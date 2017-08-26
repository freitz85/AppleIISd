# Apple][Sd
SD card based ProFile replacement for enhanced Apple IIe computers

The **Apple][Sd** is a SD card based replaced for the ProFile harddrive. In contrast to other SD card based devices, this card does not replace a Disk II drive. Data is saved directly onto the SD card, not via images on a FAT system, like on other cards. The SD card is accessable with [CiderPress](http://a2ciderpress.com/).

A Xilinx CPLD is used as a SPI controller and translates, together with the ROM driver, SD card data to/from the Apple IIe. The VHDL source is based on [SPI65/B](http://www.6502.org/users/andre/spi65b) by André Fachat.

The assembler sources were written in Merlin-8. The [schematics](AppleIISd.pdf) are available as PDF.

## Features
* up to 128MB storage space (4x 65535 blocks), currently 32MB
* ProDOS driver in ROM
* Auto boot
* Access LED

## Requirements
The Apple][Sd requires and has been tested on an enhanced IIe computer. The ROM code uses some 65c02 opcodes and will therefore not work on a II, II+ or unenhanced IIe. ProDOS versions 1.1 to 2.4.1 seem to work. 

## Timing
The clock of the SPI bus *SCK* may be derived from either *Phi0* or the *7M* clock. Additionally, the divisor may be 2 to 8.

The following measurements were taken with the divisor set to 2, resulting in *fSCK* of 500kHz and 3.5MHz. Reading of a byte requires that a dummy byte is sent on the bus, before the answer can be read. Therefore the measurement is the time between sending the byte and receiving the answer. The measurement for reading of a whole 512 byte block includes the SD card commands to do so.

| Clock  | Byte   | Block  | Image                                             |
| -----: | -----: | -----: | ------------------------------------------------: |
| *Phi0* | 17.7µs | 28.8ms | [Byte](Images/Bus1.gif), [Block](Images/Spi1.png) |
| *7M*   | 3.9µs  | 15ms   | [Byte](Images/Bus2.gif), [Block](Images/Spi2.png) |

This shows that the required to read a single byte can be reduced significantly by increasing *fSCK* (as one might have guessed). Reading at 500kHz actualy requires NOPs to be inserted (or checking the TC bit in the STATUS register), while reading at 3.5MHz can be done immediately.

The time for reading a 512 byte block could *only* be halved, but there are for sure opportunities for optimization in the code surrounding the reading.

```
* single byte @ 500kHz
LDA #$FF
STA $C0C0
NOP
NOP
NOP
NOP
NOP
NOP
NOP
LDA $C0C0

* single byte @ 3.5MHz
LDA #$FF
STA $C0C0
LDA $C0C0
```


## TODOs
* Much more testing
* Support more than one partition
* Implement card detect and write protect sensing
* SRAM option (may never work, though)
* Find a use for the IRQ pin
* Use 28 pin socket to support other EPROMS than 2716 and 2732

## Known Bugs
* Does not always boot in slot 7 (may be a faulty connector, though)
* Does not work, when a Z80 card is present


![Front_Img](Images/Card%20Front.jpg)
