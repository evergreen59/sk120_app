# SK60X / 120X Communication Protocol Description

---

## 1. Protocol Introduction

The communication protocol is MODBUS-RTU protocol. The product only supports function codes `0x03`, `0x06`, `0x10`; the communication interface is TTL serial port.

---

## 2. Introduction of the Communication Protocol

Information transmission is asynchronous, and the Modbus-RTU mode is in 11-bit bytes.

| Field | Value |
|---|---|
| Word format (serial data) | The 10-bit binary |
| Start bit | One |
| Data bit | Eight |
| Parity check bit | Not have |
| Stop bit | One |

**Data frame structure:**

| Data frame interval | Address code | FC | Data field | CRC verification |
|---|---|---|---|---|
| Of 3.5 bytes and above | 1 Bytes | 1 Bytes | N byte | 2 Bytes |

Before sending data, the rest time of data bus, i.e., no data transmission time is greater than 3.5 (e.g., baud rate is 9600, when 5ms) message sending to start with at least 3.5 bytes of time pause interval, the entire message frame must be as a series. The continued data stream is refreshed if there is more than 3.5 bytes of pause before the frame is completed.

Incomplete message and assume that the next byte is the address domain for a new message. Similarly, if a new message is less than within 3.5 characters, then before the previous message begins, the receiving device will regard it as a continuation of the previous message.

### 1.1 Address Code

The address code is the first byte (8 bits) of each communication message frame, ranging from 1 to 255. This byte indicates the set by the user.

The slave of the address will receive the information sent by the host machine. Each slave must have a unique address code and only the ground. The slave of the address code can respond to the return information. When the information is returned, the data starts with the respective address code.

The address code sent by the host machine indicates the slave machine address that will be sent to, and the address code returned by the slave machine indicates the returned slave machine address. The address code required indicates where the information comes from.

### 1.2 Function Code

The function code is the second byte of each communication information frame transmission, and the function code defined by the ModBus communication regulation is 1 to 127. Send as a host request, tell the slave what action to perform through a function code. As a slave response, return.

The function code is the same as the function code sent from the host, and indicates that the slave has responded to the host and has performed related operations.

This machine only supports `0x03`, `0x06`, `0x10` functional codes.

| FC | Definition | Operation (binary) |
|---|---|---|
| 0x03 | Read register data | Reads the data for one or more registers |
| 0x06 | Write a single register | Write a set of binary data to a single register |
| 0x10 | Write multiple registers | Write multiple sets of binary data to multiple registers |

### 1.3 Data Area

The data area includes what kind of information to be returned by the machine or what action to perform, which can be data (e.g., on/off volume input/output, analog volume input/output, register, etc.), reference address, etc. For example, the host passes by the function code `03` tells the value of the return register (including the starting address of the register to read and the length of the read register). The data returned includes the data length of the register and the data content.

#### 0x03 Read the Functional Host Format

| Address code | FC | Register start address | Number of register addresses n (1~32) | CRC check code |
|---|---|---|---|---|
| 1 Bytes | 1 Bytes | 2 Bytes | 2 Bytes | 2 Bytes |

#### 0x03 Read Function Returns the Format from the Machine

| Address code | FC | Number of returned registers n * 2 | Register data | CRC check code |
|---|---|---|---|---|
| 1 Bytes | 1 Bytes | 1 Bytes | And 2 * n bytes | 2 Bytes |

#### 0x06 Write a Single Register Function Host Format

| Address code | FC | Register start address | Register data | CRC check code |
|---|---|---|---|---|
| 1 Bytes | 1 Bytes | 2 Bytes | 2 Bytes | 2 Bytes |

#### 0x06 Write a Single Register Function from the Machine Return Format

| Address code | FC | Register start address | Register data | CRC check code |
|---|---|---|---|---|
| 1 Bytes | 1 Bytes | 2 Bytes | Two bytes | 2 Bytes |

#### 0x10 Write in a Multiple-Register Function Host Format

| Address code | FC | Register start address | Number of register addresses n (1~32) | Write the number of bytes 2*n | Register data | CRC check code |
|---|---|---|---|---|---|---|
| 1 Bytes | 1 Bytes | 2 Bytes | 2 Bytes | 1 Bytes | 2 * n Bytes | 2 Bytes |

#### 0x10 Write Multiple Registers from the Host Format

| Address code | FC | Register start address | Number of register addresses n | CRC check code |
|---|---|---|---|---|
| 1 Bytes | 1 Bytes | 2 Bytes | 2 Bytes | 2 Bytes |

---

## Protocol Register Introduction

> **Factory default port rate: 115200, device address: 1**
>
> The data in a single register address is double-byte data.

| Name | Explain | Byte number | Radix point | Unit | Read/Write | Register address (decimal) | Register address (hexadecimal) |
|---|---|---|---|---|---|---|---|
| V-SET | Voltage setting | 2 | 2 | V | R/W | 0 | 0x0000 |
| I-SET | Current setting | 2 | 3 | A | R/W | 1 | 0x0001 |
| VOUT | Output voltage display value | 2 | 2 | V | R | 2 | 0x0002 |
| IOUT | Output current display value | 2 | 3 | A | R | 3 | 0x0003 |
| POWER | Output power display value | 2 | 2 | W | R | 4 | 0x0004 |
| UIN | Input voltage display value | 2 | 2 | V | R | 5 | 0x0005 |
| AH-LOW | Output AH is low by 16 bits | 2 | 0 | maH | R | 6 | 0x0006 |
| AH-HIGH | Output AH is high by 16 bits | 2 | 0 | maH | R | 7 | 0x0007 |
| WH-LOW | Output WH is low by 16 bits | 2 | 0 | mwH | R | 8 | 0x0008 |
| WH-HIGH | Output WH high by 16 bits | 2 | 0 | mwH | R | 9 | 0x0009 |
| OUT_H | Open time-length-hours | 2 | 0 | H | R | 10 | 0x000A |
| OUT_M | Start length-minutes | 2 | 0 | M | R | 11 | 0x000B |
| OUT_S | Open time-seconds | 2 | 0 | S | R | 12 | 0x000C |
| T_IN | Internal temperature value | 2 | 1 | F/C | R | 13 | 0x000D |
| T_EX | External temperature value | 2 | 1 | F/C | R | 14 | 0x000E |
| LOCK | Key lock | 2 | 0 | – | R/W | 15 | 0x000F |
| PROTECT | Protect status | 2 | 0 | – | R/W | 16 | 0x0010 |
| CVCC | Constant pressure constant current state | 2 | 0 | – | R | 17 | 0x0011 |
| ONOFF | Switched output | 2 | 0 | – | R/W | 18 | 0x0012 |
| F-C | The temperature symbol | 2 | 0 | – | R/W | 19 | 0x0013 |
| B-LED | Back brightness level | 2 | 0 | – | R/W | 20 | 0x0014 |
| SLEEP | Rest screen time | 2 | 0 | M | R/W | 21 | 0x0015 |
| MODEL | Product model | 2 | 0 | – | R | 22 | 0x0016 |
| VERSION | Firmware version number | 2 | 0 | – | R | 23 | 0x0017 |
| SLAVE-ADD | From the machine address | 2 | 0 | – | R/W | 24 | 0x0018 |
| BAUDRATE_L | Baud rate | 2 | 0 | – | R/W | 25 | 0x0019 |
| T-IN-OFFSET | Internal temperature correction | 2 | 1 | F/C | R/W | 26 | 0x001A |
| T-EX-OFFSET | External temperature correction | 2 | 1 | F/C | R/W | 27 | 0x001B |
| BUZZER | The buzzer switch | 2 | 0 | – | R/W | 28 | 0x001C |
| EXTRACT-M | Quickly call up the data group | 2 | 0 | – | R/W | 29 | 0x001D |
| DEVICE | Device status | 2 | 0 | – | R/W | 30 | 0x001E |
| MPPT-SW | MPPT switch | 2 | 0 | – | R/W | 31 | 0x001F |
| MPPT-K | MPPT Maximum power point coefficient | 2 | 0 | – | R/W | 32 | 0x0020 |
| BatFul | Full current current | 2 | 0 | – | R/W | 33 | 0x0021 |
| CW-SW | Constant power switch | 2 | 0 | – | R/W | 34 | 0x0022 |
| CW | Constant power value | 2 | 0 | – | R/W | 35 | 0x0023 |
| V-SET | Voltage setting | 2 | 2 | V | R/W | 80 | 0x0050 |
| I-SET | Current setting | 2 | 3 | A | R/W | 81 | 0x0051 |
| S-LVP | Low pressure protection value | 2 | 2 | V | R/W | 82 | 0x0052 |
| S-OVP | Overpressure protection value | 2 | 2 | V | R/W | 83 | 0x0053 |
| S-OCP | Overflow protection value | 2 | 3 | A | R/W | 84 | 0x0054 |
| S-OPP | Overpower protection value | 2 | 1 | W | R/W | 85 | 0x0055 |
| S-OHP_H | Maximum output time-hours | 2 | 0 | H | R/W | 86 | 0x0056 |
| S-OHP_M | Maximum output time-minutes | 2 | 0 | M | R/W | 87 | 0x0057 |
| S-OAH_L | Maximum output AH is 16 bits lower | 2 | 0 | maH | R/W | 88 | 0x0058 |
| S-OAH_H | Maximum output AH is 16 bits higher | 2 | 0 | maH | R/W | 89 | 0x0059 |
| S-OWH_L | Maximum output WH is 16 bits lower | 2 | 0 | 10mwH | R/W | 90 | 0x005A |
| S-OWH_H | Maximum output WH is 16 bits high | 2 | 0 | 10mwH | R/W | 91 | 0x005B |
| S-OTP | Overtemperature protection value | 2 | 0 | F/C | R/W | 92 | 0x005C |
| S-INI | Power output switch | 2 | 0 | – | R/W | 93 | 0x005D |
| S-ETP | External pass, temperature protection | 2 | 0 | – | R/W | 94 | 0x005E |

> **Note 1:** (0019H) Port rate register meaning: `0:9600` `1:14400` `2:19200` `3:38400` `4:56000` `5:576000` `6:115200` (`7:2400` `8:4800`, some equipment support)

> **Note 2:** The product has M0–M9, each group has 14 data numbers 20–2D. M0 data group is the default, M1 and M2 data groups are the product panel, and M3–M9 is the ordinary storage array. The starting address of the data group is `0050H + data group number * 0010H`. For example, the starting address of M3 data group is `0050H + 3 * 0010H = 0080H`.

> **Note 3:** The read and write value of the key lock function is 0 and 1. 0 is non-locked, and 1 is locked.

> **Note 4:** Protection status register:
> `0`: Normal operation, `1`: OVP, `2`: OCP, `3`: OPP, `4`: LVP, `5`: OAH, `6`: OHP, `7`: OTP, `8`: OEP, `9`: OWH, `10`: ICP, `11`: ETP

**Alarm code table:**

| 0: Alarm code | 1: OVP overvoltage protection | 2: OCP overcurrent protection | 3: OPP, over-power protection |
|---|---|---|---|
| 4: LVP input undervoltage protection | 5: OAH maximum output capacity | 6: OHP maximum output time | 7: OTP over-temperature protection |
| 8: OEP, with no output protection | 9: OWH maximum energy output | 10: ICP maximum input current protection | 11: ETP, external temperature protection |

> **Note 5:** Constant voltage constant current state read value is 0 and 1. 0 is CV state and 1 is CC state.

> **Note 6:** The read and write value of switch output function are 0 and 1. 0 is closed state and 1 is open state.

> **Note 7:** The backlight brightness level is 0–5. 0 is the darkest and 5 is the brightest.

> **Note 8:** The write value of the quick call-up data group function is 0–9, and the corresponding data group data will be automatically called up after writing.

---

### 1.4 Error Check Code (CRC Check)

The host machine or slave can use the verification code to distinguish whether the received information is correct. Due to the electronic noise or some other interference, errors sometimes occur during the transmission of information. The error check code (CRC) can check the host or slave communication data whether the information in the sending process is wrong; the wrong data can be abandoned (whether sent or received), thus increasing the system safety and efficiency of the system.

MODBUS The CRC of the communication protocol (redundant cycle code) consists of 2 bytes, namely, the 16-bit binary number.

The CRC code is calculated by the sending device (host) and placed at the tail of the sending message frame. The device receiving the message (slave) is heavier. New calculation of the CRC received information, compare whether the calculated CRC is consistent with the received. If the two do not match, then indicates an error. When CRC check code is sent, the low is before and the high is behind.

#### Calculation Method of the CRC Code

1. The preset 116-bit register is hex FFFF (all 1); call this register is CRC register.
2. Put the first 8-bit binary data (both the first byte of the communication information frame) and the low 8 of the 16-bit CRC register at different positions or positions, put the results in the CRC register.
3. Move the content of the CRC register to one right (toward the low) to fill the highest position with 0, and check the displacement after the right shift.
4. If displacement is 0: repeat step 3 (move one bit right again); if displacement is 1: CRC register and multiple items. Formula A001 (`1010000000000001`).
5. Repeat steps 3 and 4 until the right moves 8 times, so that the entire 8-bit data is processed.
6. Repeat steps 2 to step 5 to process the next byte of the communication information frame.
7. The high and low levels of the 16-bit CRC register obtained after calculating all the bytes of the communication information frame according to the above steps. Bytes for exchange.
8. The final CRC register content is the CRC code.

---

## 3. Communication Instances

### Example 1: The Host Machine Reads the Output Voltage and the Output Current Display Value

**Message format sent by the host:**

| Host sent | Byte number | Send the message | Remarks |
|---|---|---|---|
| From the machine address | 1 | 01 | Send to the with address 01 |
| FC | 1 | 03 | Read the register |
| Register start address | 2 | 0002H | Register start address |
| Number of register addresses | 2 | 0002H | There are 2 bytes in total |
| CRC a sign or object indicating number | 2 | 65CBH | The CRC codes are calculated by the host |

For example, if the current display value is 05.00V, 1.500A, the message format returned by the slave response:

| From the machine response | Byte number | The information returned | Remarks |
|---|---|---|---|
| From the machine address | 1 | 01 | From the machine 01 |
| FC | 1 | 03 | Read the register |
| Number of read bytes | 1 | 04 | A total of 1 byte |
| Address is the contents of the 0002H register | 2 | 01F4H | Output voltage display value |
| Address is the contents of the 0003H register | 2 | 05DCH | Output current display value |
| CRC a sign or object indicating number | 2 | B8F4H | The CRC code is calculated by the slave machine |

### Example 2: The Host Machine Should Set the Voltage to 24.00V

**Message format sent by the host:**

| Host sent | Byte number | Send the message | Remarks |
|---|---|---|---|
| From the machine address | 1 | 01H | From the machine 01 |
| FC | 1 | 06H | Write a single register |
| Register address | 2 | 0000H | Register address |
| Address is the contents of the 0000H register | 2 | 0960H | Set the output voltage value |
| CRC a sign or object indicating number | 2 | 8FB2H | The CRC codes are calculated by the host |

**Message format of the response returned after receiving from the machine:**

| From the machine response | Byte number | The information returned | Remarks |
|---|---|---|---|
| From the machine address | 1 | 01H | Send to the with address 01 |
| FC | 1 | 06H | Write a single register |
| Register address | 2 | 0000H | Register start address |
| Address is the contents of the 0000H register | 2 | 0960H | Set the output voltage value |
| CRC a sign or object indicating number | 2 | 8FB2H | The CRC code is calculated by the slave machine |

### Example 3: The Host Should Set the Voltage of 24.00V and the Current of 15.00A

**Message format sent by the host:**

| Host sent | Byte number | Send the message | Remarks |
|---|---|---|---|
| From the machine address | 1 | 01H | From the machine 01 |
| FC | 1 | 10H | Write register |
| Register start address | 2 | 0000H | Register start address |
| Number of register addresses | 2 | 0002H | There are 2 bytes in total |
| Write the number of bytes | 1 | 04H | A total of 1 byte |
| Address is the contents of the 0000H register | 2 | 0960H | Set the output voltage value |
| Address is the contents of the 0001H register | 2 | 05DCH | Set the output current value |
| CRC a sign or object indicating number | 2 | F2E4H | The CRC codes are calculated by the host |

**Message format of the response returned after receiving from the machine:**

| From the machine response | Byte number | The information returned | Remarks |
|---|---|---|---|
| From the machine address | 1 | 01H | Send to the with address 01 |
| FC | 1 | 10H | Write register |
| Register start address | 2 | 0000H | Register start address |
| Number of register addresses | 2 | 0002H | There are 2 bytes in total |
| CRC a sign or object indicating number | 2 | 41C8H | The CRC code is calculated by the slave machine |
