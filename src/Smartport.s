;*******************************
;
; Apple][Sd Firmware
; Version 1.2
; Smartport functions
;
; (c) Florian Reitz, 2017
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************
            
.export SMARTPORT


.include "AppleIISd.inc"
.segment "SLOTROM"


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

SMARTPORT:  PLA               ; pull return address
            TAY
         