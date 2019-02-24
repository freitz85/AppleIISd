#include <stdio.h>
#include <errno.h>
#include <conio.h>
#include <apple2enh.h>

int main()
{
    // Binary can't be larger than 2k
    char buffer[2048];
    char* pBuf = buffer;
    FILE* pFile;
    size_t fileSize;
    char slotNum;

    videomode(VIDEOMODE_80COL);
    cprintf("AppleIISd firmware flasher\r");
    cprintf("(c) 2019 Florian Reitz\r\r");
    
    // ask for slot
    cursor(1);      // enable blinking cursor
    cprintf("Slot number (1-7): ");
    slotNum = cgetc();
    cursor(0);      // disable blinking cursor    

    // check if slot is valid
    if((slotNum < 1) || (slotNum > 7))
    {
        cprintf("Invalid slot number!");
        return 1;   // failure
    }

    // open file
    pFile = fopen("AppleIISd.bin", "rb");
    if(pFile)
    {
        // read buffer
        fileSize = fread(buffer, sizeof(buffer), 1, pFile);

        // enable write

        // clear 0xCFFF
        *((char*)0xCFFF) = 0;

        // write to SLOTROM

        // write to EXTROM

        // disable write
    }
    else
    {
        cprintf("Can't open binary file: %d\r", errno);
        return 1;
    }

    return 0;   // success
}


