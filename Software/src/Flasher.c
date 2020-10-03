#include "AppleIISd.h"

#include <assert.h>
#include <stdio.h>
#include <errno.h>
#include <conio.h>
#include <string.h>
#include <apple2enh.h>

// Binary can't be larger than 2k
#define BUFFER_SIZE     2048
#define BIN_FILE_NAME   "AppleIISd.bin"

typedef enum
{
    STATE_0,     // pipe
    STATE_1,     // slash
    STATE_2,     // hyphen
    STATE_3,     // backslash

    STATE_LAST   // don't use
} STATE_CURSOR_T;

const char state_char[STATE_LAST] = { '|', '/', '-', '\\' };
static uint8 buffer[BUFFER_SIZE];

static void writeChip(const uint8* pSource, volatile uint8* pDest, uint16 length);
static boolean verifyChip(const uint8* pSource, volatile uint8* pDest, uint16 length);
static void printStatus(uint8 percentage);

int main()
{
    int retval = 1;
    FILE* pFile;
    char slotNum;
    boolean erase = FALSE;
    uint16 fileSize = 0;

    APPLE_II_SD_T* pAIISD = (APPLE_II_SD_T*)SLOT_IO_START;
    volatile uint8* pSlotRom = SLOT_ROM_START;

    videomode(VIDEOMODE_40COL);
    clrscr();
    cprintf("AppleIISd firmware flasher V1.2\r\n");
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
        fileSize = BUFFER_SIZE;
        memset(buffer, 0, sizeof(buffer));
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

            if(fileSize != BUFFER_SIZE)
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

    if(fileSize == BUFFER_SIZE)
    {
        // enable write
        pAIISD->status.pgmen = 1;

        // clear 0xCFFF
        *CFFF = 0;

        // write to SLOTROM
        cprintf("\r\n\r\nFlashing SLOTROM: ");
        writeChip(buffer, pSlotRom, 256);
        cprintf("\r\nVerifying SLOTROM: ");
        if(verifyChip(buffer, pSlotRom, 256))
        {
            // write to EXTROM
            cprintf("\r\n\r\nFlashing EXTROM:  ");
            writeChip(buffer + 256, EXT_ROM_START, fileSize - 256);
            cprintf("\r\nVerifying EXTROM:  ");
            if(verifyChip(buffer + 256, EXT_ROM_START, fileSize - 256))
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

static void writeChip(const uint8* pSource, volatile uint8* pDest, uint16 length)
{
    uint32 i;
    volatile uint8 readData;

    for(i=0; i<length; i++)
    {
        pDest[i] = pSource[i];
        printStatus((i * 100u / length) + 1);

        // wait for write cycle
        do
        {
            readData = pDest[i];
        }
        while((readData & 0x80) != (pSource[i] & 0x80));
    }
}

static boolean verifyChip(const uint8* pSource, volatile uint8* pDest, uint16 length)
{
    uint32 i;

    for(i=0; i<length; i++)
    {
        printStatus((i * 100u / length) + 1);

        if(pDest[i] != pSource[i])
        {
            // verification not successful
            cprintf("\r\n\r\n!!! Verification failed at %p !!!\r\n", &pDest[i]);
            cprintf("Was 0x%02hhX, should be 0x%02hhX\r\n", pDest[i], pSource[i]);
            return FALSE;
        }
    }

    return TRUE;
}

static void printStatus(uint8 percentage)
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
