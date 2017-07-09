********************************
*
* Initialize SD card
*
********************************

               XC
               ORG   $C800

SLOT16         =     $2B        ; s0 -> slot * 16
CURSLOT        =     $07F8      ; Cs
DATA           =     $C0C0      ; slot 4
CTRL           =     DATA+1
DIV            =     DATA+2
SS             =     DATA+3
R30            =     $0478
R31            =     $04F8
R32            =     $0578
R33            =     $05F8
CMDLO          =     $FA
CMDHI          =     $FB
WORK           =     $3C
*
FROM           =     $FA        ; + $fb
TO             =     $FC        ; + $fd
SIZE           =     $FE        ; + $ff
*
SSNONE         =     $0F
SS0            =     $0E
TC             =     $80
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

* find slot nr

               JSR   $FF58
               TSX
               LDA   $0100,X
               AND   #$0F
               ORA   #$C0
               STA   CURSLOT    ; $Cs
               ASL   A
               ASL   A
               ASL   A
               ASL   A
               STA   SLOT16     ; $s0

               BIT   $CFFF
               JSR   INIT

*
* TODO: check for init error
*

* see if slot has a driver already

INSTALL        LDX   $BF31      ; get devcnt
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

ERROR          JMP   INSOUT      ; do something!

INSLP2         LDA   $BF32-1,X  ; move all entries down
               STA   $BF32,X    ; to make room at front
               DEX              ; for a new entry
               BNE   INSLP2
               LDA   #$04       ; ProFile type device
               ORA   SLOT16
               STA   $BF32      ; slot, drive 1 at top of list
               INC   $BF31      ; update devcnt

* now insert the device driver vector

               LDA   CURSLOT
               AND   #$0F
               TXA
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

               ORG   $C8FC
               DW    $FFFF      ; 65535 blocks
               DB    $47        ; Status bits
               DB    #<DRIVER   ; LSB of driver

               ORG   $C900

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

INIT           CLD
               LDA   #$03       ; set SPI mode 3
               STA   CTRL
               LDA   #SSNONE
               STA   SS
               LDA   #7
               STA   DIV
               LDX   #10
               LDA   #DUMMY

:LOOP          STA   DATA
:WAIT          BIT   CTRL
               BPL   :WAIT
               DEX
               BNE   :LOOP      ; do 10 times
               LDA   #SS0       ; set CS low
               STA   SS

               LDA   #<CMD0     ; send CMD0
               STA   CMDLO
               LDA   #>CMD0
               STA   CMDHI
               JSR   CMD
               JSR   GETR1      ; get response
               CMP   #$01
               BNE   ERROR1     ; error!

               LDA   #<CMD8     ; send CMD8
               STA   CMDLO
               LDA   #>CMD8
               STA   CMDHI
               JSR   CMD
               JSR   GETR3
               CMP   #$01
               BNE   SDV1       ; may be SD Ver. 1

* check for $01aa match!
 
SDV2           LDA   #<CMD55
               STA   CMDLO
               LDA   #>CMD55
               STA   CMDHI
               JSR   CMD
               JSR   GETR1
               LDA   #<ACMD41_40
               STA   CMDLO
               LDA   #>ACMD41_40
               STA   CMDHI
               JSR   CMD
               JSR   GETR1
               CMP   #$01
               BEQ   SDV2       ; wait for ready
               CMP   #$00
               BNE   ERROR1     ;  error!
* send CMD58
* SD Ver. 2 initialized!
               JMP   BLOCKSZ

ERROR1         JMP   IOERROR    ; needed for far jump

SDV1           LDA   #<CMD55
               STA   CMDLO
               LDA   #>CMD55
               STA   CMDHI
               JSR   CMD        ; ignore response
               LDA   #<ACMD41_0
               STA   CMDLO
               LDA   #>ACMD41_0
               STA   CMDHI
               JSR   CMD
               JSR   GETR1
               CMP   #$01
               BEQ   SDV1       ; wait for ready
               CMP   #$00
               BNE   MMC        ; may be MMC card
* SD Ver. 1 initialized!
               JMP   BLOCKSZ

MMC            LDA   #<CMD1
               STA   CMDLO
               LDA   #>CMD1
               STA   CMDHI
:LOOP          JSR   CMD
               JSR   GETR1
               CMP   #$01
               BEQ   :LOOP      ; wait for ready
               CMP   #$00
               BNE   IOERROR    ; error!
* MMC Ver. 3 initialized!

BLOCKSZ        LDA   #<CMD16
               STA   CMDLO
               LDA   #>CMD16
               STA   CMDHI
               JSR   CMD 
               JSR   GETR1
               CMP   #$00
               BNE   IOERROR    ; error!

END            CLC              ; all ok
               LDY   #0
               BCC   END1
CDERROR        SEC
               LDY   #$28       ; no card error
               BCS   END1
IOERROR        SEC
               LDY   #$27       ; init error
END1           LDA   #SSNONE    ; deselect card
               STA   SS
               LDA   #0
               STA   DIV
               TYA              ; retval in A
               RTS


********************************
*
* Send SD command
* Call with command in CMDHI and CMDLO
*
********************************

CMD            LDY   #0
:LOOP          LDA   (CMDLO),Y
               STA   DATA
:WAIT          BIT   CTRL       ; TC is in N
               BPL   :WAIT
               INY
               CPY   #6
               BCC   :LOOP
               RTS


********************************
*
* Get R1
* R1 is in A
*
********************************

GETR1          LDA   #DUMMY
               STA   DATA
:WAIT          BIT   CTRL
               BPL   :WAIT
               LDA   DATA       ; get response
               STA   R30+SLOT   ; save R1
               AND   #$80
               BNE   GETR1      ; wait for MSB=0
               LDA   #DUMMY
               STA   DATA       ; send another dummy
               LDA   R30+SLOT    ; restore R1
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
               LDY   #04
:LOOP          LDA   #DUMMY     ; send dummy
               STA   DATA
:WAIT          BIT   CTRL
               BPL   :WAIT
               LDA   DATA
               PHA
               DEY
               BNE   :LOOP      ; do 4 times
               PLA
               STA   R33+SLOT   ; save R3
               PLA
               STA   R32+SLOT
               PLA
               STA   R31+SLOT
               PLA
               STA   R30+SLOT
               PLY              ; restore Y
               LDA   #DUMMY
               STA   DATA       ; send another dummy
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
* X       - Blocks avail (low byte)
* Y       - Blocks avail (high byte)
*
********************************

STATUS         CLC              ; no error
               LDA   #0
               LDX   #$FF       ; 32 MB partition
               LDY   #$FF
               RTS

*
* TODO: check for card detect and write protect!
*


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

*
* TODO: check for card detect!
*

READ           LDA   #SS0       ; enable /CS
               STA   SS

               LDA   $46        ; store block num
               STA   R33+SLOT   ; in R30-R33
               LDA   $47
               STA   R32+SLOT
               STZ   R31+SLOT
               STZ   R30+SLOT
               LDY   #9
:LOOP          ASL   R33+SLOT   ; mul block num
               ROL   R32+SLOT   ; by 512 to get
               ROL   R31+SLOT   ; real address
               ROL   R30+SLOT
               DEY
               BNE   :LOOP

               LDA   #$51       ; send CMD17
               STA   DATA
:WAIT          BIT   CTRL
               BPL   :WAIT
:ARG           LDA   R30+SLOT   ; get arg from R30 on
               STA   DATA
:WAIT1         BIT   CTRL
               BPL   :WAIT1
               LDA   R31+SLOT
               STA   DATA
:WAIT11        BIT   CTRL
               BPL   :WAIT11
               LDA   R32+SLOT
               STA   DATA
:WAIT12        BIT   CTRL
               BPL   :WAIT12
               LDA   R33+SLOT
               STA   DATA
:WAIT13        BIT   CTRL
               BPL   :WAIT13
               LDA   #DUMMY
               STA   DATA       ; dummy crc
:WAIT2         BIT   CTRL
               BPL   :WAIT2
:GETR1         LDA   #DUMMY
               STA   DATA       ; get R1
:WAIT3         BIT   CTRL
               BPL   :WAIT3
               LDA   DATA       ; get response
*
* TODO: check for error!
*
               CMP   #$FE
               BNE   :GETR1     ; wait for $FE

               LDX   #2         ; read data from card
:LOOPX         LDY   #0
:LOOPY         LDA   #DUMMY
               STA   DATA
:WAIT4         BIT   CTRL
               BPL   :WAIT4
               LDA   DATA
               STA   ($44)
               INC   $44
               BNE   :INY
               INC   $45        ; inc msb on page boundary
:INY           INY
               BNE   :LOOPY
               DEX
               BNE   :LOOPX

:OK            JSR   GETR3      ; read 2 bytes crc
               LDA   #SSNONE
               STA   SS         ; disable /CS
               CLC              ; no error
               LDA   #$00
               RTS

:ERROR         LDA   #SSNONE
               STA   SS         ; disable /CS
               SEC              ; an error occured
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
*   $27   - Bad block number
*   $28   - No card inserted
*
********************************

*
* TODO: check for card detect and write protect!
*

WRITE          LDA   #SS0       ; enable /CS
               STA   SS

               LDA   $46        ; store block num
               STA   R33+SLOT
               LDA   $47
               STA   R32+SLOT
               STZ   R31+SLOT
               STZ   R30+SLOT
               LDY   #9
:LOOP          ASL   R33+SLOT   ; mul block num
               ROL   R32+SLOT   ; by 512 to get
               ROL   R31+SLOT   ; real address
               ROL   R30+SLOT
               DEY
               BNE   :LOOP

               LDA   #$58       ; send CMD24
               STA   DATA
:WAIT          BIT   CTRL
               BPL   :WAIT
:ARG           LDA   R30+SLOT   ; get arg from R30 on
               STA   DATA
:WAIT1         BIT   CTRL
               BPL   :WAIT1
               LDA   R31+SLOT
               STA   DATA
:WAIT11        BIT   CTRL
               BPL   :WAIT11
               LDA   R32+SLOT
               STA   DATA
:WAIT12        BIT   CTRL
               BPL   :WAIT12
               LDA   R33+SLOT
               STA   DATA
:WAIT13        BIT   CTRL
               BPL   :WAIT13
               LDA   #DUMMY
               STA   DATA       ; dummy crc
:WAIT2         BIT   CTRL
               BPL   :WAIT2
:GETR1         LDA   #DUMMY
               STA   DATA       ; get R1
:WAIT3         BIT   CTRL
               BPL   :WAIT3
               LDA   DATA       : get response
*
* TODO: check for error!
*
               CMP   #$FE
               BNE   :GETR1     ; wait for $FE
               LDX   #2         ; send data to card
:LOOPX         LDY   #0
:LOOPY         LDA   ($44)
               STA   DATA
:WAIT4         BIT   CTRL
               BPL   :WAIT4
               INC   $44
               BNE   :INY
               INC   $45        ; inc msb on page boundary
:INY           INY
               BNE   :LOOPY
               DEX
               BNE   :LOOPX

               LDY   #2         ; send 2 dummy crc bytes
:CRC           STA   DATA
:WAIT5         BIT   CTRL
               BPL   :WAIT5
               DEY
               BNE   :CRC

:OK            LDA   #SSNONE    ; disable /CS
               STA   SS
               CLC              ; no error
               LDA   #0
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



CMD0           HEX   400000000095
CMD1           HEX   4100000000F9
CMD8           HEX   48000001AA87
CMD16          HEX   5000000200FF
CMD55          HEX   770000000065
ACMD41_40      HEX   694000000077
ACMD41_0       HEX   6900000000FF

DRIVEND        =     *
