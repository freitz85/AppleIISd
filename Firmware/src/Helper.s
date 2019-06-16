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

SDCMD:      .IFPC02
            PHY
            .ELSE
            TYA
            PHA
            .ENDIF
            LDY   #0
@LOOP:      LDA   (CMDLO),Y
            STA   DATA,X
@WAIT:      .IFPC02
            BIT   CTRL,X      ; TC is in N
            BPL   @WAIT
            .ELSE
            LDA   #TC
            AND   CTRL,X
            BNE   @WAIT
            .ENDIF
            INY
            CPY   #6
            BCC   @LOOP
            .IFPC02
            PLY
            .ELSE
            PLA
            TAY
            .ENDIF
            RTS


;*******************************
;
; Get R1
; R1 is in A
;
;*******************************

GETR1:      LDA   #DUMMY
            STA   DATA,X
@WAIT:      .IFPC02
            BIT   CTRL,X      ; TC is in N
            BPL   @WAIT
            .ELSE
            LDA   #TC
            AND   CTRL,X
            BNE   @WAIT
            .ENDIF
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
            .IFPC02
            PHY               ; save Y
            .ELSE
            TYA
            PHA
            .ENDIF
            LDY   #04         ; load counter
            JMP   @WAIT       ; first byte is already there 
@LOOP:      LDA   #DUMMY      ; send dummy
            STA   DATA,X
@WAIT:      .IFPC02
            BIT   CTRL,X      ; TC is in N
            BPL   @WAIT
            .ELSE
            LDA   #TC
            AND   CTRL,X
            BNE   @WAIT
            .ENDIF
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
            .IFPC02
            PLY               ; restore Y
            .ELSE
            PLA
            TAY
            .ENDIF
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

GETBLOCK:   .IFPC02
            PHX               ; save X
            PHY               ; save Y
            .ELSE
            TXA
            PHA               ; save X
            TYA
            PHA               ; save y
            .ENDIF
            LDX   SLOT        ; SLOT is now in X
            LDY   SLOT16
            LDA   BLOCKNUM    ; store block num
            STA   R33,X       ; in R30-R33
            LDA   BLOCKNUM+1
            STA   R32,X
            .IFPC02
            STZ   R31,X
            STZ   R30,X
            .ELSE
            LDA   #0
            STA   R31,X
            STA   R30,X
            .ENDIF

            TYA               ; get SLOT16
            EOR   DSNUMBER
            AND   #$70        ; check only slot bits
            BEQ   @DRIVE      ; it is our slot
            LDA   #2          ; it is a phantom slot
            STA   R31,X

@DRIVE:     BIT   DSNUMBER    ; drive number
            BPL   @SDHC       ; D1
            LDA   R31,X       ; D2
            .IFPC02
            INC   A
            .ELSE
            ADC   #1
            .ENDIF
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
  
 @END:      .IFPC02
            PLY               ; restore Y
            PLX               ; restore X
            .ELSE
            PLA
            TAY               ; restore y
            PLA
            TAX               ; restore x
            .ENDIF
            RTS


;*******************************
;
; Send SD command
; X must contain SLOT16
; Cmd is in A
;
; Y is destroyed
;
;*******************************

COMMAND:    LDY   SLOT
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
            AND   SS,X        ; 1: card out
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
            AND   SS,X        ; 1: write disabled
            CLC
            BEQ   @DONE
            SEC
@DONE:      PLA
            RTS
