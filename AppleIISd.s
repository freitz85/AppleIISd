********************************
*
* Apple][Sd Firmware
* Version 0.5
*
* (c) Florian Reitz, 2017
*
* X register usually contains SLOT16
* Y register is used for counting or SLOT
*
********************************

               DAT

               XC               ; enable 65C02 code
               ORG   $C800      ; Expansion ROM

* Memory defines

SLOT16         =     $2B        ; $s0 -> slot * 16
WORK           =     $3C
SLOT           =     $3D        ; $0s
CMDLO          =     $40
CMDHI          =     $41

CURSLOT        =     $07F8      ; $Cs
DATA           =     $C080
CTRL           =     DATA+1
DIV            =     DATA+2
SS             =     DATA+3
R30            =     $0478
R31            =     $04F8
R32            =     $0578
R33            =     $05F8

* Constants

SSNONE         =     $0F
SS0            =     $0E
DUMMY          =     $FF


********************************
*
* Install SD card driver
*
********************************

* signature bytes

               LDX   #$20
               LDY   #$00
               LDX   #$03
               STX   WORK

               PAG
* find slot nr

               JSR   $FF58
               TSX
               LDA   $0100,X
               AND   #$0F
               STA   SLOT       ; $0s
               ORA   #$C0
               STA   CURSLOT    ; $Cs
               ASL   A
               ASL   A
               ASL   A
               ASL   A
               STA   SLOT16     ; $s0

               JSR   INIT
               BIT   $CFFF

*
* TODO: check for init error
*

* see if slot has a driver already

               LDX   $BF31      ; get devcnt
INSLP          LDA   $BF32,X    ; get a devnum
               AND   #$70       ; isolate slot
               CMP   SLOT16     ; slot?
               BEQ   INSOUT     ; yes, skip it
               DEX
               BPL   INSLP      ; keep up the search

* restore the devnum to the list

               LDX   $BF31      ; get devcnt again
               CPX   #$0D       device table full?
               BNE   INSLP2

               JMP   INSOUT      ; do something!

INSLP2         LDA   $BF32-1,X  ; move all entries down
               STA   $BF32,X    ; to make room at front
               DEX              ; for a new entry
               BNE   INSLP2
               LDA   #$04       ; ProFile type device
               ORA   SLOT16
               STA   $BF32      ; slot, drive 1 at top of list
               INC   $BF31      ; update devcnt

               PAG
* now insert the device driver vector

               LDA   SLOT
               TAX
               LDA   #<DRIVER
               STA   $BF10,X
               LDA   CURSLOT
               STA   $BF11,X

INSOUT         RTS


********************************
*
* Jump table
*
********************************

DRIVER         CLD
               JSR   $FF58      ; find slot nr
               TSX
               LDA   $0100,X
               AND   #$0F
               STA   SLOT       ; $0s
               ORA   #$C0
               STA   CURSLOT    ; $Cs
               ASL   A
               ASL   A
               ASL   A
               ASL   A
               STA   SLOT16     ; $s0
               TAX              ; X holds now SLOT16

               BIT   $CFFF
               LDA   $42        ; get command
               CMP   #$00
               BEQ   :STATUS
               CMP   #$01
               BEQ   :READ
               CMP   #$02
               BEQ   :WRITE
               CMP   #$03
               BEQ   :FORMAT
               SEC              ; unknown command
               LDA   #$01
               RTS

:STATUS        JMP   STATUS
:READ          JMP   READ
:WRITE         JMP   WRITE
:FORMAT        JMP   FORMAT

               PAG
* Signature bytes

               ORG   $C8FC
               DW    $FFFF      ; 65535 blocks
               DB    $47        ; Status bits
               DB    #<DRIVER   ; LSB of driver


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

               ORG   $C900

INIT           CLD
               LDX   SLOT16
               LDA   #$03       ; set SPI mode 3
               STA   CTRL,X
               LDA   #SSNONE
               STA   SS,X
               LDA   #7
               STA   DIV,X
               LDY   #10
               LDA   #DUMMY

:LOOP          STA   DATA,X
:WAIT          BIT   CTRL,X
               BPL   :WAIT
               DEY
               BNE   :LOOP      ; do 10 times
               LDA   #SS0       ; set CS low
               STA   SS,X

               LDA   #<CMD0     ; send CMD0
               STA   CMDLO
               LDA   #>CMD0
               STA   CMDHI
               JSR   CMD
               JSR   GETR1      ; get response
               CMP   #$01
               BNE   :ERROR1    ; error!

               LDA   #<CMD8     ; send CMD8
               STA   CMDLO
               LDA   #>CMD8
               STA   CMDHI
               JSR   CMD
               JSR   GETR3
               CMP   #$01
               BNE   :SDV1      ; may be SD Ver. 1

* check for $01aa match!
:SDV2          LDA   #<CMD55
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
               BEQ   :SDV2      ; wait for ready
               CMP   #$00
               BNE   :ERROR1    ;  error!
* send CMD58
* SD Ver. 2 initialized!
               JMP   :BLOCKSZ

:ERROR1        JMP   :IOERROR ; needed for far jump

:SDV1          LDA   #<CMD55
               STA   CMDLO
               LDA   #>CMD55
               STA   CMDHI
               JSR   CMD        ; ignore response
               LDA   #<ACMD410
               STA   CMDLO
               LDA   #>ACMD410
               STA   CMDHI
               JSR   CMD
               JSR   GETR1
               CMP   #$01
               BEQ   :SDV1      ; wait for ready
               CMP   #$00
               BNE   :MMC       ; may be MMC card
* SD Ver. 1 initialized!
               JMP   :BLOCKSZ

:MMC           LDA   #<CMD1
               STA   CMDLO
               LDA   #>CMD1
               STA   CMDHI
:LOOP1         JSR   CMD
               JSR   GETR1
               CMP   #$01
               BEQ   :LOOP1     ; wait for ready
               CMP   #$00
               BNE   :IOERROR   ; error!
* MMC Ver. 3 initialized!

:BLOCKSZ       LDA   #<CMD16
               STA   CMDLO
               LDA   #>CMD16
               STA   CMDHI
               JSR   CMD
               JSR   GETR1
               CMP   #$00
               BNE   :IOERROR   ; error!

:END           CLC              ; all ok
               LDX   #0
               BCC   :END1
:CDERROR       SEC
               LDX   #$28       ; no card error
               BCS   :END1
:IOERROR       SEC
               LDX   #$27       ; init error
:END1          LDA   #SSNONE    ; deselect card
               STA   SS,X
               LDA   #0         ; set div to 2
               STA   DIV,X
               TXA              ; retval in A
               RTS


********************************
*
* Send SD command
* Call with command in CMDHI and CMDLO
*
********************************

CMD            PHY
               LDY   #0
:LOOP          LDA   (CMDLO),Y
               STA   DATA,X
:WAIT          BIT   CTRL,X     ; TC is in N
               BPL   :WAIT
               INY
               CPY   #6
               BCC   :LOOP
               PLY
               RTS

               PAG
********************************
*
* Get R1
* R1 is in A
*
********************************

GETR1          LDA   #DUMMY
               STA   DATA,X
:WAIT          BIT   CTRL,X
               BPL   :WAIT
               LDA   DATA,X     ; get response
               STA   WORK       ; save R1
               AND   #$80
               BNE   GETR1      ; wait for MSB=0
               LDA   #DUMMY
               STA   DATA,X     ; send another dummy
               LDA   WORK        ; restore R1
               RTS


********************************
*
* Get R3
* R1 is in A
* R3 is in scratchpad ram
*
********************************

GETR3          JSR   GETR1      ; get R1 first
               PHA              ; save R1
               PHY              ; save Y
               LDA   #04        ; load counter
               STA   WORK
               LDY   SLOT
:LOOP          LDA   #DUMMY     ; send dummy
               STA   DATA,X
:WAIT          BIT   CTRL,X
               BPL   :WAIT
               LDA   DATA,X
               PHA
               DEC   WORK
               BNE   :LOOP      ; do 4 times
               PLA
               STA   R33,Y      ; save R3
               PLA
               STA   R32,Y
               PLA
               STA   R31,Y
               PLA
               STA   R30,X
               PLY              ; restore Y
               LDA   #DUMMY
               STA   DATA,X     ; send another dummy
               PLA              ; restore R1
               RTS


********************************
*
* Status request
* $43    Unt number DSSS000
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

STATUS         CLC              ; no error
               LDA   #0
               LDX   #$FF       ; 32 MB partition
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

READ           LDA   #SS0       ; enable /CS
               STA   SS,X

               PHY              ; save Y
               LDY   SLOT
               LDA   $46        ; store block num
               STA   R33,Y      ; in R30-R33
               LDA   $47
               STA   R32,Y
               LDA   #0
               STA   R31,Y
               STA   R30,Y

               PHX
               PHY
               LDY   #9
               LDX   SLOT       ; ASL can't be done with Y
:LOOP          ASL   R33,X      ; mul block num
               ROL   R32,X      ; by 512 to get
               ROL   R31,X      ; real address
               ROL   R30,X
               DEY
               BNE   :LOOP
               PLY
               PLX

               LDA   #$51       ; send CMD17
               STA   DATA,X
:WAIT          BIT   CTRL,X
               BPL   :WAIT
:ARG           LDA   R30,Y      ; get arg from R30 on
               STA   DATA,X
:WAIT1         BIT   CTRL,X
               BPL   :WAIT1
               LDA   R31,Y
               STA   DATA,X
:WAIT11        BIT   CTRL,X
               BPL   :WAIT11
               LDA   R32,Y
               STA   DATA,X
:WAIT12        BIT   CTRL,X
               BPL   :WAIT12
               LDA   R33,Y
               STA   DATA,X
:WAIT13        BIT   CTRL,X
               BPL   :WAIT13
               LDA   #DUMMY
               STA   DATA,X     ; dummy crc
:WAIT2         BIT   CTRL,X
               BPL   :WAIT2
:GETR1         LDA   #DUMMY
               STA   DATA,X     ; get R1
:WAIT3         BIT   CTRL,X
               BPL   :WAIT3
               LDA   DATA,X     ; get response
*
* TODO: check for error!
*
               CMP   #$FE
               BNE   :GETR1     ; wait for $FE

               PHY
               LDY   #2         ; read data from card
:LOOPY         STZ   WORK
:LOOPW         LDA   #DUMMY
               STA   DATA,X
:WAIT4         BIT   CTRL,X
               BPL   :WAIT4
               LDA   DATA,X
               STA   ($44)
               INC   $44
               BNE   :INW
               INC   $45        ; inc msb on page boundary
:INW           INC   WORK
               BNE   :LOOPW
               DEY
               BNE   :LOOPY
               PLY

:OK            JSR   GETR3      ; read 2 bytes crc
               LDA   #SSNONE
               STA   SS,X       ; disable /CS
               CLC              ; no error
               LDA   #$00
               PLY              ; restore Y
               RTS

:ERROR         LDA   #SSNONE
               STA   SS,X       ; disable /CS
               SEC              ; an error occured
               LDA   #$27
               PLY              ; restore Y
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
*   $27   - Bad block number
*   $28   - No card inserted
*
********************************

* TODO: check for card detect and write protect!

WRITE          LDA   #SS0       ; enable /CS
               STA   SS,X

               PHY
               LDY   SLOT
               LDA   $46        ; store block num
               STA   R33,Y
               LDA   $47
               STA   R32,Y
               LDA   #0
               STA   R31,Y
               STA   R30,Y

               PHX
               PHY
               LDY   #9
               LDX   SLOT       ; ASL can't be done with Y
:LOOP          ASL   R33,X      ; mul block num
               ROL   R32,X      ; by 512 to get
               ROL   R31,X      ; real address
               ROL   R30,X
               DEY
               BNE   :LOOP
               PLY
               PLX

               LDA   #$58       ; send CMD24
               STA   DATA,X
:WAIT          BIT   CTRL,X
               BPL   :WAIT
:ARG           LDA   R30,Y      ; get arg from R30 on
               STA   DATA,X
:WAIT1         BIT   CTRL,X
               BPL   :WAIT1
               LDA   R31,Y
               STA   DATA,X
:WAIT11        BIT   CTRL,X
               BPL   :WAIT11
               LDA   R32,Y
               STA   DATA,X
:WAIT12        BIT   CTRL,X
               BPL   :WAIT12
               LDA   R33,Y
               STA   DATA,X
:WAIT13        BIT   CTRL,X
               BPL   :WAIT13
               LDA   #DUMMY
               STA   DATA,X     ; dummy crc
:WAIT2         BIT   CTRL,X
               BPL   :WAIT2
:GETR1         LDA   #DUMMY
               STA   DATA,X     ; get R1
:WAIT3         BIT   CTRL,X
               BPL   :WAIT3
               LDA   DATA,X     ; get response
*
* TODO: check for error!
*
               CMP   #$FE
               BNE   :GETR1     ; wait for $FE

               PHY
               LDY   #2         ; send data to card
:LOOPY         STZ   WORK
:LOOPW         LDA   ($44)
               STA   DATA,X
:WAIT4         BIT   CTRL,X
               BPL   :WAIT4
               INC   $44
               BNE   :INW
               INC   $45        ; inc msb on page boundary
:INW           INC   WORK
               BNE   :LOOPW
               DEY
               BNE   :LOOPY

               LDY   #2         ; send 2 dummy crc bytes
:CRC           STA   DATA,X
:WAIT5         BIT   CTRL,X
               BPL   :WAIT5
               DEY
               BNE   :CRC
               PLY

:OK            LDA   #SSNONE    ; disable /CS
               STA   SS,X
               CLC              ; no error
               LDA   #0
               PLY
               RTS


********************************
*
* Format
* not supported!
*
********************************

FORMAT         SEC
               LDA   #$01       ; invalid command
               RTS



CMD0           HEX   400000
               HEX   000095
CMD1           HEX   410000
               HEX   0000F9
CMD8           HEX   480000
               HEX   01AA87
CMD16          HEX   500000
               HEX   0200FF
CMD55          HEX   770000
               HEX   000065
ACMD4140       HEX   694000
               HEX   000077
ACMD410        HEX   690000
               HEX   0000FF
               PAG
