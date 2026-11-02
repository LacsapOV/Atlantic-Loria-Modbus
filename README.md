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
<img src="https://private-user-images.githubusercontent.com/260115439/688105651-809a0025-6496-4eed-83d0-4668467c4f11.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3OTM2MzE5NTgsIm5iZiI6MTc5MzYzMTY1OCwicGF0aCI6Ii8yNjAxMTU0MzkvNjg4MTA1NjUxLTgwOWEwMDI1LTY0OTYtNGVlZC04M2QwLTQ2Njg0NjdjNGYxMS5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjYxMTAyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI2MTEwMlQxNTAwNThaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT00ZDUyNTBhZTRjZTFiMjc4NTFjNDJkYTY1MmMzYjQ0MzI3OGM0NTM5MjQ2Yzg5YjU3ODY1NDRhNWRhNjJjY2MwJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCZyZXNwb25zZS1jb250ZW50LXR5cGU9aW1hZ2UlMkZwbmcifQ.DEddwllwNvSgPol28X6JYN4XeHF6ip6vQbTLKFqaZm0" width="250">

## Connection settings
- Baudrate: 19.200
- Data Bits: 8
- Parity: None
- Stop Bits: 1
