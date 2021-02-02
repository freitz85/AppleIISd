#!/bin/bash

make clean
make
java -jar ../Binary/AppleCommander-ac-1.5.0.jar -d ../Binary/Flasher.dsk flasher
java -jar ../Binary/AppleCommander-ac-1.5.0.jar -as ../Binary/Flasher.dsk flasher < Flasher.bin
cp Flasher.bin ../Binary/
