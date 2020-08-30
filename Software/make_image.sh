#!/bin/bash

make clean
make
java -jar AppleCommander-ac-1.5.0.jar -d flasher.dsk flasher
java -jar AppleCommander-ac-1.5.0.jar -as flasher.dsk flasher < flasher.bin
