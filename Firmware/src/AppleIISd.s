;*******************************
;
; Apple][Sd Firmware
; Version 1.3
; Main source
;
; (c) Florian Reitz, 2017 - 2019
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************

.import PRODOS
.import SMARTPORT
.import GETR1
.import GETR3
.import SDCMD
.import CARDDET
.import READ

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
            .word  $0000      ; use status call
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

            SEI               ; find slot
            LDA   #$60        ; opcode for RTS
            STA   SLOT
            JSR   SLOT
            TSX
            LDA   $0100,X
            CLI
            STA   CURSLOT     ; $Cs
            AND   #$0F
            STA   SLOT        ; $0s
            TAY               ; Y holds now SLOT
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            STA   SLOT16      ; $s0
            TAX               ; X holds now SLOT16
            BIT   $CFFF

            LDY   #0          ; display copyright message
@DRAW:      LDA   TEXT,Y
            BEQ   @OAPPLE     ; check for NULL
            ORA   #$80        ; set MSB
            STA   $0750,Y     ; put second to last line
            INY
            BPL   @DRAW

            LDA   #197      
            JSR   $FCA8       ; wait for 100 ms

@OAPPLE:    BIT   OAPPLE      ; check for OA key
            BPL   @INIT       ; and skip boot if pressed

@NEXTSLOT:  LDA   CURSLOT     ; skip boot when no card
            DEC   A
            STA   CMDHI       ; use CMDHI/LO as pointer
            STZ   CMDLO
            JMP   (CMDLO)

@INIT:      JSR   INIT
            CMP   #NO_ERR
            BNE   @NEXTSLOT   ; init not successful

;*******************************
;
; Boot from SD card
;
;*******************************

; load disk blocks 0 and 1 to $800 and $A00
@BOOT:      LDA   #$08        ; load to $800
            STA   BUFFER+1    ; buffer hi
            STZ   BUFFER      ; buffer lo
            STZ   BLOCKNUM+1  ; block hi
            STZ   BLOCKNUM    ; block lo
            JSR   READ
            BCS   @NEXTSLOT   ; load not successful 

            LDA   #$0A
            STA   BUFFER+1    ; buffer hi
            STZ   BUFFER      ; buffer lo
            STZ   BLOCKNUM+1  ; block hi
            LDA   #$01
            STA   BLOCKNUM    ; block lo
            JSR   READ
            BCS   @NEXTSLOT   ; load not successful 
            JMP   $801        ; goto bootloader


;*******************************
;
; Jump table
;
;*******************************

DRIVER:     CLC               ; ProDOS entry
            BCC   @PRODOS
            SEC               ; Smartport entry

@PRODOS:    PHP               ; transfer P to X
            PLX
            LDY   #PDZPSIZE-1 ; save zeropage area for ProDOS
@SAVEZP:    LDA   PDZPAREA,Y
            PHA
            DEY
            BPL   @SAVEZP
            STX   PSAVE       ; save X (P)

; Has this to be done every time this gets called or only on boot???
            SEI
            LDA   #$60        ; opcode for RTS
            STA   SLOT
            JSR   SLOT
            TSX
            LDA   $0100,X
            CLI
            STA   CURSLOT     ; $Cs
            AND   #$0F
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
            LDA   #ERR_OFFLINE; no card inserted
            BRA   @END

@INITED:    LDA   #INITED     ; check for init
            BIT   SS,X
            BNE   @DISP
            JSR   INIT
            BCS   @END        ; Init failed

@DISP:      LDA   PSAVE       ; get saved P value
            PHA               ; and transfer to P
            PLP
            BCS   @SMARTPORT  ; Smartport dispatcher
            JSR   PRODOS      ; ProDOS dispatcher

@END:       PHX
            LDX   SLOT        ; X holds $0s
            STA   R30,X       ; save A
            PLA
            STA   R31,X       ; save X
            TYA
            STA   R32,X       ; save Y
            PHP
            PLA
            STA   R33,X       ; save P
            
            LDY   #0
@RESTZP:    PLA               ; restore zeropage area
            STA   PDZPAREA,Y
            INY
            CPY   #PDZPSIZE
            BCC   @RESTZP
            
            LDA   R33,X       ; get retval
            PHA
            LDA   R32,X
            PHA
            LDA   R31,X
            PHA
            LDA   R30,X        ; restore A
            PLX                ; restore X
            PLY                ; restore Y
            PLP                ; restore P
            RTS

@SMARTPORT: CLC
            JSR   SMARTPORT
            BRA   @END


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
            LDY   #NO_ERR
            BCC   @END1

@IOERROR:   SEC
            LDY   #ERR_IOERR  ; init error
@END1:      LDA   SS,X        ; set CS high
            ORA   #SS0
            STA   SS,X
            LDA   #0          ; set div to 2
            STA   DIV,X
            TYA               ; retval in A
            RTS


TEXT:       .asciiz " Apple][Sd v1.3 (c)2019 Florian Reitz "

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
