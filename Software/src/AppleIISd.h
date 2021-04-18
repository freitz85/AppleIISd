#ifndef APPLE_II_SD_H
#define APPLE_II_SD_H

typedef unsigned char   uint8;
typedef unsigned short  uint16;
typedef unsigned long   uint32;
typedef unsigned char   boolean;

#ifndef TRUE
#define TRUE    1
#endif
#ifndef FALSE
#define FALSE   0
#endif

#define SLOT_IO_START   (volatile uint8*)0xC080
#define SLOT_ROM_START  (volatile uint8*)0xC000
#define EXT_ROM_START   (volatile uint8*)0xC800

#define CFFF            (volatile uint8*)0xCFFF

typedef volatile struct
{
    // data register 
    // +0
    uint8 data;

    // status register
    // +1
    union
    {
        struct
        {
            unsigned pgmen : 1;
            unsigned : 1;
            unsigned ece : 1;
            unsigned : 1;
            unsigned frx : 1;
            const unsigned bsy : 1;
            unsigned : 1;
            const unsigned tc : 1;
        };

        uint8 status;
    } status;

    // clock divisor register, unused
    // +2
    uint8 clkDiv;

    // slave select and card state register
    // +3
    union
    {
        struct
        {
            unsigned slaveSel : 1;
            unsigned : 3;
            unsigned sdhc : 1;
            const unsigned wp : 1;
            const unsigned card : 1;
            unsigned inited : 1;
        };

        uint8 ss_card;
    } ss_card;
} APPLE_II_SD_T;

#endif
