#include "AppleIISd.h"

#include <stdio.h>
#include <errno.h>
#include <conio.h>
#include <apple2enh.h>

#define BIN_FILE_NAME   "AppleIISd.bin"

typedef enum
{
    STATE_0,     // pipe
    STATE_1,     // slash
    STATE_2,     // hyphen
    STATE_3,     // backslash

    STATE_LAST          // don't use
} STATE_CURSOR_T;

const char state_char[STATE_LAST] = { '|', '/', '-', '\\' };


boolean writeChip(const uint8* pSource, uint8* pDest, uint16 length);
void printStatus(uint8 percentage);

// Binary can't be larger than 2k
uint8 buffer[2048] = { 0 };

int main()
{
    int retval = 1;
    FILE* pFile;
    char slotNum;
    boolean erase = FALSE;
    uint16 fileSize = 0;

    APPLE_II_SD_T* pAIISD = (APPLE_II_SD_T*)SLOT_IO_START;
    uint8* pSlotRom = SLOT_ROM_START;
    uint8* pExtRom = EXT_ROM_START;

    videomode(VIDEOMODE_40COL);
    clrscr();
    cprintf("AppleIISd firmware flasher\r\n");
    cprintf("(c) 2019-2020 Florian Reitz\r\n\r\n");
    
    // ask for slot
    cursor(1);      // enable blinking cursor
    cprintf("Slot number (1-7): ");
    cscanf("%c", &slotNum);
    slotNum -= 0x30;
    cursor(0);      // disable blinking cursor

    if(slotNum == 0)
    {
        // erase device
        erase = TRUE;
        // ask for slot
        cursor(1);      // enable blinking cursor
        cprintf("Erase device in slot number (1-7): ");
        cscanf("%c", &slotNum);
        slotNum -= 0x30;
        cursor(0);      // disable blinking cursor
    }

    // check if slot is valid
    if((slotNum < 1) || (slotNum > 7))
    {
        cprintf("\r\nInvalid slot number!");
        cgetc();
        return 1;   // failure
    }

    ((uint8*)pAIISD) += slotNum << 4;
    pSlotRom += slotNum << 8;

    if(erase)
    {
        // buffer is already filled with 0
        fileSize = 2048;
    }
    else
    {
        // open file
        pFile = fopen(BIN_FILE_NAME, "rb");
        if(pFile)
        {
            // read buffer
            fileSize = fread(buffer, 1, sizeof(buffer), pFile);
            fclose(pFile);
            pFile = NULL;

            if(fileSize != 2048)
            {
                cprintf("\r\nWrong file size: %d\r\n", fileSize);
            }
        }
        else
        {
            cprintf("\r\nCan't open %s file\r\n", BIN_FILE_NAME);
            fileSize = 0;
        }
    }

    if(fileSize == 2048)
    {
        // enable write
        pAIISD->status.pgmen = 1;

        // clear 0xCFFF
        *CFFF = 0;

        // write to SLOTROM
        cprintf("\r\n\r\nFlashing SLOTROM: ");
        if(writeChip(buffer, pSlotRom, 256))
        {
            // write to EXTROM
            cprintf("\r\nFlashing EXTROM:  ");
            if(writeChip(buffer + 256, pExtRom, fileSize - 256))
            {
                cprintf("\r\n\r\nFlashing finished!\n");
                retval = 0;
            }
        }

        // disable write
        pAIISD->status.pgmen = 0;
    }

    cgetc();
    return retval;
}

boolean writeChip(const uint8* pSource, uint8* pDest, uint16 length)
{
    uint32 i;
    uint8 data = 0;
    uint8 readData;
    volatile uint8* pDestination = pDest;

    for(i=0; i<length; i++)
    {
        // set 0 if no source
        if(pSource)
        {
            data = pSource[i];
        }

        *pDestination = data;
        printStatus((i * 100u / length) + 1);

        // wait for write cycle
        do
        {
            readData = *pDestination;
        }
        while((readData & 0x80) != (data & 0x80));

        if(readData != data)
        {
            // verification not successful
            cprintf("\r\n\r\n!!! Flashing failed at %p !!!\r\n", pDestination);
            cprintf("Was 0x%02hhX, should be 0x%02hhX\r\n", readData, data);
            return FALSE;
        }

        pDestination++;
    }

    return TRUE;
}

void printStatus(uint8 percentage)
{
    static STATE_CURSOR_T state = STATE_0;
    uint8 wait = 0;
    uint8 x = wherex();
    char cState = (percentage < 100) ? state_char[state] : ' ';

    cprintf("% 3hhu%% %c", percentage, cState);
    gotox(x);

    state++;
    if(state == STATE_LAST)
    {
        state = STATE_0;
    }
}
