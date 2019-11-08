# AppleIISd
SD card based ProFile replacement for enhanced Apple IIe and IIgs computers

The **AppleIISd** is a SD card based replaced for the ProFile harddrive. In contrast to other SD card based devices, this card does not replace a Disk II drive. Data is saved directly onto the SD card, not via images on a FAT system, like on other cards. The SD card is accessable with [CiderPress](http://a2ciderpress.com/).

A Xilinx CPLD is used as a SPI controller and translates, together with the ROM driver, SD card data to/from the Apple IIe. The VHDL source is based on [SPI65/B](http://www.6502.org/users/andre/spi65b) by André Fachat.

The assembler sources are written for CC65. The [schematics](AppleIISd.pdf) are available as PDF.

## Features
* works with ProDOS and GS/OS
* up to 128MB storage space (4x 65535 blocks)
* ProDOS and Smartport driver in ROM
* Firmware update from ProDOS
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


## Registers
The control registers of the *AppleIISd* are mapped to the usual I/O space at **$C0n0 - $C0n3**, where n is slot+8. All registers and bits are read/write, except where noted.

| Address | Function        | Default value |
| ------- | --------------- | ------------- |
| $C0n0   | DATA            | - |
| $C0n1   | **0:** PGMEN<br>**1:** -<br>**2:** ECE<br>**3:** -<br>**4:** FRX<br>**5:** BSY (R)<br>**6:** -<br>**7:** TC (R) | 0<br>0<br>0<br>0<br>0<br>0<br>0<br>0<br> |
| $C0n2   | unused          | $00 |
| $C0n3   | **0:** /SS<br>**1:** -<br>**2:** -<br>**3:** -<br>**4:** SDHC<br>**5:** WP (R)<br>**6:** CD (R)<br>**7:** INIT | 1<br>0<br>0<br>0<br>0<br>-<br>-<br>0 |

**DATA** SPI data register - Is used for both input and output. When the register is written to, the controller will output the byte on the SPI bus. When it is read from, it reflects the data that was received over the SPI bus.

**ECE** External Clock Enable - This bit enables the the external clock input to the SPI controller. In the *AppleIISd*, this effectively switches the SPI clock between 500kHz (ECE = 0) and 3.5MHz (ECE = 1).

**FRX** Fast Receive mode - When set to 1, fast receive mode triggers shifting upon reading or writing the SPI Data register. When set to 0, shifting is only triggered by writing the SPI data register.

**BSY** Busy - This bit is 1 as long as data is shifted out on the SPI bus. *BSY* is read-only.

**TC** Transfer Complete - This flag is set when the last bit has been shifted out onto the SPI bus and is cleared when *SPI data* is read.

**/SS** Slave select - Write 0 to this bit to select the SD card.

**SDHC** This bit is used by the initialization routine in firmware to signalize when a SDHC card was found. Do not write to manually.

**WP** Write Protect - This read-only bit is 0 when writing to the card is enabled by the switch on the card.

**CD** Card Detect - This read-only bit is 0 when a card is inserted.

**INIT** Initialized - This bit is set to 1 when the SD card has been initialized by the firmware. Do not write manually.

## TODOs
* Much more testing
* Enable more than 4 volumes under GS/OS
* Support for 6502 CPUs

## Known Bugs
* Does not work with some Z80 cards present
* Programs not startable from partitions 3 and 4 under ProDOS


![Front_Img](Images/Card%20Front.jpg)
