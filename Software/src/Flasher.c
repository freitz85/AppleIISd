#include "AppleIISd.h"

#include <stdio.h>
#include <errno.h>
#include <conio.h>
#include <apple2enh.h>

typedef enum
{
    STATE_0 = 0x7C,     // pipe
    STATE_1 = 0x2F,     // slash
    STATE_2 = 0x2D,     // hyphen
    STATE_3 = 0x5C,     // backslash

    STATE_LAST          // don't use
} STATE_CURSOR_T;


void writeChip(const byte* pSource, byte* pDest, unsigned length);
void printStatus(byte percentage);

// Binary can't be larger than 2k
byte buffer[2048] = { 0 };

int main()
{
    FILE* pFile;
    char slotNum;

    APPLE_II_SD_T* pAIISD = (APPLE_II_SD_T*)SLOT_IO_START;
    byte* pSlotRom = SLOT_ROM_START;
    byte* pExtRom = EXT_ROM_START;

    videomode(VIDEOMODE_80COL);
    clrscr();
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

    ((byte*)pAIISD) += slotNum << 4;
    pSlotRom += slotNum << 8;

    // open file
    pFile = fopen("AppleIISd.bin", "rb");
    if(pFile)
    {
        // read buffer
        unsigned fileSize = fread(buffer, sizeof(buffer), 1, pFile);

        // enable write
        pAIISD->status.pgmen = 1;

        // clear 0xCFFF
        *CFFF = 0;

        // write to SLOTROM
        cprintf("\r\rFlashing SLOTROM: ");
        writeChip(buffer, pSlotRom, 256);

        // write to EXTROM
        cprintf("\r\rFlashing EXTROM: ");
        writeChip(buffer + 256, pExtRom, fileSize - 256);

        // zero rest of chip
        if(fileSize < 2048)
        {
            cprintf("\r\rErase rest of chip: ");
            writeChip(NULL, pExtRom + fileSize, 2048 - fileSize);
        }

        // disable write
        pAIISD->status.pgmen = 0;
        cprintf("\r\r Flashing finished!\r");
    }
    else
    {
        cprintf("Can't open binary file: %d\r", errno);
        return 1;
    }

    return 0;   // success
}

void writeChip(const byte* pSource, byte* pDest, unsigned length)
{
    unsigned i;
    for(i=0; i<length; i++)
    {
        if(pSource)
        {
            *pDest = pSource[i];
        }
        else
        {
            // erase if no source
            *pDest = 0;
        }

        printStatus(i * 100 / length);
        pDest++;
    }
}

void printStatus(byte percentage)
{
    static STATE_CURSOR_T state = STATE_0;

    byte x = wherex();
    cprintf("% 2hhu %c", percentage, (char)state);
    gotox(x);

    state++;
    if(state == STATE_LAST)
    {
        state = STATE_0;
    }
}
