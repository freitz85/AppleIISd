# AppleIISd
SD card based ProFile replacement for enhanced Apple IIe computers

The **AppleIISd** is an SD card based replaced for the ProFile harddrive. In contrast to other SD card based cards this card does not replace a Disk II drive. Data is saved directly onto the SD card, it is not via images on a FAT system, like on other cards. The SD card is read- / writable with CiderPress.

A CPLD is used as a SPI controller and translates, together with the ROM driver, SD card data to/from the Apple IIe.

The assembler sources are written in Merlin-8.

## Features
* up to 128MB storage space (4x 65535 blocks), currently 32MB
* ProDOS driver in ROM
* Auto boot
* Access LED
* Write protect sensing (not yet)
* Card detect sensing (not yet)

## Requirements
The AppleIISd requires and has been tested on an enhanced IIe computer. The ROM code uses some 65c02 opcodes. ProDOS versions 1.1 to 2.4.1 seem to work. 

## TODOs
* Support more than one partition
* Implement card detect and write protect sensing
* Use 7MHz clock as SPI clock



![Alt text](IMG_20170813_124455.jpg)
