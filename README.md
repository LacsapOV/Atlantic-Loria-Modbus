# Mapping of the Atlantic Loria Modbus interface

This project describes all known Modbus functions and registers for the Atlantic Loria Heat Pump. The goal is to map all registers so these can be used to log sensor data like Temperature, Flow and Frequency.

It also describes how to make a connection to the Modbus interface. Including wiring and connection settings.

## Protocol
The Atlantic Loria Heat Pump uses the Modbus RTU protocol through a rs485 serial interface. All public functions 0x1, 0x2, 0x3 and 0x4 return empty responses. Only proprietary function x41 and x42 are implemented. (Keep in mind most Modbus tools don't support functions other than 0x1 through 0x4)

Registers are divided into two files. A file with mapped registers and a file with unmapped registers. Please update accordingly.
- mapped.txt
- unmapped.txt

## Wiring
<img src="https://github.com/LacsapOV/Atlantic-Loria-Modbus/blob/main/assets/molex_male.jpg?raw=true" width="250">
The Male Molex 3x2 connector is located underneath the expansion vessel. (See image above)

---

<img src="https://github.com/LacsapOV/Atlantic-Loria-Modbus/blob/main/assets/molex_female.jpg?raw=true" width="250">
You'll need a Female Molex 3x2 connector. (See image above)

---

<img src="https://github.com/LacsapOV/Atlantic-Loria-Modbus/blob/main/assets/molex_wiring.jpg?raw=true" width="250">

- 1: 24v DC
- 2: 
- 3: A (Data)
- 4: GND
- 5: 
- 6: B (Data)

## Connector location
<img src="https://github.com/LacsapOV/Atlantic-Loria-Modbus/blob/main/assets/688105651-809a0025-6496-4eed-83d0-4668467c4f11.png" width="250">
<img src="https://raw.githubusercontent.com/LacsapOV/Atlantic-Loria-Modbus/refs/heads/main/assets/700065304-b68c0055-3b54-4fb2-8479-919207d733d5.png" width="250">
<img src="https://raw.githubusercontent.com/LacsapOV/Atlantic-Loria-Modbus/refs/heads/main/assets/700065302-5b93fb8c-2da6-41ad-b5a1-9c09e25ebedc.png" width="250">

## Connection settings
- Baudrate: 19.200
- Data Bits: 8
- Parity: None
- Stop Bits: 1
