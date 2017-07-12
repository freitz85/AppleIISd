;*******************************
;
; Initialize SD card
;
;*******************************

               .PC02
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

FROM           =     $FA        ; + $fb
TO             =     $FC        ; + $fd
SIZE           =     $FE        ; + $ff

SSNONE         =     $0F
SS0            =     $0E
TC             =     $80
DUMMY          =     $FF


;*******************************
;
; Install SD card driver
;
;*******************************

; signature bytes

               ldx   #$20
               ldy   #$00
               ldx   #$03
               stx   WORK

; find slot nr

               jsr   $FF58
               tsx
               lda   $0100,X
               and   #$0F
               ora   #$C0
               sta   CURSLOT    ; $Cs
               asl   A
               asl   A
               asl   A
               asl   A
               sta   SLOT16     ; $s0

               bit   $CFFF
               jsr   INIT:

;
; TODO: check for init error
;

; see if slot has a driver already

INSTALL:       ldx   $BF31      ; get devcnt
INSLP:         lda   $BF32,X    ; get a devnum
               and   #$70       ; isolate slot
               cmp   SLOT16     ; slot?
               beq   INSOUT:     ; yes, skip it
               dex
               bpl   INSLP:      ; keep up the search

; restore the devnum to the list

               ldx   $BF31      ; get devcnt again
               cpx   #$0D       ; device table full?
               bne   INSLP2:

ERROR:         jmp   INSOUT:      ; do something!

INSLP2:        lda   $BF32-1,X  ; move all entries down
               sta   $BF32,X    ; to make room at front
               dex              ; for a new entry
               bne   INSLP2:
               lda   #$04       ; ProFile type device
               ora   SLOT16
               sta   $BF32      ; slot, drive 1 at top of list
               inc   $BF31      ; update devcnt

; now insert the device driver vector

               lda   CURSLOT
               and   #$0F
               txa
               lda   #<DRIVER:
               sta   $BF10,X
               lda   CURSLOT
               sta   $BF11,X

INSOUT:        rts


;*******************************
;
; Jump table
;
;*******************************

DRIVER:        cld
               bit   $CFFF
               lda   $42        ; get command
               cmp   #$00
               beq   @STATUS:
               cmp   #$01
               beq   @READ:
               cmp   #$02
               beq   @WRITE:
               cmp   #$03
               beq   @FORMAT:
               sec              ; unknown command
               lda   #$01
               rts

@STATUS:       jmp   STATUS:
@READ:         jmp   READ:
@WRITE:        jmp   WRITE:
@FORMAT:       jmp   FORMAT:

               ORG   $C8FC
               .word $FFFF      ; 65535 blocks
               .byte $47        ; Status bits
               .byte #<DRIVER:   ; LSB of driver

               ORG   $C900

;*******************************
;
; Initialize SD card
;
; C Clear - No error
;   Set   - Error
; A $00   - No error
;   $27   - I/O error - Init failed
;   $28   - No card inserted
;
;*******************************

INIT:           cld
               lda   #$03       ; set SPI mode 3
               sta   CTRL
               lda   #SSNONE
               sta   SS
               lda   #7
               sta   DIV
               ldx   #10
               lda   #DUMMY

@LOOP:          sta   DATA
@WAIT:          bit   CTRL
               bpl   @WAIT:
               dex
               bne   @LOOP:      ; do 10 times
               lda   #SS0       ; set CS low
               sta   SS

               lda   #<CMD0     ; send CMD0
               sta   CMDLO
               lda   #>CMD0
               sta   CMDHI
               jsr   CMD
               jsr   GETR1:      ; get response
               cmp   #$01
               bne   ERROR1:     ; error!

               lda   #<CMD8     ; send CMD8
               sta   CMDLO
               lda   #>CMD8
               sta   CMDHI
               jsr   CMD
               jsr   GETR3:
               cmp   #$01
               bne   SDV1:       ; may be SD Ver. 1

; check for $01aa match!
 
SDV2:           lda   #<CMD55
               sta   CMDLO
               lda   #>CMD55
               sta   CMDHI
               jsr   CMD
               jsr   GETR1:
               lda   #<ACMD41_40
               sta   CMDLO
               lda   #>ACMD41_40
               sta   CMDHI
               jsr   CMD
               jsr   GETR1:
               cmp   #$01
               beq   SDV2:       ; wait for ready
               cmp   #$00
               bne   ERROR1:     ;  error!
; send CMD58
; SD Ver. 2 initialized!
               jmp   BLOCKSZ:

ERROR1:         jmp   IOERROR:    ; needed for far jump

SDV1:           lda   #<CMD55
               sta   CMDLO
               lda   #>CMD55
               sta   CMDHI
               jsr   CMD        ; ignore response
               lda   #<ACMD41_0
               sta   CMDLO
               lda   #>ACMD41_0
               sta   CMDHI
               jsr   CMD
               jsr   GETR1:
               cmp   #$01
               beq   SDV1:       ; wait for ready
               cmp   #$00
               bne   MMC:        ; may be MMC card
; SD Ver. 1 initialized!
               jmp   BLOCKSZ:

MMC:            lda   #<CMD1
               sta   CMDLO
               lda   #>CMD1
               sta   CMDHI
@LOOP:          jsr   CMD
               jsr   GETR1:
               cmp   #$01
               beq   @LOOP:      ; wait for ready
               cmp   #$00
               bne   IOERROR:    ; error!
; MMC Ver. 3 initialized!

BLOCKSZ:        lda   #<CMD16
               sta   CMDLO
               lda   #>CMD16
               sta   CMDHI
               jsr   CMD 
               jsr   GETR1:
               cmp   #$00
               bne   IOERROR:    ; error!

END:            clc              ; all ok
               ldy   #0
               bcc   END1:
CDERROR:        sec
               ldy   #$28       ; no card error
               bcs   END1:
IOERROR:        sec
               ldy   #$27       ; init error
END1:           lda   #SSNONE    ; deselect card
               sta   SS
               lda   #0
               sta   DIV
               tya              ; retval in A
               rts


;*******************************
;
; Send SD command
; Call with command in CMDHI and CMDLO
;
;*******************************

CMD:            ldy   #0
@LOOP:          lda   (CMDLO),Y
               sta   DATA
@WAIT:          bit   CTRL       ; TC is in N
               bpl   @WAIT:
               iny
               cpy   #6
               bcc   @LOOP:
               rts


;*******************************
;
; Get R1
; R1 is in A
;
;*******************************

GETR1:          lda   #DUMMY
               sta   DATA
@WAIT:          bit   CTRL
               bpl   @WAIT:
               lda   DATA       ; get response
               sta   R30+SLOT   ; save R1
               and   #$80
               bne   GETR1:      ; wait for MSB=0
               lda   #DUMMY
               sta   DATA       ; send another dummy
               lda   R30+SLOT    ; restore R1
               rts


;*******************************
;
; Get R3
; R1 is in A
; R3 is in scratchpad ram
;
;*******************************

GETR3:          jsr   GETR1:      ; get R1 first
               pha              ; save R1
               phy              ; save Y
               ldy   #04
@LOOP:          lda   #DUMMY     ; send dummy
               sta   DATA
@WAIT:          bit   CTRL
               bpl   @WAIT:
               lda   DATA
               pha
               dey
               bne   @LOOP:      ; do 4 times
               pla
               sta   R33+SLOT   ; save R3
               pla
               sta   R32+SLOT
               pla
               sta   R31+SLOT
               pla
               sta   R30+SLOT
               ply              ; restore Y
               lda   #DUMMY
               sta   DATA       ; send another dummy
               pla              ; restore R1
               rts


;*******************************
;
; Status request
; $43    Unt number DSSS000
; $44-45 Unused
; $46-47 Unused
;
; C Clear - No error
;   Set   - Error
; A $00   - No error
;   $27   - I/O error
;   $28   - No card inserted / no init
;   $2B   - Card write protected
; X       - Blocks avail (low byte)
; Y       - Blocks avail (high byte)
;
;*******************************

STATUS:         clc              ; no error
               lda   #0
               ldx   #$FF       ; 32 MB partition
               ldy   #$FF
               rts

;
; TODO: check for card detect and write protect!
;


;*******************************
;
; Read 512 byte block
; $43    Unit number DSSS0000
; $44-45 Address (LO/HI) of buffer
; $46-47 Block number (LO/HI)
;
; C Clear - No error
;   Set   - Error
; A $00   - No error
;   $27   - Bad block number
;   $28   - No card inserted
;
;*******************************

;
; TODO: check for card detect!
;

READ:           lda   #SS0       ; enable /CS
               sta   SS

               lda   $46        ; store block num
               sta   R33+SLOT   ; in R30-R33
               lda   $47
               sta   R32+SLOT
               stz   R31+SLOT
               stz   R30+SLOT
               ldy   #9
@LOOP:          asl   R33+SLOT   ; mul block num
               rol   R32+SLOT   ; by 512 to get
               rol   R31+SLOT   ; real address
               rol   R30+SLOT
               dey
               bne   @LOOP:

               lda   #$51       ; send CMD17
               sta   DATA
@WAIT:          bit   CTRL
               bpl   @WAIT:
@ARG:           lda   R30+SLOT   ; get arg from R30 on
               sta   DATA
@WAIT1:         bit   CTRL
               bpl   @WAIT1:
               lda   R31+SLOT
               sta   DATA
@WAIT11:        bit   CTRL
               bpl   @WAIT11:
               lda   R32+SLOT
               sta   DATA
@WAIT12:        bit   CTRL
               bpl   @WAIT12:
               lda   R33+SLOT
               sta   DATA
@WAIT13:        bit   CTRL
               bpl   @WAIT13:
               lda   #DUMMY
               sta   DATA       ; dummy crc
@WAIT2:         bit   CTRL
               bpl   @WAIT2:
@GETR1:         lda   #DUMMY
               sta   DATA       ; get R1
@WAIT3:         bit   CTRL
               bpl   @WAIT3:
               lda   DATA       ; get response
;
; TODO: check for error!
;
               cmp   #$FE
               bne   @GETR1:     ; wait for $FE

               ldx   #2         ; read data from card
@LOOPX:         ldy   #0
@LOOPY:         lda   #DUMMY
               sta   DATA
@WAIT4:         bit   CTRL
               bpl   @WAIT4:
               lda   DATA
               sta   ($44)
               inc   $44
               bne   @INCY:
               inc   $45        ; inc msb on page boundary
@INCY:           iny
               bne   @LOOPY:
               dex
               bne   @LOOPX:

@OK:            jsr   GETR3:      ; read 2 bytes crc
               lda   #SSNONE
               sta   SS         ; disable /CS
               clc              ; no error
               lda   #$00
               rts

:ERROR:        lda   #SSNONE
               sta   SS         ; disable /CS
               sec              ; an error occured
               lda   #$27
               rts


;*******************************
;
; Write 512 byte block
; $43    Unit number DSSS000
; $44-45 Address (LO/HI) of buffer
; $46-47 Block number (LO/HI)
;
; C Clear - No error
;   Set   - Error
; A $00   - No error
;   $27   - Bad block number
;   $28   - No card inserted
;
;*******************************

;
; TODO: check for card detect and write protect!
;

WRITE:         lda   #SS0       ; enable /CS
               sta   SS

               lda   $46        ; store block num
               sta   R33+SLOT
               lda   $47
               sta   R32+SLOT
               stz   R31+SLOT
               stz   R30+SLOT
               ldy   #9
@LOOP:          asl   R33+SLOT   ; mul block num
               rol   R32+SLOT   ; by 512 to get
               rol   R31+SLOT   ; real address
               rol   R30+SLOT
               dey
               bne   @LOOP:

               lda   #$58       ; send CMD24
               sta   DATA
@WAIT:          bit   CTRL
               bpl   @WAIT:
@ARG:           lda   R30+SLOT   ; get arg from R30 on
               sta   DATA
@WAIT1:         bit   CTRL
               bpl   @WAIT1:
               lda   R31+SLOT
               sta   DATA
@WAIT11:        bit   CTRL
               bpl   @WAIT11:
               lda   R32+SLOT
               sta   DATA
@WAIT12:        bit   CTRL
               bpl   @WAIT12:
               lda   R33+SLOT
               sta   DATA
@WAIT13:        bit   CTRL
               bpl   @WAIT13:
               lda   #DUMMY
               sta   DATA       ; dummy crc
@WAIT2:         bit   CTRL
               bpl   @WAIT2:
@GETR1:         lda   #DUMMY
               sta   DATA       ; get R1
@WAIT3:         bit   CTRL
               bpl   @WAIT3:
               lda   DATA       ; get response
;
; TODO: check for error!
;
               cmp   #$FE
               bne   @GETR1:     ; wait for $FE
               ldx   #2         ; send data to card
@LOOPX:         ldy   #0
@LOOPY:         lda   ($44)
               sta   DATA
@WAIT4:         bit   CTRL
               bpl   @WAIT4:
               inc   $44
               bne   @INCY:
               inc   $45        ; inc msb on page boundary
@INCY:           iny
               bne   @LOOPY:
               dex
               bne   @LOOPX:

               ldy   #2         ; send 2 dummy crc bytes
@CRC:           sta   DATA
@WAIT:5         bit   CTRL
               bpl   @WAIT:5
               dey
               bne   @CRC:

@OK:            lda   #SSNONE    ; disable /CS
               sta   SS
               clc              ; no error
               lda   #0
               rts


;*******************************
;
; Format
; not supported!
;
;*******************************

FORMAT:        sec
               lda   #$01       ; invalid command
               rts



CMD0           .byte   $400000000095
CMD1           .byte   $4100000000F9
CMD8           .byte   $48000001AA87
CMD16          .byte   $5000000200FF
CMD55          .byte   $770000000065
ACMD41_40      .byte   $694000000077
ACMD41_0       .byte   $6900000000FF

DRIVEND        =     *
