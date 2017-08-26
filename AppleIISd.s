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
INITED      =     $0678

* Constants

SSNONE      =     $0F
SS0         =     $0E
DUMMY       =     $FF
FRXEN       =     $17
FRXDIS      =     $07


* signature bytes

            LDX   #$20
            LDY   #$00
            LDX   #$03
            STX   WORK

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
            AND   #$0F
            STA   SLOT        ; $0s
            ORA   #$C0
            STA   CURSLOT     ; $Cs
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            STA   SLOT16      ; $s0
            FIN
            TAX               ; X holds now SLOT16

            BIT   $CFFF
            JSR   INIT

*
* TODO: check for init error
*

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

BOOT        LDA   #$01
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
            AND   #$0F
            STA   SLOT        ; $0s
            ORA   #$C0
            STA   CURSLOT     ; $Cs
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            STA   SLOT16      ; $s0
            FIN
            TAX               ; X holds now SLOT16

            BIT   $CFFF
            LDY   SLOT
            LDA   INITED,Y    ; check for init
            CMP   #$01
            BCC   :INIT
:CMD        LDA   $42         ; get command
            CMP   #$00
            BEQ   :STATUS
            CMP   #$01
            BEQ   :READ
            CMP   #$02
            BEQ   :WRITE
            CMP   #$03
            BEQ   :FORMAT
            SEC               ; unknown command
            LDA   #$01
            RTS

:STATUS     JMP   STATUS
:READ       JMP   READ
:WRITE      JMP   WRITE
:FORMAT     JMP   FORMAT
:INIT       JSR   INIT
            BRA   :CMD


* Signature bytes

            DS    \           ; fill with zeroes
            DS    -4          ; locate to $xxFC
            DW    $FFFF       ; 65535 blocks
            DB    $47         ; Status bits
            DB    #<DRIVER    ; LSB of driver


********************************
*
* Initialize SD card
*
* C Clear - No error
*   Set   - Error
* A $00   - No error
*   $27   - I/O error - Init failed
*   $28   - No card inserted
*
********************************

INIT        CLD
            LDA   #$03        ; set SPI mode 3
            STA   CTRL,X
            LDA   #SSNONE
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
            LDA   #SS0        ; set CS low
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

:END        LDY   SLOT
            LDA   #$01
            STA   INITED,Y    ; initialized
            CLC               ; all ok
            LDY   #0
            BCC   :END1
:CDERROR    SEC
            LDY   #$28        ; no card error
            BCS   :END1
:IOERROR    SEC
            LDY   #$27        ; init error
:END1       LDA   #SSNONE     ; deselect card
            STA   SS,X
            LDA   #7          ; enable 7MHz
            STA   CTRL,X
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

            LDY   #9          ; ASL can't be used with Y
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
* Status request
* $43    Unit number DSSS000
* $44-45 Unused
* $46-47 Unused
*
* C Clear - No error
*   Set   - Error
* A $00   - No error
*   $27   - I/O error
*   $28   - No card inserted / no init
*   $2B   - Card write protected
* x       - Blocks avail (low byte)
* y       - Blocks avail (high byte)
*
********************************

STATUS      CLC               ; no error
            LDA   #0
            LDX   #$FF        ; 32 MB partition
            LDY   #$FF
            RTS

* TODO: check for card detect and write protect!


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

* TODO: check for card detect!

READ        JSR   BLOCK       ; calc block address

            LDA   #SS0        ; enable /CS
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
            LDA   #FRXEN      ; enable FRX
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

            LDA   #FRXDIS     ; disable FRX
            STA   CTRL,X

:CRC        LDA   #DUMMY      ; first crc byte has
            STA   DATA,X      ; already been read

            LDA   #SSNONE
            STA   SS,X        ; disable /CS
            CLC               ; no error
            LDA   #$00
            RTS

:ERROR      LDA   #SSNONE
            STA   SS,X        ; disable /CS
            SEC               ; an error occured
            LDA   #$27
            RTS


********************************
*
* Write 512 byte block
* $43    Unit number DSSS000
* $44-45 Address (LO/HI) of buffer
* $46-47 Block number (LO/HI)
*
* C Clear - No error
*   Set   - Error
* A $00   - No error
*   $27   - I/O error or bad block number
*   $28   - No card inserted
*   $2B   - Card write protected
*
********************************

* TODO: check for card detect and write protect!

WRITE       JSR   BLOCK       ; calc block address

            LDA   #SS0        ; enable /CS
            STA   SS,X
            LDA   #$58        ; send CMD24
            JSR   COMMAND     ; send command

            CMP   #0          ; check for error
            BNE   :ERROR

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
            BNE   :ERROR      ; check for write error

:WAIT6      LDA   #DUMMY
            STA   DATA,X      ; wait for write cycle
            LDA   DATA,X      ; to complete
            CMP   #$00
            BEQ   :WAIT6

            LDA   #SSNONE     ; disable /CS
            STA   SS,X
            CLC               ; no error
            LDA   #0
            RTS

:ERROR      LDA   #DUMMY
            STA   DATA,X      ; wait for write cycle
            LDA   DATA,X      ; to complete
            CMP   #$00
            BEQ   :ERROR

            LDA   #SSNONE
            STA   SS,X        ; disable /CS
            SEC               ; an error occured
            LDA   #$27
            RTS


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

