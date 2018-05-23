;*******************************
;
; Apple][Sd Firmware
; Version 1.2
; Smartport functions
;
; (c) Florian Reitz, 2017 - 2018
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************
            
.export SMARTPORT


.include "AppleIISd.inc"
.segment "EXTROM"


;*******************************
;
; Smartport command dispatcher
;
; $42-$47 MLI input locations
; X Slot*16
; Y Slot
;
; C Clear - No error
;   Set   - Error
; A $00   - No error
;   $01   - Unknown command
;
;*******************************

SMARTPORT:  LDY   #SMZPSIZE-1   ; save zeropage area for Smarport
@SAVEZP:    LDA   SMZPAREA,Y
            PHA
            DEY
            BPL   @SAVEZP

            TSX                 ; get parameter list pointer
            LDA   $101+SMZPSIZE,X
            STA   SMPARAMLIST
            CLC
            ADC   #3            ; adjust return address
            STA   $101+SMZPSIZE,X
            LDA   $102+SMZPSIZE,X
            STA   SMPARAMLIST+1
            ADC   #0
            STA   $102+SMZPSIZE,X

            LDY   #1            ; get command code
            LDA   (SMPARAMLIST),Y 
            STA   SMCMD
            INY
            LDA   (SMPARAMLIST),Y
            TAX
            INY
            LDA   (SMPARAMLIST),Y
            STA   SMPARAMLIST+1 ; TODO: why overwrite, again?
            STX   SMPARAMLIST

            LDA   #ERR_BADCMD   ; suspect bad command
            LDX   SMCMD
            CPX   #$09+1        ; command too large
            BCS   @END

            LDA   (SMPARAMLIST) ; parameter count
            CMP   REQPARAMCOUNT,X
            BNE   @COUNTMISMATCH

            LDY   #1            ; get drive number
            LDA   (SMPARAMLIST),Y
            LDY   SLOT
            STA   DRVNUM,Y

            TXA
            ASL   A             ; shift for use or word addresses
            TAX
            JSR   @JMPSPCOMMAND
            BCS   @END          ; jump on error
            LDA   #NO_ERR

@END:       TAX                 ; save retval
            LDY   #0            ; restore zeropage
@RESTZP:    PLA
            STA   SMZPAREA,Y
            INY
            CPY   #SMZPSIZE
            BCC   @RESTZP

            TXA
            LDY   #2            ; highbyte of # bytes transferred
            LDY   #0            ; low byte of # bytes transferred
            CMP   #1            ; C=1 if A != NO_ERR
            RTS

@COUNTMISMATCH:
            LDA   #ERR_BADPCNT
            BRA   @END
            
@JMPSPCOMMAND:                  ; use offset from cmd*2
            JMP   (SPDISPATCH,X)
            


; Required parameter counts for the commands
REQPARAMCOUNT:
            .byt 3              ; 0 = status
            .byt 3              ; 1 = read block
            .byt 3              ; 2 = write block
            .byt 1              ; 3 = format
            .byt 3              ; 4 = control
            .byt 1              ; 5 = init
            .byt 1              ; 6 = open
            .byt 1              ; 7 = close
            .byt 4              ; 8 = read char
            .byt 4              ; 9 = write char

; Command jump table
SPDISPATCH:
            .word SMSTATUS
            .word SMREADBLOCK
            .word SMWRITEBLOCK
            .word SMFORMAT
            .word SMCONTROL
            .word SMINIT
            .word SMOPEN
            .word SMCLOSE
            .word SMREADCHAR
            .word SMWRITECHAR



SMSTATUS:
SMREADBLOCK:
SMWRITEBLOCK:
SMFORMAT:
SMCONTROL:
SMINIT:
SMOPEN:
SMCLOSE:
SMREADCHAR:
SMWRITECHAR: