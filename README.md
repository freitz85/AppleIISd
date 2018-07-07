# AppleIISd
SD card based ProFile replacement for enhanced Apple IIe and IIgs computers

The **AppleIISd** is a SD card based replaced for the ProFile harddrive. In contrast to other SD card based devices, this card does not replace a Disk II drive. Data is saved directly onto the SD card, not via images on a FAT system, like on other cards. The SD card is accessable with [CiderPress](http://a2ciderpress.com/).

A Xilinx CPLD is used as a SPI controller and translates, together with the ROM driver, SD card data to/from the Apple IIe. The VHDL source is based on [SPI65/B](http://www.6502.org/users/andre/spi65b) by André Fachat.

The assembler sources are written for CC65. The [schematics](AppleIISd.pdf) are available as PDF.

## Features
* works with ProDOS and GS/OS
* up to 128MB storage space (4x 65535 blocks)
* ProDOS and Smartport driver in ROM
* Auto boot
* Access LED
* Card detect and write protect sensing
* Skip boot when Open-Apple key is pressed

## Requirements
The AppleIISd requires an enhanced IIe or IIgs computer. The ROM code uses some 65c02 opcodes and will therefore not work on a II, II+ or unenhanced IIe. It has been tested in the following combinations:
* Apple IIgs Rom 01, GS/OS 6.0.4
* Apple IIgs Rom 01, Prodos 2.4.1
* Apple IIgs Rom 01, Prodos 1.9
* Apple IIe enhanced, 128k, Prodos 2.4.1
* Apple IIe enhanced, 128k, Prodos 1.9
* Apple IIe enhanced, 64k, Prodos 1.9

When a 2732 type ROM is used, the binary image has to be programmed at offset 0x800, because A11 is always high for compatibility with 2716 type ROMs.

## Smartport drive remapping
The AppleIISd features Smartport drivers in ROM to provide more than two drives in both GS/OS and ProDOS.

As ProDOS supports only two drives per slot, additional drives on a Smartport device are mapped to 'phantom slots'. Version prior to version 2 supported only the remapping of drives when the card was in slot 5. Starting with version 2, the remapping seems to work on all slots. The following list shows the assignments as slot/drive, when no other devices are attached:

* Slot 7: 7/1, 7/2, 4/1, 4/2
* Slot 6: 6/1, 6/2, 4/1, 4/1
* Slot 5: 5/1, 5/2, 2/1, 2/1
* Slot 4: 4/1, 4/2, 1/1, 1/2
* Slot 3: 80 col HW, not usable
* Slot 2: 2/1, 2/2, 4/1, 4/2
* Slot 1: 1/1, 1/2, 4/1, 4/2

When more devices are connected, things get a little confusing ;-)

## Building the sources
Be sure to have the newest version of CC65 (V2.16) and some kind of Make instaled, then type one of the following comands:
```
make                            # generate binaries
make OPTIONS=mapfile,listing    # generate mapfile and listing, too
make clean                      # delete binaries
```
Alternatively use the VisualStudio solution.

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
* SRAM option (may never work, though)
* Enable more than 4 volumes under GS/OS
* Use 28 pin socket to support other EPROMS than 2716 and 2732

## Known Bugs
* Does not work with some Z80 cards present


![Front_Img](Images/Card%20Front.jpg)
