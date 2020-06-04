;*******************************
;
; Apple][Sd Firmware
; Version 1.2.2
; Defines
;
; (c) Florian Reitz, 2017 - 2020
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************

; ZP locations
PSAVE       :=    $3D         ; P save location
SLOT16      :=    $3E         ; $s0 -> slot * 16
SLOT        :=    $3F         ; $0s
CMDLO       :=    $40
CMDHI       :=    $41
PDZPAREA    =     PSAVE      
PDZPSIZE    =     CMDHI-PDZPAREA+1

; ProDOS
DCMD        :=    $42         ; Command code
DSNUMBER    :=    $43         ; drive / slot number
BUFFER      :=    $44         ; buffer pointer, two bytes
BLOCKNUM    :=    $46         ; block number, two bytes

; Smartport
SMPARAMLIST :=    $48         ; parameter list, two bytes
SMCMDLIST   :=    $4A         ; command list, two bytes
SMCSCODE    :=    $4C
SMZPAREA    =     SMPARAMLIST
SMZPSIZE    =     SMCSCODE-SMZPAREA+1
SMCMD       =     DCMD


; Ram equates, access with SLOT offset
R30         :=    $0478
R31         :=    $04F8
R32         :=    $0578
R33         :=    $05F8
DRVNUM      :=    $0678
CURSLOT     :=    $07F8       ; $Cs

; Rom equates
OAPPLE      :=    $C061       ; open apple key
DATA        :=    $C080
CTRL        :=    DATA+1
SS          :=    DATA+3

; Constants
DUMMY       =     $FF
FRX         =     $10         ; CTRL register
ECE         =     $04
SS0         =     $01         ; SS register
SDHC        =     $10
WP          =     $20
CD          =     $40
CARD_INIT   =     $80

SMDRIVERVER =     $120B       ; Version 1.2 Beta

; Error codes
NO_ERR          =     $00
ERR_BADCMD      =     $01
ERR_BADPCNT     =     $04
ERR_BUSERR      =     $06
ERR_BADUNIT     =     $11
ERR_NOINT       =     $1F
ERR_BADCTL      =     $21
ERR_BADCTLPARM  =     $22
ERR_IOERR       =     $27
ERR_NODRIVE     =     $28
ERR_NOWRITE     =     $2B
ERR_BADBLOCK    =     $2D
ERR_OFFLINE     =     $2F
