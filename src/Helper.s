;*******************************
;
; Apple][Sd Firmware
; Version 1.2
; Helper functions
;
; (c) Florian Reitz, 2017 - 2018
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************
            
.export WRDATA
.export COMMAND
.export SDCMD
.export SDCMD0
.export GETBLOCK
.export CARDDET
.export WRPROT
.export GETR1
.export GETR3

.include "AppleIISd.inc"
.segment "EXTROM"

WRDATA:	STA	DATA,X
@WAIT:	BIT	CTRL,X
	BPL	@WAIT
	RTS
;********************************
; Wait for card ready
; C set on timeout
;********************************
WREADY:
	PHA
	LDA   #$FE
@LOOP:	PHA   ; counter
	LDA   #DUMMY
        JSR   WRDATA
        LDA   DATA,X
        CMP   #$FF
        BNE   @AGAIN
        PLA
        PLA
        CLC
        RTS
@AGAIN: PLA
        CMP   #$FF
        BEQ   @TOUT
        SBC   #0 ; dec a
	JMP   @LOOP
@TOUT:  PLA
	SEC
	RTS
	
;*******************************
;
; Send SD command
; Call with command in CMDHI and CMDLO
; Returns iwth carry set on timeout
;
;*******************************

SDCMD:      JSR   WREADY
            BCC   SDCMD0
            RTS
SDCMD0:     PHY
            LDY   #0
@LOOP:      LDA   (CMDLO),Y
            JSR   WRDATA
            INY
            CPY   #6
            BCC   @LOOP
            PLY
            CLC
            RTS


;*******************************
;
; Get R1
; R1 is in A
;
;*******************************

GETR1:      PHY
            LDY   #10
@AGAIN:     LDA   #DUMMY
            JSR   WRDATA
            LDA   DATA,X      ; get response
            BIT   #$80
            BEQ   @CONT       ; wait for MSB=0
            DEY
            BNE   @AGAIN
            PLY
            RTS
@CONT:      PHA
            LDA   #DUMMY
            JSR   WRDATA      ; send another dummy
            PLA               ; restore R1
            PLY
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
            JMP   @LOAD       ; first byte is already there 
@LOOP:      LDA   #DUMMY      ; send dummy
            JSR   WRDATA
@LOAD:      LDA   DATA,X
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
            JSR   WRDATA      ; send another dummy
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
            LDX   SLOT        ; SLOT is now in X
            LDY   SLOT16
            LDA   BLOCKNUM    ; store block num
            STA   R33,X       ; in R30-R33
            LDA   BLOCKNUM+1
            STA   R32,X
            STZ   R31,X
            STZ   R30,X

            TYA               ; get SLOT16
            EOR   DSNUMBER
            AND   #$70        ; check only slot bits
            BEQ   @DRIVE      ; it is our slot
            LDA   #2          ; it is a phantom slot
            STA   R31,X

@DRIVE:     BIT   DSNUMBER    ; drive number
            BPL   @SDHC       ; D1
            LDA   R31,X       ; D2
            INC   A
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

COMMAND:    
            JSR   WREADY
            BCC   @CONT
            RTS
@CONT:      PHY               ; save Y
            LDY   SLOT
            JSR   WRDATA      ; send command
            LDA   R30,Y       ; get arg from R30 on
            JSR   WRDATA
            LDA   R31,Y
            JSR   WRDATA
            LDA   R32,Y
            JSR   WRDATA
            LDA   R33,Y
            JSR   WRDATA
            LDA   #DUMMY
            JSR   WRDATA      ; dummy crc
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
