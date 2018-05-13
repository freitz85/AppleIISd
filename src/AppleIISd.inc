;*******************************
;
; Apple][Sd Firmware
; Version 1.2
; Defines
;
; (c) Florian Reitz, 2017 - 2018
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************

; ZP equates
SLOT16      :=    $2B         ; $s0 -> slot * 16
SLOT        :=    $3D         ; $0s
CMDLO       :=    $40
CMDHI       :=    $41

; ProDOS equates
DCMD        :=    $42         ; Command code
DSNUMBER    :=    $43         ; drive / slot number
BUFFER      :=    $44         ; buffer pointer
BLOCK       :=    $46         ; block number

; Smartport equates
SMPARAM     :=    $43         ; parameter count
SMUNIT      :=    $44         ; unit number
SMBUFF      :=    $45         ; buffer pointer
SMSTAT      :=    $47         ; status / control code
SMBLOCK     :=    $47         ; block number
SMCOUNT     :=    $47         ; byte count
SMADDR      :=    $49         ; address for read

; Ram equates
R30         :=    $0478
R31         :=    $04F8
R32         :=    $0578
R33         :=    $05F8
CURSLOT     :=    $07F8       ; $Cs

; Slot equates
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

; Error codes
NO_ERR          =     $00
ERR_BAD_CMD     =     $01
ERR_BAD_PCNT    =     $04
ERR_BUS_ERR     =     $06
ERR_BAD_UNIT    =     $11
ERR_BAD_CTL     =     $21
ERR_BAD_CTL_PARM =    $22
ERR_IO_ERR      =     $27
ERR_NO_DRIVE    =     $28
ERR_NO_WRITE    =     $2B
ERR_BAD_BLOCK   =     $2D
ERR_OFF_LINE    =     $2F
