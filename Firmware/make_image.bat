make clean
make OPTIONS=mapfile,listing
java -jar ..\Binary\AppleCommander-ac-1.5.0.jar -d ..\Binary\Flasher.dsk appleiisd.bin
java -jar ..\Binary\AppleCommander-ac-1.5.0.jar -p ..\Binary\Flasher.dsk appleiisd.bin $00 < AppleIISd.bin
copy AppleIISd.bin ..\Binary
