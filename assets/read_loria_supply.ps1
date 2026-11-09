# Atlantic Loria - supply water temperature over RS485/Ethernet
# Windows PowerShell 5.1 or newer; no modules or additional software required.
# READ ONLY: sends proprietary function 0x41 to register C4 17 8F.
# Examples:
#   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\read_loria_supply.ps1 -Ip 192.168.1.200
#   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\read_loria_supply.ps1 -Ip 192.168.1.200 -Mode Transparent -Port 4196

param(
    [Parameter(Mandatory=$true)][string]$Ip,
    [ValidateSet('TcpToRtu', 'Transparent')][string]$Mode = 'TcpToRtu',
    [ValidateRange(0,65535)][int]$Port = 0,
    [ValidateRange(1,247)][int]$UnitId = 1,
    [ValidateRange(500,30000)][int]$TimeoutMs = 4000
)

$ErrorActionPreference = 'Stop'
if ($Port -eq 0) {
    $Port = if ($Mode -eq 'TcpToRtu') { 502 } else { 4196 }
}

function Read-Exactly([System.IO.Stream]$Stream, [int]$Count) {
    [byte[]]$Buffer = New-Object byte[] $Count
    $Offset = 0
    while ($Offset -lt $Count) {
        $Read = $Stream.Read($Buffer, $Offset, $Count - $Offset)
        if ($Read -le 0) { throw "Connection closed while waiting for $Count bytes (got $Offset)." }
        $Offset += $Read
    }
    return ,$Buffer
}

function Format-Hex([byte[]]$Bytes) {
    return [BitConverter]::ToString($Bytes).Replace('-', ' ')
}

function Get-ModbusCrc([byte[]]$Bytes) {
    $Crc = 65535
    foreach ($Byte in $Bytes) {
        $Crc = $Crc -bxor [int]$Byte
        for ($i = 0; $i -lt 8; $i++) {
            if (($Crc -band 1) -ne 0) {
                $Crc = ($Crc -shr 1) -bxor 0xA001
            } else {
                $Crc = $Crc -shr 1
            }
        }
    }
    return [int]$Crc
}

$Client = $null
try {
    Write-Host "Connecting to $Ip`:$Port (mode=$Mode, unit=$UnitId) ..."
    $Client = New-Object System.Net.Sockets.TcpClient
    $Connect = $Client.BeginConnect($Ip, $Port, $null, $null)
    try {
        if (-not $Connect.AsyncWaitHandle.WaitOne($TimeoutMs)) {
            throw "TCP connection timed out. Check the Waveshare IP/port, network, and TCP Server mode."
        }
        $Client.EndConnect($Connect)
    } finally {
        $Connect.AsyncWaitHandle.Close()
    }
    $Stream = $Client.GetStream()
    $Stream.ReadTimeout = $TimeoutMs
    $Stream.WriteTimeout = $TimeoutMs

    if ($Mode -eq 'TcpToRtu') {
        # MBAP: transaction=1, protocol=0, length=5 (unit + 4-byte PDU).
        # Loria proprietary PDU: function 41, 24-bit address C4 17 8F.
        [byte[]]$Request = @(0x00,0x01,0x00,0x00,0x00,0x05,$UnitId,0x41,0xC4,0x17,0x8F)
        Write-Host ('TX Modbus TCP: ' + (Format-Hex $Request))
        $Stream.Write($Request, 0, $Request.Length)
        [byte[]]$Header = Read-Exactly $Stream 7
        $Tid = ([int]$Header[0] * 256) + $Header[1]
        $Protocol = ([int]$Header[2] * 256) + $Header[3]
        $Length = ([int]$Header[4] * 256) + $Header[5]
        if ($Tid -ne 1 -or $Protocol -ne 0 -or $Header[6] -ne $UnitId -or
            $Length -lt 2 -or $Length -gt 253) {
            throw ('Invalid Modbus TCP header: ' + (Format-Hex $Header))
        }
        [byte[]]$Pdu = Read-Exactly $Stream ($Length - 1)
        Write-Host ('RX Modbus TCP: ' + (Format-Hex ($Header + $Pdu)))
    } else {
        # A transparent TCP bridge carries the RTU frame, including the CRC16.
        [byte[]]$Body = @($UnitId,0x41,0xC4,0x17,0x8F)
        $Crc = Get-ModbusCrc $Body
        [byte[]]$Request = $Body + [byte[]]@(($Crc -band 255), (($Crc -shr 8) -band 255))
        Write-Host ('TX Modbus RTU: ' + (Format-Hex $Request))
        $Stream.Write($Request, 0, $Request.Length)
        [byte[]]$Prefix = Read-Exactly $Stream 3
        if ($Prefix[0] -ne $UnitId) { throw ('Unexpected slave address: ' + $Prefix[0]) }
        if ($Prefix[1] -eq 0xC1) {
            [byte[]]$Rest = Read-Exactly $Stream 2
        } elseif ($Prefix[1] -eq 0x41 -and $Prefix[2] -ge 1 -and $Prefix[2] -le 64) {
            [byte[]]$Rest = Read-Exactly $Stream ($Prefix[2] + 2)
        } else {
            throw ('Unexpected RTU response prefix: ' + (Format-Hex $Prefix))
        }
        [byte[]]$Response = $Prefix + $Rest
        Write-Host ('RX Modbus RTU: ' + (Format-Hex $Response))
        [byte[]]$WithoutCrc = $Response[0..($Response.Length-3)]
        $ExpectedCrc = Get-ModbusCrc $WithoutCrc
        $ActualCrc = ([int]$Response[$Response.Length-1] -shl 8) -bor $Response[$Response.Length-2]
        if ($ExpectedCrc -ne $ActualCrc) { throw 'Modbus RTU CRC mismatch (check line settings/wiring).' }
        [byte[]]$Pdu = $Response[1..($Response.Length-3)]
    }

    if ($Pdu.Length -eq 2 -and $Pdu[0] -eq 0xC1) {
        $Code = $Pdu[1]
        $Message = switch ($Code) {
            1 { 'Illegal Function' }
            2 { 'Illegal Data Address' }
            3 { 'Illegal Data Value' }
            default { 'Device/gateway exception' }
        }
        throw ('Modbus exception 0x{0:X2}: {1}. Check the custom 0x41 function and bridge mode.' -f $Code,$Message)
    }
    if ($Pdu.Length -ne 4 -or $Pdu[0] -ne 0x41 -or $Pdu[1] -ne 2) {
        throw ('Unexpected response PDU: ' + (Format-Hex $Pdu))
    }
    $Raw = ([int]$Pdu[2] * 256) + [int]$Pdu[3]
    if ($Raw -ge 32768) { $Raw -= 65536 }
    $Temperature = $Raw / 10.0
    Write-Host ('SUCCESS - Supply water temperature: {0:N1} deg C (raw={1})' -f $Temperature,$Raw) -ForegroundColor Green
}
catch {
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'Check the Waveshare IP/port, RS485 A/B, 19200 baud, 8N1, and that no other Modbus master is polling.'
    Write-Host 'If the bridge rejects proprietary function 0x41, try transparent TCP Server mode and -Mode Transparent -Port 4196 (or your configured port).'
    exit 1
}
finally {
    if ($null -ne $Client) { $Client.Close() }
}
