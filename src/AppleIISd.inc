;*******************************
;
; Apple][Sd Firmware
; Version 1.1
; Defines
;
; (c) Florian Reitz, 2017
;
; X register usually contains SLOT16
; Y register is used for counting or SLOT
;
;*******************************

; Memory defines

SLOT16      :=    $2B         ; $s0 -> slot * 16
SLOT        :=    $3D         ; $0s
CMDLO       :=    $40
CMDHI       :=    $41

DCMD        :=    $42         ; Command code
BUFFER      :=    $44         ; Buffer address
BLOCK       :=    $46         ; Block number

R30         :=    $0478
R31         :=    $04F8
R32         :=    $0578
R33         :=    $05F8
CURSLOT     :=    $07F8       ; $Cs
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
