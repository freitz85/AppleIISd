;*******************************
;
; Apple][Sd Firmware
; Version 1.2
; Main source
;
; (c) Florian Reitz, 2017 - 2018
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************

.import PD_DISP
.import SMARTPORT
.import GETR1
.import GETR3
.import SDCMD
.import CARDDET

.include "AppleIISd.inc"


;******************************* 
; 
; Signature bytes 
; 
; 65535 blocks 
; Removable media 
; Non-interruptable 
; 2 drives 
; Read, write and status allowed 
; 
;******************************* 

            .segment "SLOTID"
            .byt   $0         ; not extended, no SCSI, no RAM
            .dbyt  $0         ; use status call
            .byt   $97        ; Status bits
            .byt   <DRIVER    ; LSB of driver


;******************************* 
; 
; Bootcode
; 
; Is executed on boot or PR#
; 
;******************************* 

            .segment "SLOTROM"
            LDX   #$20
            LDX   #$00
            LDX   #$03
            LDX   #$00        ; is Smartport controller

PRODOS:     
            SEI               ; no interrupts if booting
            BIT   $CFFF
            LDY   #0          ; display copyright message
@DRAW:      LDA   TEXT,Y
            BEQ   @OAPPLE     ; check for NULL
            ORA   #$80
            STA   $0750,Y     ; put second to last line
            INY
            BPL   @DRAW

@OAPPLE:    BIT   OAPPLE      ; check for OA key
            BPL   @BOOT       ; and skip boot if pressed

@NEXTSLOT:  LDA   CURSLOT     ; skip boot when no card
            DEC   A
            STA   CMDHI
            STZ   CMDLO
            JMP   (CMDLO)


;*******************************
;
; Boot from SD card
;
;*******************************

@BOOT:      LDA   #$01        ; READ
            STA   DCMD        ; load command
            LDA   #$08
            STA   BUFFER+1    ; buffer hi
            STZ   BUFFER      ; buffer lo
            STZ   BLOCKNUM+1  ; block hi
            STZ   BLOCKNUM    ; block lo
            LDA   #>DRIVER
            JSR   DRIVER      ; call driver
            CMP   #0 
            BNE   @NEXTSLOT   ; init not successful 

            LDA   #$01        ; READ
            STA   DCMD        ; load command
            STX   DSNUMBER    ; slot number
            LDA   #$0A
            STA   BUFFER+1    ; buffer hi
            STZ   BUFFER      ; buffer lo
            STZ   BLOCKNUM+1  ; block hi
            LDA   #$01
            STA   BLOCKNUM    ; block lo
            JSR   DRIVER      ; call driver
            CMP   #0 
            BNE   @NEXTSLOT   ; init not successful 
            LDX   SLOT16
            JMP   $801        ; goto bootloader


;*******************************
;
; Jump table
;
;*******************************

DRIVER:     BRA   @SAVEZP     ; jump to ProDOS entry
            BRA   @SMARTPORT  ; jump to Smartport entry

@SAVEZP:    PHA               ; make room for retval
            LDA   SLOT16      ; save all ZP locations
            PHA
            LDA   SLOT
            PHA
            LDA   CMDLO
            PHA
            LDA   CMDHI
            PHA
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
            TAY               ; Y holds now SLOT
            ASL   A
            ASL   A
            ASL   A
            ASL   A

            STA   SLOT16      ; $s0
            TAX               ; X holds now SLOT16
            BIT   $CFFF
            JSR   CARDDET
            BCC   @INITED
            LDA   ERR_OFFLINE ; no card inserted
            BRA   @RESTZP

@INITED:    LDA   #INITED     ; check for init
            BIT   SS,X
            BNE   @PD_DISP
            JSR   INIT
            BCS   @RESTZP     ; Init failed

@PD_DISP:   JSR   PD_DISP     ; ProDOS dispatcher

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

@SMARTPORT: JMP   SMARTPORT


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
            LDA   #7          ; set 400 kHz
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
            JSR   GETR3       ; R7 is also 1+4 bytes 
            CMP   #$01
            BNE   @SDV1       ; may be SD Ver. 1

            LDY   SLOT        ; check for $aa in R33 
            LDA   R33,Y 
            CMP   #$AA 
            BNE   @ERROR1     ; error! 

@SDV2:      LDA   #<CMD55
            STA   CMDLO
            LDA   #>CMD55
            STA   CMDHI
            JSR   SDCMD
            JSR   GETR1
            LDA   #<ACMD4140  ; enable SDHC support 
            STA   CMDLO
            LDA   #>ACMD4140
            STA   CMDHI
            JSR   SDCMD
            JSR   GETR1
            CMP   #$01
            BEQ   @SDV2       ; wait for ready
            CMP   #0
            BNE   @ERROR1     ;  error!

; SD Ver. 2 initialized!
            LDA   #<CMD58     ; check for SDHC 
            STA   CMDLO 
            LDA   #>CMD58 
            STA   CMDHI 
            JSR   SDCMD 
            JSR   GETR3 
            CMP   #0 
            BNE   @ERROR1     ; error! 
            LDY   SLOT 
            LDA   R30,Y 
            AND   #$40        ; check CCS 
            BEQ   @BLOCKSZ 
 
            LDA   SS,X        ; card is SDHC 
            ORA   #SDHC
            STA   SS,X
            JMP   @END

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
            LDY   NO_ERR
            BCC   @END1

@IOERROR:   SEC
            LDY   ERR_IOERR   ; init error
@END1:      LDA   SS,X        ; set CS high
            ORA   #SS0
            STA   SS,X
            LDA   #0          ; set div to 2
            STA   DIV,X
            TYA               ; retval in A
            RTS


TEXT:       .asciiz "  Apple][Sd v1.2 (c)2018 Florian Reitz"

CMD0:       .byt $40, $00, $00
            .byt $00, $00, $95
CMD1:       .byt $41, $00, $00
            .byt $00, $00, $F9
CMD8:       .byt $48, $00, $00
            .byt $01, $AA, $87
CMD16:      .byt $50, $00, $00
            .byt $02, $00, $FF
CMD55:      .byt $77, $00, $00
            .byt $00, $00, $FF 
CMD58:      .byt $7A, $00, $00 
            .byt $00, $00, $FF
ACMD4140:   .byt $69, $40, $00
            .byt $00, $00, $77
ACMD410:    .byt $69, $00, $00
            .byt $00, $00, $FF
