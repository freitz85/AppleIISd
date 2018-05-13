;*******************************
;
; Apple][Sd Firmware
; Version 1.2
; ProDOS functions
;
; (c) Florian Reitz, 2017 - 2018
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************
            
.export STATUS
.export READ
.export WRITE

.import COMMAND
.import SDCMD
.import GETBLOCK
.import WRPROT
.import GETR1
.import GETR3

.include "AppleIISd.inc"
.segment "EXTROM"


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
; X       - Blocks avail (low byte)
; Y       - Blocks avail (high byte)
;
;*******************************

STATUS:     LDA   NO_ERR     ; no error
            JSR   WRPROT
            BCC   @DONE
            LDA   ERR_NO_WRITE; card write protected

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
            LDA   NO_ERR

@DONE:      PHP
            PHA
            LDA   SS,X
            ORA   #SS0
            STA   SS,X        ; disable /CS
            PLA
            PLP
            RTS

@ERROR:     SEC               ; an error occured
            LDA   ERR_IO_ERR
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
            LDA   NO_ERR

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
            LDA   ERR_IO_ERR
            BRA   @DONE

@WPERROR:   SEC
            LDA   ERR_NO_WRITE
            BRA   @DONE
