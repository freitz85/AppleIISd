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



void writeChip(const uint8* pSource, uint8* pDest, uint16 length);
void printStatus(uint8 percentage);

// Binary can't be larger than 2k
uint8 buffer[2048] = { 0 };

int main()
{
    FILE* pFile;
    char slotNum;

    APPLE_II_SD_T* pAIISD = (APPLE_II_SD_T*)SLOT_IO_START;
    uint8* pSlotRom = SLOT_ROM_START;
    uint8* pExtRom = EXT_ROM_START;

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

    ((uint8*)pAIISD) += slotNum << 4;
    pSlotRom += slotNum << 8;

    // open file
    pFile = fopen("AppleIISd.bin", "rb");
    if(pFile)
    {
        // read buffer
        uint16 fileSize = fread(buffer, 1, sizeof(buffer), pFile);
        fclose(pFile);
        pFile = NULL;

        if(fileSize == 2048)
        {
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
        }
        else
        {
            cprintf("\r\nWrong file size: %d\r\n", fileSize);
            return 1;
        }
    }
    else
    {
        cprintf("Can't open binary file: %d\r", errno);
        return 1;
    }

    return 0;   // success
}

void writeChip(const uint8* pSource, uint8* pDest, uint16 length)
{
    uint32 i;
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

void printStatus(uint8 percentage)
{
    static STATE_CURSOR_T state = STATE_0;
    uint8 wait = 0;

    uint8 x = wherex();
    cprintf("% 2hhu %c", percentage, (char)state);
    gotox(x);

    state++;
    if(state == STATE_LAST)
    {
        state = STATE_0;
    }
}
