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
    int retval = 0;
    FILE* pFile;
    char slotNum;

    APPLE_II_SD_T* pAIISD = (APPLE_II_SD_T*)SLOT_IO_START;
    uint8* pSlotRom = SLOT_ROM_START;
    uint8* pExtRom = EXT_ROM_START;

    videomode(VIDEOMODE_80COL);
    clrscr();
    cprintf("AppleIISd firmware flasher\r\n");
    cprintf("(c) 2019 Florian Reitz\r\n\r\n");
    
    // ask for slot
    cursor(1);      // enable blinking cursor
    cprintf("Slot number (1-7): ");
    cscanf("%c", &slotNum);
    slotNum -= 0x30;
    cursor(0);      // disable blinking cursor

    // check if slot is valid
    if((slotNum < 1) || (slotNum > 7))
    {
        cprintf("\r\nInvalid slot number!");
        return 1;   // failure
    }

    ((uint8*)pAIISD) += slotNum << 4;
    pSlotRom += slotNum << 8;

    // open file
    pFile = fopen(BIN_FILE_NAME, "rb");
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
            cprintf("\r\n\r\nFlashing SLOTROM: ");
            if(writeChip(buffer, pSlotRom, 256))
            {
                // write to EXTROM
                cprintf("\r\nFlashing EXTROM:  ");
                if(writeChip(buffer + 256, pExtRom, fileSize - 256))
                {
                    cprintf("\r\n\r\nFlashing finished!\n");
                }
                else
                {
                    retval = 1;
                }
            }
            else
            {
                retval = 1;
            }

            // disable write
            pAIISD->status.pgmen = 0;
        }
        else
        {
            cprintf("\r\nWrong file size: %d\r\n", fileSize);
            retval = 1;
        }
    }
    else
    {
        cprintf("\r\nCan't open %s file\r\n", BIN_FILE_NAME);
        retval = 1;
    }

    return retval;
}

boolean writeChip(const uint8* pSource, uint8* pDest, uint16 length)
{
    uint32 i;
    uint8 data = 0;

    for(i=0; i<length; i++)
    {
        // set 0 if no source
        if(pSource)
        {
            data = pSource[i];
        }

        *pDest = data;
        if(*pDest != data)
        {
            // verification not successful
            cprintf("\r\n\r\n!!! Flashing failed at %p !!!\r\n", pDest);
            return FALSE;
        }

        printStatus((i * 100u / length) + 1);
        pDest++;
    }

    return TRUE;
}

void printStatus(uint8 percentage)
{
    static STATE_CURSOR_T state = STATE_0;
    uint8 wait = 0;
    uint8 x = wherex();
    char cState = (percentage < 100) ? state_char[state] : ' ';

    cprintf("% 2hhu%% %c", percentage, cState);
    gotox(x);

    while(wait < 0xff)
    {
        wait++;
    }

    state++;
    if(state == STATE_LAST)
    {
        state = STATE_0;
    }
}
