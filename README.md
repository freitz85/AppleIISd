# AppleIISd
SD card based ProFile replacement for enhanced Apple IIe computers

The **AppleIISd** is an SD card based replaced for the ProFile harddrive. In contrast to other SD card based cards this card does not replace a Disk II drive. Data is saved directly onto the SD card, it is not via images on a FAT system, like on other cards. The SD card is read- / writable with CiderPress.

A Xilinx CPLD is used as a SPI controller and translates, together with the ROM driver, SD card data to/from the Apple IIe. The VHDL source is based on [SPI65/B](http://www.6502.org/users/andre/spi65b) by André Fachat.

The assembler sources are written in Merlin-8.

## Features
* up to 128MB storage space (4x 65535 blocks), currently 32MB
* ProDOS driver in ROM
* Auto boot
* Access LED

## Requirements
The AppleIISd requires and has been tested on an enhanced IIe computer. The ROM code uses some 65c02 opcodes. ProDOS versions 1.1 to 2.4.1 seem to work. 

## TODOs
* Much more testing
* Support more than one partition
* Implement card detect and write protect sensing
* Use 7MHz clock as SPI clock
* SRAM option (may never work, though)
* Find a use for the IRQ pin
* Support other EPROMS than 2716 and 2732



![Front_Img](IMG_20170813_124455.jpg)
