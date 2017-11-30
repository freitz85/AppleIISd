;*******************************
;
; Apple][Sd Firmware
; Version 0.8
;
; (c) Florian Reitz, 2017
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************

;DEBUG       :=    0
            
; Memory defines

SLOT16      :=    $2B         ; $s0 -> slot * 16
SLOT        :=    $3D         ; $0s
CMDLO       :=    $40
CMDHI       :=    $41

DCMD        :=    $42         ; Command code
BUFFER      :=    $44         ; Buffer address
BLOCK       :=    $46         ; Block number

R30         :=    $0478
R31         :=    $04F8
R32         :=    $0578
R33         :=    $05F8
CURSLOT     :=    $07F8       ; $Cs
OAPPLE      :=    $C061       ; open apple key
DATA        :=    $C080
CTRL        :=    DATA+1
DIV         :=    DATA+2
SS          :=    DATA+3

; Constants

DUMMY       =     $FF
FRX         =     $10         ; CTRL register
ECE         =     $04
SS0         =     $01         ; SS register
SDHC        =     $10
WP          =     $20
CD          =     $40
INITED      =     $80


; signature bytes

            .segment "SLOTROM"
            LDX   #$20
            LDX   #$00
            LDX   #$03
            LDX   #$3C

; find slot nr

            .ifdef DEBUG
            LDA   #$04
            STA   SLOT
            LDA   #$C4
            STA   CURSLOT
            LDA   #$40

            .else
            PHP
            SEI
            LDA   #$60        ; opcode for RTS
            STA   SLOT
            JSR   SLOT
            TSX
            LDA   $0100,X
            STA   CURSLOT     ; $Cs
            AND   #$0F
            PLP
            STA   SLOT        ; $0s
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            .endif

            STA   SLOT16      ; $s0
            TAX               ; X holds now SLOT16
            BIT   $CFFF
            LDY   #0          ; display copyright message
@DRAW:      LDA   TEXT,Y
            BEQ   @OAPPLE     ; check for NULL
            ORA   #$80
            STA   $0750,Y     ; put second to last line
            INY
            BPL   @DRAW

@OAPPLE:    BIT   OAPPLE      ; check for OA key
            BMI   @NEXTSLOT   ; and skip boot if pressed

            JSR   CARDDET
            BCC   @INIT

@NEXTSLOT:  LDA   CURSLOT     ; skip boot when no card
            DEC   A
            STA   CMDHI
            STZ   CMDLO
            JMP   (CMDLO)

@INIT:      JSR   INIT


;*******************************
;
; Install SD card driver
;
;*******************************

            .ifdef DEBUG

; see if slot has a driver already

            LDX   $BF31       ; get devcnt
@INSTALL:   LDA   $BF32,X     ; get a devnum
            AND   #$70        ; isolate slot
            CMP   SLOT16      ; slot?
            BEQ   @INSOUT     ; yes, skip it
            DEX
            BPL   @INSTALL    ; keep up the search

; restore the devnum to the list

            LDX   $BF31       ; get devcnt again
            CPX   #$0D        ; device table full?
            BNE   @INST2

            JSR   $FF3A       ; bell
            JMP   @INSOUT     ; do something!

@INST2:     LDA   $BF32-1,X   ; move all entries down
            STA   $BF32,X     ; to make room at front
            DEX               ; for a new entry
            BNE   @INST2
            LDA   #$04        ; ProFile type device
            ORA   SLOT16
            STA   $BF32       ; slot, drive 1 at top of list
            INC   $BF31       ; update devcnt

; now insert the device driver vector

            LDA   SLOT
            ASL
            TAX
            LDA   #<DRIVER
            STA   $BF10,X     ; write to driver table
            LDA   #>DRIVER
            STA   $BF11,X
@INSOUT:    RTS


;*******************************
;
; Boot from SD card
;
;*******************************

            .else
@BOOT:      LDA   #$01
            STA   DCMD        ; load command
            LDX   SLOT16
            STX   $43         ; slot number
            LDA   #$08
            STA   BUFFER+1    ; buffer hi
            STZ   BUFFER      ; buffer lo
            STZ   BLOCK+1     ; block hi
            STZ   BLOCK       ; block lo
            BIT   $CFFF
            JSR   READ        ; call driver

            LDA   #$01
            STA   DCMD        ; load command
            LDX   SLOT16
            STX   $43         ; slot number
            LDA   #$0A
            STA   BUFFER+1    ; buffer hi
            STZ   BUFFER      ; buffer lo
            STZ   BLOCK+1     ; block hi
            LDA   #$01
            STA   BLOCK       ; block lo
            BIT   $CFFF
            JSR   READ        ; call driver
            LDX   SLOT16
            JMP   $801        ; goto bootloader
            .endif


;*******************************
;
; Jump table
;
;*******************************

DRIVER:     CLD

@SAVEZP:    PHA               ; make room for retval
            LDA   SLOT16      ; save all ZP locations
            PHA
            LDA   SLOT
            PHA
            LDA   CMDLO
            PHA
            LDA   CMDHI
            PHA

            .ifdef DEBUG
            LDA   #$04
            STA   SLOT
            LDA   #$C4
            STA   CURSLOT
            LDA   #$40

            .else
            PHP
            SEI
            LDA   #$60        ; opcode for RTS
            STA   SLOT
            JSR   SLOT
            TSX
            LDA   $0100,X
            STA   CURSLOT     ; $Cs
            AND   #$0F
            PLP
            STA   SLOT        ; $0s
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            .endif

            STA   SLOT16      ; $s0
            TAX               ; X holds now SLOT16
            BIT   $CFFF
            JSR   CARDDET
            BCC   @INITED
            LDA   #$2F        ; no card inserted
            BRA   @RESTZP

@INITED:    LDA   #INITED     ; check for init
            BIT   SS,X
            BEQ   @INIT

@CMD:       LDA   DCMD        ; get command
            BEQ   @STATUS     ; branch if cmd is 0
            CMP   #1
            BEQ   @READ
            CMP   #2
            BEQ   @WRITE
            .ifdef DEBUG
            CMP   #$FF
            BEQ   @TEST
            .endif
            LDA   #1          ; unknown command
            SEC
            BRA   @RESTZP

@STATUS:    JSR   STATUS
            BRA   @RESTZP
@READ:      JSR   READ
            BRA   @RESTZP
@WRITE:     JSR   WRITE
            BRA   @RESTZP
            .ifdef DEBUG
@TEST:      JSR   TEST        ; do device test
            BRA   @RESTZP
            .endif

@INIT:      JSR   INIT
            BCC   @CMD        ; init ok

@RESTZP:    TSX
            STA   $105,X      ; save retval on stack
            PLA               ; restore all ZP locations
            STA   CMDHI
            PLA
            STA   CMDLO
            PLA
            STA   SLOT
            PLA
            STA   SLOT16
            PLA               ; get retval
            RTS


; Signature bytes

            .segment "SLOTID"
            .dbyt  $FFFF      ; 65535 blocks
            .byt   $97        ; Status bits
            .byt   <DRIVER    ; LSB of driver

;*******************************
;
; Initialize SD card
;
; C Clear - No error
;   Set   - Error
; A $00   - No error
;   $27   - I/O error - Init failed
;   $2F   - No card inserted
;
;*******************************

            .segment "EXTROM"
INIT:       LDA   #$03        ; set SPI mode 3
            STA   CTRL,X
            LDA   SS,X
            ORA   #SS0        ; set CS high
            STA   SS,X
            LDA   #7
            STA   DIV,X
            LDY   #10
            LDA   #DUMMY

@LOOP:      STA   DATA,X
@WAIT:      BIT   CTRL,X
            BPL   @WAIT
            DEY
            BNE   @LOOP       ; do 10 times
            LDA   SS,X
            AND   #<~SS0      ; set CS low
            STA   SS,X

            LDA   #<CMD0      ; send CMD0
            STA   CMDLO
            LDA   #>CMD0
            STA   CMDHI
            JSR   SDCMD
            JSR   GETR1       ; get response
            CMP   #$01
            BNE   @ERROR1     ; error!

            LDA   #<CMD8      ; send CMD8
            STA   CMDLO
            LDA   #>CMD8
            STA   CMDHI
            JSR   SDCMD
            JSR   GETR3
            CMP   #$01
            BNE   @SDV1       ; may be SD Ver. 1

; check for $01aa match!
@SDV2:      LDA   #<CMD55
            STA   CMDLO
            LDA   #>CMD55
            STA   CMDHI
            JSR   SDCMD
            JSR   GETR1
            LDA   #<ACMD4140
            STA   CMDLO
            LDA   #>ACMD4140
            STA   CMDHI
            JSR   SDCMD
            JSR   GETR1
            CMP   #$01
            BEQ   @SDV2       ; wait for ready
            CMP   #0
            BNE   @ERROR1     ;  error!
; send CMD58
; SD Ver. 2 initialized!
            LDA   SS,X
            ORA   #SDHC
            STA   SS,X
            JMP   @BLOCKSZ

@ERROR1:    JMP   @IOERROR    ; needed for far jump

@SDV1:      LDA   #<CMD55
            STA   CMDLO
            LDA   #>CMD55
            STA   CMDHI
            JSR   SDCMD       ; ignore response
            LDA   #<ACMD410
            STA   CMDLO
            LDA   #>ACMD410
            STA   CMDHI
            JSR   SDCMD
            JSR   GETR1
            CMP   #$01
            BEQ   @SDV1       ; wait for ready
            CMP   #0
            BNE   @MMC        ; may be MMC card
; SD Ver. 1 initialized!
            JMP   @BLOCKSZ

@MMC:       LDA   #<CMD1
            STA   CMDLO
            LDA   #>CMD1
            STA   CMDHI
@LOOP1:     JSR   SDCMD
            JSR   GETR1
            CMP   #$01
            BEQ   @LOOP1      ; wait for ready
            CMP   #0
            BNE   @IOERROR    ; error!
; MMC Ver. 3 initialized!

@BLOCKSZ:   LDA   #<CMD16
            STA   CMDLO
            LDA   #>CMD16
            STA   CMDHI
            JSR   SDCMD
            JSR   GETR1
            CMP   #0
            BNE   @IOERROR    ; error!

@END:       LDA   SS,X
            ORA   #INITED     ; initialized
            STA   SS,X
            LDA   CTRL,X
            ORA   #ECE        ; enable 7MHz
            STA   CTRL,X
            CLC               ; all ok
            LDY   #0
            BCC   @END1

@IOERROR:   SEC
            LDY   #$27        ; init error
@END1:      LDA   SS,X        ; set CS high
            ORA   #SS0
            STA   SS,X
            LDA   #0          ; set div to 2
            STA   DIV,X
            TYA               ; retval in A
            RTS


;*******************************
;
; Send SD command
; Call with command in CMDHI and CMDLO
;
;*******************************

SDCMD:      PHY
            LDY   #0
@LOOP:      LDA   (CMDLO),Y
            STA   DATA,X
@WAIT:      BIT   CTRL,X      ; TC is in N
            BPL   @WAIT
            INY
            CPY   #6
            BCC   @LOOP
            PLY
            RTS


;*******************************
;
; Get R1
; R1 is in A
;
;*******************************

GETR1:      LDA   #DUMMY
            STA   DATA,X
@WAIT:      BIT   CTRL,X
            BPL   @WAIT
            LDA   DATA,X      ; get response
            BIT   #$80
            BNE   GETR1       ; wait for MSB=0
            PHA
            LDA   #DUMMY
            STA   DATA,X      ; send another dummy
            PLA               ; restore R1
            RTS

;*******************************
;
; Get R3
; R1 is in A
; R3 is in scratchpad ram
;
;*******************************

GETR3:      JSR   GETR1       ; get R1 first
            PHA               ; save R1
            PHY               ; save Y
            LDY   #04         ; load counter
@LOOP:      LDA   #DUMMY      ; send dummy
            STA   DATA,X
@WAIT:      BIT   CTRL,X
            BPL   @WAIT
            LDA   DATA,X
            PHA
            DEY
            BNE   @LOOP       ; do 4 times
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


;*******************************
;
; Calculate block address
; Unit number is in $43 DSSS0000
; Block no is in $46-47
; Address is in R30-R33
;
;*******************************

GETBLOCK:   PHX               ; save X
            PHY               ; save Y
            TXA
            TAY               ; SLOT16 is now in Y
            LDX   SLOT
            LDA   BLOCK       ; store block num
            STA   R33,X       ; in R30-R33
            LDA   BLOCK+1
            STA   R32,X
            LDA   #0
            STA   R31,X
            STA   R30,X

            LDA   #$80        ; drive number
            AND   $43
            BEQ   @SDHC       ; D1
            LDA   #1          ; D2
            STA   R31,X

@SDHC:      LDA   #SDHC
            AND   SS,Y        ; if card is SDHC,
            BNE   @END        ; use block addressing
            
            LDY   #9          ; ASL can't be used with Y
@LOOP:      ASL   R33,X       ; mul block num
            ROL   R32,X       ; by 512 to get
            ROL   R31,X       ; real address
            ROL   R30,X
            DEY
            BNE   @LOOP
  
 @END:      PLY               ; restore Y
            PLX               ; restore X
            RTS


;*******************************
;
; Send SD command
; Cmd is in A
;
;*******************************

COMMAND:    PHY               ; save Y
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


;*******************************
;
; Check for card detect
;
; C Clear - card in slot
;   Set   - no card in slot
;
;*******************************

CARDDET:    PHA
            LDA   #CD         ; 0: card in
            BIT   SS,X        ; 1: card out
            CLC
            BEQ   @DONE       ; card is in
            SEC               ; card is out
@DONE:      PLA
            RTS


;*******************************
;
; Check for write protect
;
; C Clear - card not protected
;   Set   - card write protected
;
;*******************************

WRPROT:     PHA
            LDA   #WP         ; 0: write enabled
            BIT   SS,X        ; 1: write disabled
            CLC
            BEQ   @DONE
            SEC
@DONE:      PLA
            RTS


;*******************************
;
; Status request
; $43    Unit number DSSS000
; $44-45 Unused
; $46-47 Unused
;
; C Clear - No error
;   Set   - Error
; A $00   - No error
;   $2B   - Card write protected
;   $2F   - No card inserted
; X       - Blocks avail (low byte)
; Y       - Blocks avail (high byte)
;
;*******************************

STATUS:     LDA   #0          ; no error
            JSR   WRPROT
            BCC   @DONE
            LDA   #$2B        ; card write protected

@DONE:      LDX   #$FF        ; 32 MB partition
            LDY   #$FF
            RTS


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
;
;*******************************

READ:       JSR   GETBLOCK    ; calc block address

            LDA   SS,X        ; enable /CS
            AND   #<~SS0
            STA   SS,X
            LDA   #$51        ; send CMD17
            JSR   COMMAND     ; send command
            CMP   #0
            BNE   @ERROR      ; check for error

@GETTOK:    LDA   #DUMMY      ; get data token
            STA   DATA,X
            LDA   DATA,X      ; get response
            CMP   #$FE
            BNE   @GETTOK     ; wait for $FE

            LDA   CTRL,X      ; enable FRX
            ORA   #FRX
            STA   CTRL,X
            LDA   #DUMMY
            STA   DATA,X

            LDY   #0
@LOOP1:     LDA   DATA,X      ; read data from card
            STA   (BUFFER),Y
            INY
            BNE   @LOOP1
            INC   BUFFER+1    ; inc msb on page boundary
@LOOP2:     LDA   DATA,X
            STA   (BUFFER),Y
            INY
            BNE   @LOOP2
            DEC   BUFFER+1

@CRC:       LDA   DATA,X      ; read two bytes crc
            LDA   DATA,X      ; and ignore
            LDA   DATA,X      ; read a dummy byte

            LDA   CTRL,X      ; disable FRX
            AND   #<~FRX
            STA   CTRL,X
            CLC               ; no error
            LDA   #0

@DONE:      PHP
            PHA
            LDA   SS,X
            ORA   #SS0
            STA   SS,X        ; disable /CS
            PLA
            PLP
            RTS

@ERROR:     SEC               ; an error occured
            LDA   #$27
            BRA   @DONE


;*******************************
;
; Write 512 byte block
; $43    Unit number DSSS0000
; $44-45 Address (LO/HI) of buffer
; $46-47 Block number (LO/HI)
;
; C Clear - No error
;   Set   - Error
; A $00   - No error
;   $27   - I/O error or bad block number
;   $2B   - Card write protected
;
;*******************************

WRITE:      JSR   WRPROT
            BCS   @WPERROR    ; card write protected

            JSR   GETBLOCK    ; calc block address

            LDA   SS,X        ; enable /CS
            AND   #<~SS0
            STA   SS,X
            LDA   #$58        ; send CMD24
            JSR   COMMAND     ; send command
            CMP   #0
            BNE   @IOERROR    ; check for error

            LDA   #DUMMY
            STA   DATA,X      ; send dummy
            LDA   #$FE
            STA   DATA,X      ; send data token

            LDY   #0
@LOOP1:     LDA   (BUFFER),Y
            STA   DATA,X
            INY
            BNE   @LOOP1
            INC   BUFFER+1
@LOOP2:     LDA   (BUFFER),Y
            STA   DATA,X
            INY
            BNE   @LOOP2
            DEC   BUFFER+1

@CRC:       LDA   #DUMMY
            STA   DATA,X      ; send 2 dummy crc bytes
            STA   DATA,X

            STA   DATA,X      ; get data response
            LDA   DATA,X
            AND   #$1F
            CMP   #$05
            BNE   @IOERROR    ; check for write error
            CLC               ; no error
            LDA   #0

@DONE:      PHP
            PHA
@WAIT:      LDA   #DUMMY
            STA   DATA,X      ; wait for write cycle
            LDA   DATA,X      ; to complete
            BEQ   @WAIT

            LDA   SS,X        ; disable /CS
            ORA   #SS0
            STA   SS,X
            PLA
            PLP
            RTS

@IOERROR:   SEC               ; an error occured
            LDA   #$27
            BRA   @DONE

@WPERROR:   SEC
            LDA   #$2B
            BRA   @DONE



;*******************************
;
; Test routine
;
;*******************************

            .ifdef DEBUG
TEST:       LDA   SLOT16
            PHA
            LDA   SLOT
            PHA

; get buffer
            LDA   #2          ; get 512 byte buffer
            JSR   $BEF5       ; call GETBUFR
            BCS   @ERROR
            STA   BUFFER+1
            STZ   BUFFER
            PLA
            STA   SLOT
            PLA
            STA   SLOT16

; fill buffer
            LDY   #0
@LOOP:      TYA
            STA   (BUFFER),Y
            INY
            BNE   @LOOP
            INC   BUFFER+1
@LOOP1:     TYA
            STA   (BUFFER),Y
            INY
            BNE   @LOOP1
            DEC   BUFFER+1

            STZ   BLOCK       ; block number
            STZ   BLOCK+1
            LDX   SLOT16

; write to card
            JSR   WRITE
            BCS   @ERROR

; read from card
            JSR   READ
            BCS   @ERROR

; check for errors
            LDY   #0
@LOOP2:     TYA
            CMP   (BUFFER),Y
            BNE   @ERRCMP     ; error in buffer
            INY
            BNE   @LOOP2
            INC   BUFFER+1
@LOOP3:     TYA
            CMP   (BUFFER),Y
            BNE   @ERRCMP
            INY
            BNE   @LOOP3
            DEC   BUFFER+1

; free buffer
            JSR   $BEF8       ; call FREEBUFR
            CLC
            LDA   #0
            RTS

@ERROR:     BRK
@ERRCMP:    BRK
            .endif


TEXT:       .asciiz "  Apple][Sd v0.8 (c)2017 Florian Reitz"

CMD0:       .byt $40, $00, $00
            .byt $00, $00, $95
CMD1:       .byt $41, $00, $00
            .byt $00, $00, $F9
CMD8:       .byt $48, $00, $00
            .byt $01, $AA, $87
CMD16:      .byt $50, $00, $00
            .byt $02, $00, $FF
CMD55:      .byt $77, $00, $00
            .byt $00, $00, $65
ACMD4140:   .byt $69, $40, $00
            .byt $00, $00, $77
ACMD410:    .byt $69, $00, $00
            .byt $00, $00, $FF

