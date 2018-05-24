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

.import READ
.import WRITE
.import WRPROT

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
            JSR   @JMPSPCOMMAND ; Y holds SLOT
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
            


; Smartport Status command
;
SMSTATUS:   JSR   GETCSLIST
            LDY   SLOT
            LDA   DRVNUM,Y
            BNE   @PARTITION    ; status call for a partition

            LDA   SMCSCODE
            BEQ   @STATUS00     ; status call 0 for the bus
            LDA   #ERR_BADCTL   ; calls other than 0 are not allowed
            SEC
            RTS

@STATUS00:  LDA   #4            ; support 4 partitions
            STA   (SMCMDLIST)
            CLC
            RTS

@PARTITION: LDX   SMCSCODE
            BEQ   @STATUS03     ; 0: device status
            DEX
            BEQ   @GETDCB       ; 1: get DCB
            DEX   
            DEX
            BEQ   @STATUS03     ; 3: get DIB
            LDA   #ERR_BADCTL
            SEC
            RTS

@GETDCB:    LDA   #1            ; return 'empty' DCB, one byte
            STA   (SMCMDLIST)
            TAY
            LDA   #NO_ERR
            STA   (SMCMDLIST),Y
            CLC
            RTS

@STATUS03:  LDA   #$F8          ; block device, read, write, format,
                                ; online, no write-protect
            JSR   WRPROT
            BCC   @STATUSBYTE   
            ORA   #$04          ; SD card write-protected
@STATUSBYTE:STA  (SMCMDLIST)

            LDY   #1            ; block count, always $00FFFF
            LDA   #$FF
            STA   (SMCMDLIST),Y
            INY
            STA   (SMCMDLIST),Y
            INY
            LDA   #0
            STA   (SMCMDLIST),Y

            LDA   SMCSCODE
            BEQ   @DONE         ; done if code 0, else get DIB, 21 bytes

            LDY   #4
@LOOP:      LDA   STATUS3DATA-4,Y
            STA   (SMCMDLIST),Y
            INY
            CPY   #21+4
            BCC   @LOOP

@DONE:      CLC
            RTS


; Smartport Control command
;
; no controls supported, yet
;
SMCONTROL:  JSR   GETCSLIST
            LDX   SMCSCODE
            BEQ   @RESET        ; 0: Reset
            DEX
            BEQ   @SETDCB       ; 1: SetDCB
            DEX
            BEQ   @NEWLINE      ; 2: SetNewLine
            DEX 
            BEQ   @IRQ          ; 3: ServiceInterrupt
            DEX
            BEQ   @EJECT        ; 4: Eject

@NEWLINE:   LDA   #ERR_BADCTL
            SEC
@RESET:
@SETDCB:
@EJECT:     RTS

@IRQ:       LDA   #ERR_NOINT    ; interrupts not supported
            SEC
            RTS


; Get control/status list pointer and code
;
GETCSLIST:  LDY   #2
            LDA   (SMPARAMLIST),Y
            STA   SMCMDLIST     ; get list pointer     
            INY
            LDA   (SMPARAMLIST),Y
            STA   SMCMDLIST+1
            INY
            LDA   (SMPARAMLIST),Y
            STA   SMCSCODE      ; get status/control code
            RTS


; Smartport Read Block command
;
; reads a 512-byte block using the ProDOS function
;
SMREADBLOCK:
            JSR   TRANSLATE
            BCC   @READ
            RTS

@READ:      LDX   SLOT16
            LDY   SLOT
            JMP   READ          ; call ProDOS read



; Smartport Write Block command
;
; writes a 512-byte block using the ProDOS function
;
SMWRITEBLOCK:
            JSR   TRANSLATE
            BCC   @WRITE
            RTS

@WRITE:     LDX   SLOT16
            LDY   SLOT
            JMP   WRITE     ; call ProDOS write


; Translates the Smartport unit number to a ProDOS device
; and prepares the block number
;
; Unit 0: entire chain, not supported
; Unit 1: this slot, drive 0
; Unit 2: this slot, drive 1
; Unit 3: phantom slot, drive 0
; Unit 4: phantom slot, drive 1
;
TRANSLATE:  LDA   DRVNUM,Y
            BEQ   @BADUNIT       ; not supportd for unit 0
            CMP   #1
            BEQ   @UNIT1
            CMP   #2
            BEQ   @UNIT2
            CMP   #3
            BEQ   @UNIT3
            CMP   #4
            BEQ   @UNIT4
            BRA   @BADUNIT      ; only 4 partitions are supported

@UNIT1:     LDA   SLOT16        ; this slot
            BRA   @STORE
@UNIT2:     LDA   SLOT16
            ORA   #$80          ; drive 1
            BRA   @STORE
@UNIT3:     LDA   SLOT16
            DEC   A             ; phantom slot
            BRA   @STORE
@UNIT4:     LDA   SLOT16
            DEC   A             ; phantom slot
            ORA   #$80          ; drive 1

@STORE:     STA   DSNUMBER      ; store in ProDOS variable

            LDY   #2            ; get buffer pointer
            LDA   (SMPARAMLIST),Y
            STA   BUFFER
            INY
            LDA   (SMPARAMLIST),Y
            STA   BUFFER+1

            INY                 ; get block number
            LDA   (SMPARAMLIST),Y
            STA   BLOCKNUM
            INY
            LDA   (SMPARAMLIST),Y
            STA   BLOCKNUM+1
            INY
            LDA   (SMPARAMLIST),Y
            BNE   @BADBLOCK     ; bit 23-16 need to be 0

            CLC
            RTS

@BADUNIT:   LDA   #ERR_BADUNIT
            SEC
            RTS

@BADBLOCK:  LDA   #ERR_BADBLOCK
            SEC
            RTS


; Smartport Format command
;
; supported, but doesn't do anything
; unit number must not be 0
;
SMFORMAT:   LDA   DRVNUM,Y
            BEQ   @ERROR
            LDA   #NO_ERR
            CLC
            RTS

@ERROR:     LDA   #ERR_BADUNIT
            SEC
            RTS


; Smartport Init comand
;
; supported, but doesn't do anything
; unit number must be 0
;
SMINIT:     LDA   DRVNUM,Y
            CLC
            BEQ   @END          ; error if not 0
            LDA   #ERR_BADUNIT
            SEC
@END:       RTS


; Smartport Open and Close commands
;
; supported for character devices, only
;
SMOPEN:
SMCLOSE:    LDA   #ERR_BADCMD
            SEC
            RTS


; Smartport Read Character and Write Character
;
; only 512-byte block operations are supported
;
SMREADCHAR:
SMWRITECHAR:
            LDA   #ERR_IOERR
            SEC
            RTS


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

; Status 3 command data
STATUS3DATA:
            .byt 16, "APPLE][SD       " ; ID length and string, padded
            .byt $02                    ; hard disk
            .byt $00                    ; removable hard disk
            .word $0012                 ; driver version
            .assert (*-STATUS3DATA)=21, error, "STATUS3DATA must be 21 bytes long"
