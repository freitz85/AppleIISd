********************************
*
* Apple][Sd Firmware
* Version 0.6
*
* (c) Florian Reitz, 2017
*
* X register usually contains SLOT16
* Y register is used for counting or SLOT
*
********************************

            DAT

            XC                ; enable 65C02 code
DEBUG       =     0
            DO    DEBUG
            ORG   $8000
            ELSE
            ORG   $C800       ; Expansion ROM
            FIN

* Memory defines

SLOT16      =     $2B         ; $s0 -> slot * 16
WORK        =     $3C
SLOT        =     $3D         ; $0s
CMDLO       =     $40
CMDHI       =     $41

CURSLOT     =     $07F8       ; $Cs
DATA        =     $C080
CTRL        =     DATA+1
DIV         =     DATA+2
SS          =     DATA+3
R30         =     $0478
R31         =     $04F8
R32         =     $0578
R33         =     $05F8

* Constants

DUMMY       =     $FF
FRX         =     $10         ; CTRL register
ECE         =     $04
SS0         =     $01         ; SS register
WP          =     $20
CD          =     $40
INITED      =     $80


* signature bytes

            LDX   #$20
            LDY   #$00
            LDX   #$03
            LDY   #$FF        ; neither 5.25 nor Smartport

* find slot nr

            DO    DEBUG
            LDA   #$04
            STA   SLOT
            LDA   #$C4
            STA   CURSLOT
            LDA   #$40
            STA   SLOT16

            ELSE
            JSR   $FF58
            TSX
            LDA   $0100,X
            STA   CURSLOT     ; $Cs
            AND   #$0F
            STA   SLOT        ; $0s
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            STA   SLOT16      ; $s0
            FIN

            TAX               ; X holds now SLOT16
            BIT   $CFFF
            JSR   CARDDET
            BCC   :INIT
            LDA   #$27        ; no card inserted
            BRK

:INIT       JSR   INIT


********************************
*
* Install SD card driver
*
********************************

            DO    DEBUG

* see if slot has a driver already

            LDX   $BF31       ; get devcnt
INSTALL     LDA   $BF32,X     ; get a devnum
            AND   #$70        ; isolate slot
            CMP   SLOT16      ; slot?
            BEQ   :INSOUT     ; yes, skip it
            DEX
            BPL   INSTALL     ; keep up the search

* restore the devnum to the list

            LDX   $BF31       ; get devcnt again
            CPX   #$0D        ; device table full?
            BNE   :INST2

            JSR   $FF3A       ; bell
            JMP   :INSOUT     ; do something!

:INST2      LDA   $BF32-1,X   ; move all entries down
            STA   $BF32,X     ; to make room at front
            DEX               ; for a new entry
            BNE   :INST2
            LDA   #$04        ; ProFile type device
            ORA   SLOT16
            STA   $BF32       ; slot, drive 1 at top of list
            INC   $BF31       ; update devcnt

* now insert the device driver vector

            LDA   SLOT
            ASL
            TAX
            LDA   #<DRIVER
            STA   $BF10,X     ; write to driver table
            LDA   #>DRIVER
            STA   $BF11,X
:INSOUT     RTS


********************************
*
* Boot from SD card
*
********************************

            ELSE

BOOT        CMP   #0          ; check for error
            BEQ   :BOOT1
            BRK

:BOOT1      LDA   #$01
            STA   $42         ; load command
            LDA   SLOT16
            TAX
            STA   $43         ; slot number
            STZ   $44         ; buffer lo
            LDA   #$08
            STA   $45         ; buffer hi
            STZ   $46         ; block lo
            STZ   $47         ; block hi
            BIT   $CFFF
            JSR   READ        ; call driver
            JMP   $801        ; goto bootloader

            FIN


********************************
*
* Jump table
*
********************************

DRIVER      CLD

            DO    DEBUG
            LDA   #$04
            STA   SLOT
            LDA   #$C4
            STA   CURSLOT
            LDA   #$40
            STA   SLOT16

            ELSE
            JSR   $FF58       ; find slot nr
            TSX
            LDA   $0100,X
            STA   CURSLOT     ; $Cs
            AND   #$0F
            STA   SLOT        ; $0s
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            STA   SLOT16      ; $s0
            FIN

            TAX               ; X holds now SLOT16
            BIT   $CFFF
            JSR   CARDDET
            BCC   :INITED
            LDA   #$27        ; no card inserted
            BRA   :DONE

:INITED     LDA   #INITED     ; check for init
            BIT   SS,X
            BEQ   :INIT

:CMD        LDA   $42         ; get command
            CMP   #0
            BEQ   :STATUS
            CMP   #1
            BEQ   :READ
            CMP   #2
            BEQ   :WRITE
            CMP   #3
            BEQ   :FORMAT
            LDA   #1          ; unknown command

:DONE       SEC
            RTS

:STATUS     JMP   STATUS
:READ       JMP   READ
:WRITE      JMP   WRITE
:FORMAT     JMP   FORMAT
:INIT       JSR   INIT
            BCS   :DONE       ; init failure
            BRA   :CMD


* Signature bytes

            DS    \           ; fill with zeroes
            DS    -4          ; locate to $xxFC
            DW    $FFFF       ; 65535 blocks
            DB    $17         ; Status bits
            DB    #<DRIVER    ; LSB of driver


********************************
*
* Initialize SD card
*
* C Clear - No error
*   Set   - Error
* A $00   - No error
*   $27   - I/O error - Init failed
*   $2F   - No card inserted
*
********************************

INIT        CLD
            LDA   #$03        ; set SPI mode 3
            STA   CTRL,X
            LDA   SS,X
            ORA   #SS0        ; set CS high
            STA   SS,X
            LDA   #7
            STA   DIV,X
            LDY   #10
            LDA   #DUMMY

:LOOP       STA   DATA,X
:WAIT       BIT   CTRL,X
            BPL   :WAIT
            DEY
            BNE   :LOOP       ; do 10 times
            LDA   SS,X
            AND   #$FF!SS0    ; set CS low
            STA   SS,X

            LDA   #<CMD0      ; send CMD0
            STA   CMDLO
            LDA   #>CMD0
            STA   CMDHI
            JSR   CMD
            JSR   GETR1       ; get response
            CMP   #$01
            BNE   :ERROR1     ; error!

            LDA   #<CMD8      ; send CMD8
            STA   CMDLO
            LDA   #>CMD8
            STA   CMDHI
            JSR   CMD
            JSR   GETR3
            CMP   #$01
            BNE   :SDV1       ; may be SD Ver. 1

* check for $01aa match!
:SDV2       LDA   #<CMD55
            STA   CMDLO
            LDA   #>CMD55
            STA   CMDHI
            JSR   CMD
            JSR   GETR1
            LDA   #<ACMD4140
            STA   CMDLO
            LDA   #>ACMD4140
            STA   CMDHI
            JSR   CMD
            JSR   GETR1
            CMP   #$01
            BEQ   :SDV2       ; wait for ready
            CMP   #$00
            BNE   :ERROR1     ;  error!
* send CMD58
* SD Ver. 2 initialized!
            JMP   :BLOCKSZ

:ERROR1     JMP   :IOERROR    ; needed for far jump

:SDV1       LDA   #<CMD55
            STA   CMDLO
            LDA   #>CMD55
            STA   CMDHI
            JSR   CMD         ; ignore response
            LDA   #<ACMD410
            STA   CMDLO
            LDA   #>ACMD410
            STA   CMDHI
            JSR   CMD
            JSR   GETR1
            CMP   #$01
            BEQ   :SDV1       ; wait for ready
            CMP   #$00
            BNE   :MMC        ; may be MMC card
* SD Ver. 1 initialized!
            JMP   :BLOCKSZ

:MMC        LDA   #<CMD1
            STA   CMDLO
            LDA   #>CMD1
            STA   CMDHI
:LOOP1      JSR   CMD
            JSR   GETR1
            CMP   #$01
            BEQ   :LOOP1      ; wait for ready
            CMP   #$00
            BNE   :IOERROR    ; error!
* MMC Ver. 3 initialized!

:BLOCKSZ    LDA   #<CMD16
            STA   CMDLO
            LDA   #>CMD16
            STA   CMDHI
            JSR   CMD
            JSR   GETR1
            CMP   #$00
            BNE   :IOERROR    ; error!

:END        LDA   SS,X
            ORA   #INITED     ; initialized
            STA   SS,X
            LDA   CTRL,X
            ORA   #ECE        ; enable 7MHz
            STA   CTRL,X
            CLC               ; all ok
            LDY   #0
            BCC   :END1
:CDERROR    SEC
            LDY   #$2F        ; no card error
            BCS   :END1
:IOERROR    SEC
            LDY   #$27        ; init error
:END1       LDA   SS,X        ; set CS high
            ORA   #SS0
            STA   SS,X
            LDA   #0          ; set div to 2
            STA   DIV,X
            TYA               ; retval in A
            RTS


********************************
*
* Send SD command
* Call with command in CMDHI and CMDLO
*
********************************

CMD         PHY
            LDY   #0
:LOOP       LDA   (CMDLO),Y
            STA   DATA,X
:WAIT       BIT   CTRL,X      ; TC is in N
            BPL   :WAIT
            INY
            CPY   #6
            BCC   :LOOP
            PLY
            RTS


********************************
*
* Get R1
* R1 is in A
*
********************************

GETR1       LDA   #DUMMY
            STA   DATA,X
:WAIT       BIT   CTRL,X
            BPL   :WAIT
            LDA   DATA,X      ; get response
            STA   WORK        ; save R1
            AND   #$80
            BNE   GETR1       ; wait for MSB=0
            LDA   #DUMMY
            STA   DATA,X      ; send another dummy
            LDA   WORK        ; restore R1
            RTS


********************************
*
* Get R3
* R1 is in A
* R3 is in scratchpad ram
*
********************************

GETR3       JSR   GETR1       ; get R1 first
            PHA               ; save R1
            PHY               ; save Y
            LDY   #04         ; load counter
:LOOP       LDA   #DUMMY      ; send dummy
            STA   DATA,X
:WAIT       BIT   CTRL,X
            BPL   :WAIT
            LDA   DATA,X
            PHA
            DEY
            BNE   :LOOP       ; do 4 times
            LDY   SLOT
            PLA
            STA   R33,Y       ; save R3
            PLA
            STA   R32,Y
            PLA
            STA   R31,Y
            PLA
            STA   R30,Y
            PLY               ; restore Y
            LDA   #DUMMY
            STA   DATA,X      ; send another dummy
            PLA               ; restore R1
            RTS


********************************
*
* Calculate block address
* Unit number is in $43 DSSS0000
* Block no is in $46-47
* Address is in R30-R33
*
********************************

BLOCK       PHX               ; save X
            PHY               ; save Y
            LDX   SLOT
            LDA   $46         ; store block num
            STA   R33,X       ; in R30-R33
            LDA   $47
            STA   R32,X
            LDA   #0
            STA   R31,X
            STA   R30,X

            LDA   #$80        ; drive number
            BIT   $43
            BEQ   :SHIFT      ; D1
            LDA   #1          ; D2
            STA   R31,X

:SHIFT      LDY   #9          ; ASL can't be used with Y
:LOOP       ASL   R33,X       ; mul block num
            ROL   R32,X       ; by 512 to get
            ROL   R31,X       ; real address
            ROL   R30,X
            DEY
            BNE   :LOOP
            PLY               ; restore Y
            PLX               ; restore X
            RTS


********************************
*
* Send SD command
* Cmd is in A
*
********************************

COMMAND     PHY               ; save Y
            LDY   SLOT
            STA   DATA,X      ; send command
            LDA   R30,Y       ; get arg from R30 on
            STA   DATA,X
            LDA   R31,Y
            STA   DATA,X
            LDA   R32,Y
            STA   DATA,X
            LDA   R33,Y
            STA   DATA,X
            LDA   #DUMMY
            STA   DATA,X      ; dummy crc
            JSR   GETR1
            PLY               ; restore Y
            RTS


********************************
*
* Check for card detect
*
* C Clear - card in slot
*   Set   - no card in slot
*
********************************

CARDDET     PHA
            LDA   #CD         ; 0: card in
            BIT   SS,X        ; 1: card out
            CLC
            BEQ   :DONE       ; card is in
            SEC               ; card is out
:DONE       PLA
            RTS


********************************
*
* Check for write protect
*
* C Clear - card not protected
*   Set   - card write protected
*
********************************

WRPROT      PHA
            LDA   #WP         ; 0: write enabled
            BIT   SS,X        ; 1: write disabled
            CLC
            BEQ   :DONE
            SEC
:DONE       PLA
            RTS


********************************
*
* Status request
* $43    Unit number DSSS000
* $44-45 Unused
* $46-47 Unused
*
* C Clear - No error
*   Set   - Error
* A $00   - No error
*   $2B   - Card write protected
*   $2F   - No card inserted
* X       - Blocks avail (low byte)
* Y       - Blocks avail (high byte)
*
********************************

STATUS      LDA   #0          ; no error
            LDX   #$FF        ; 32 MB partition
            LDY   #$FF

            JSR   CARDDET
            BCC   :WRPROT
            LDA   #$2F        ; no card inserted
            BRA   :DONE

:WRPROT     JSR   WRPROT
            BCC   :DONE
            LDA   #$2B        ; card write protected

:DONE       RTS


********************************
*
* Read 512 byte block
* $43    Unit number DSSS0000
* $44-45 Address (LO/HI) of buffer
* $46-47 Block number (LO/HI)
*
* C Clear - No error
*   Set   - Error
* A $00   - No error
*   $27   - Bad block number
*   $28   - No card inserted
*
********************************

READ        JSR   CARDDET
            BCS   :ERROR      ; no card inserted

            JSR   BLOCK       ; calc block address

            LDA   SS,X        ; enable /CS
            AND   #$FF!SS0
            STA   SS,X
            LDA   #$51        ; send CMD17
            JSR   COMMAND     ; send command

            CMP   #0          ; check for error
            BNE   :ERROR

:GETTOK     LDA   #DUMMY      ; get data token
            STA   DATA,X
            LDA   DATA,X      ; get response
            CMP   #$FE
            BNE   :GETTOK     ; wait for $FE

            LDY   #2          ; read data from card
            LDA   CTRL,X      ; enable FRX
            ORA   #FRX
            STA   CTRL,X
            LDA   #DUMMY
            STA   DATA,X
:LOOPY      STZ   WORK
:LOOPW      LDA   DATA,X
            STA   ($44)
            INC   $44
            BNE   :INW
            INC   $45         ; inc msb on page boundary
:INW        INC   WORK
            BNE   :LOOPW
            DEY
            BNE   :LOOPY

:CRC        LDA   DATA,X      ; read two bytes crc
            LDA   DATA,X      ; and ignore
            LDA   DATA,X      ; read a dummy byte

            LDA   CTRL,X      ; disable FRX
            AND   #$FF!FRX
            STA   CTRL,X
            CLC               ; no error
            LDA   #0

:DONE       PHP
            PHA
            LDA   SS,X
            ORA   #SS0
            STA   SS,X        ; disable /CS
            PLA
            PLP
            RTS

:ERROR      SEC               ; an error occured
            LDA   #$27
            BRA   :DONE


********************************
*
* Write 512 byte block
* $43    Unit number DSSS0000
* $44-45 Address (LO/HI) of buffer
* $46-47 Block number (LO/HI)
*
* C Clear - No error
*   Set   - Error
* A $00   - No error
*   $27   - I/O error or bad block number
*   $2B   - Card write protected
*
********************************

WRITE       JSR   CARDDET
            BCS   :IOERROR    ; no card inserted

            JSR   WRPROT
            BCS   :WPERROR    ; card write protected

            JSR   BLOCK       ; calc block address

            LDA   SS,X        ; enable /CS
            AND   #$FF!SS0
            STA   SS,X
            LDA   #$58        ; send CMD24
            JSR   COMMAND     ; send command

            CMP   #0          ; check for error
            BNE   :IOERROR

            LDA   #DUMMY
            STA   DATA,X      ; send dummy
            LDA   #$FE
            STA   DATA,X      ; send data token

            LDY   #2          ; send data to card
:LOOPY      STZ   WORK
:LOOPW      LDA   ($44)
            STA   DATA,X
            INC   $44
            BNE   :INW
            INC   $45         ; inc msb on page boundary
:INW        INC   WORK
            BNE   :LOOPW
            DEY
            BNE   :LOOPY

:CRC        STA   DATA,X      ; send 2 dummy crc bytes
            STA   DATA,X

            STA   DATA,X      ; get data response
            LDA   DATA,X
            AND   #$1F
            CMP   #$05
            BNE   :IOERROR    ; check for write error
            CLC               ; no error
            LDA   #0

:DONE       PHP
            PHA
:WAIT       LDA   #DUMMY
            STA   DATA,X      ; wait for write cycle
            LDA   DATA,X      ; to complete
            CMP   #$00
            BEQ   :WAIT

            LDA   SS,X        ; disable /CS
            ORA   #SS0
            STA   SS,X
            PLA
            PLP
            RTS

:IOERROR    SEC               ; an error occured
            LDA   #$27
            BRA   :DONE

:WPERROR    SEC
            LDA   #$2B
            BRA   :DONE



********************************
*
* Format
* not supported!
*
********************************

FORMAT      SEC
            LDA   #$01        ; invalid command
            RTS


CMD0        HEX   400000
            HEX   000095
CMD1        HEX   410000
            HEX   0000F9
CMD8        HEX   480000
            HEX   01AA87
CMD16       HEX   500000
            HEX   0200FF
CMD55       HEX   770000
            HEX   000065
ACMD4140    HEX   694000
            HEX   000077
ACMD410     HEX   690000
            HEX   0000FF

