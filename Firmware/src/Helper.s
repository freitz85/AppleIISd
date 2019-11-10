;*******************************
;
; Apple][Sd Firmware
; Version 1.3
; Helper functions
;
; (c) Florian Reitz, 2017 - 2019
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************
            
.export COMMAND
.export SDCMD
.export GETBLOCK
.export CARDDET
.export WRPROT
.export GETR1
.export GETR3

.include "AppleIISd.inc"
.segment "EXTROM"


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
            BMI   GETR1       ; wait for MSB=0
            PHA
            LDA   #DUMMY
            STA   DATA,X      ; send another dummy
            PLA               ; restore R1
            RTS

;*******************************
;
; Get R3 or R7
; R1 is in A
; R3 is in scratchpad ram
;
;*******************************

GETR3:      JSR   GETR1       ; get R1 first
            PHA               ; save R1
            PHY               ; save Y
            LDY   #04         ; load counter
            JMP   @WAIT       ; first byte is already there 
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
            STA   R30,Y       ; R30 is MSB
            PLY               ; restore Y
            LDA   #DUMMY
            STA   DATA,X      ; send another dummy
            PLA               ; restore R1
            RTS


;*******************************
;
; Calculate block address
; Unit number is in $43 DSSS0000 / DSSS00DD
; Block no is in $46-47
; Address is in R30-R33
;
; Starting ProDOS 2.5a5 the unit number
; has been enhanced to DSSS00DD
;
;*******************************

GETBLOCK:   PHX               ; save X
            PHY               ; save Y
            LDX   SLOT        ; SLOT is now in X
            LDY   SLOT16
            LDA   BLOCKNUM    ; store block num
            STA   R33,X       ; in R30-R33
            LDA   BLOCKNUM+1
            STA   R32,X
            STZ   R30,X

.if 1
            LDA   DSNUMBER    ; calculate drive number
            ASL   A
            AND   #$07
            ADC   #$01
            STA   R31,X
.else
            LDA   DSNUMBER
            AND   #$03        ; mask extended drive bits (bits 0-1)
            STA   R31,X
            BIT   DSNUMBER    ; check old drive number (bit 7)
            BPL   @PHANTOM
            INC   A           ; increase by one
            STA   R31,X
.endif
.if 0
@PHANTOM:   TYA               ; get SLOT16
            EOR   DSNUMBER
            AND   #$70        ; check only slot bits
            BEQ   @SDHC       ; it is our slot
            LDA   R31,X       ; it is a phantom slot, multiply by 16
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            STA   R31,X
.endif

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
  
@END:       PLY               ; restore Y
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
; X must contain SLOT16
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
; X must contain SLOT16
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
