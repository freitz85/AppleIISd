VERSION 6
BEGIN SCHEMATIC
    BEGIN ATTR DeviceFamilyName "xc9500xl"
        DELETE all:0
        EDITNAME all:0
        EDITTRAIT all:0
    END ATTR
    BEGIN NETLIST
        SIGNAL A10
        SIGNAL A9
        SIGNAL A8
        SIGNAL XLXN_10
        SIGNAL CLK
        SIGNAL XLXN_14
        SIGNAL B10
        SIGNAL B9
        SIGNAL B8
        SIGNAL NOE
        SIGNAL XLXN_29
        SIGNAL NIO_SEL
        SIGNAL NIO_STB
        SIGNAL XLXN_38
        SIGNAL XLXN_46
        PORT Input A10
        PORT Input A9
        PORT Input A8
        PORT Input CLK
        PORT Output B10
        PORT Output B9
        PORT Output B8
        PORT Output NOE
        PORT Input NIO_SEL
        PORT Input NIO_STB
        BEGIN BLOCKDEF fdrs
            TIMESTAMP 2001 3 9 11 23 0
            LINE N 0 -128 64 -128 
            LINE N 0 -256 64 -256 
            LINE N 384 -256 320 -256 
            LINE N 0 -32 64 -32 
            LINE N 0 -352 64 -352 
            RECTANGLE N 64 -320 320 -64 
            LINE N 192 -64 192 -32 
            LINE N 192 -32 64 -32 
            LINE N 64 -112 80 -128 
            LINE N 80 -128 64 -144 
            LINE N 192 -320 192 -352 
            LINE N 192 -352 64 -352 
        END BLOCKDEF
        BEGIN BLOCKDEF inv
            TIMESTAMP 2001 3 9 11 23 50
            LINE N 0 -32 64 -32 
            LINE N 224 -32 160 -32 
            LINE N 64 -64 128 -32 
            LINE N 128 -32 64 0 
            LINE N 64 0 64 -64 
            CIRCLE N 128 -48 160 -16 
        END BLOCKDEF
        BEGIN BLOCKDEF vcc
            TIMESTAMP 2001 3 9 11 23 11
            LINE N 96 -64 32 -64 
            LINE N 64 0 64 -32 
            LINE N 64 -32 64 -64 
        END BLOCKDEF
        BEGIN BLOCKDEF and2
            TIMESTAMP 2001 5 11 10 41 37
            LINE N 0 -64 64 -64 
            LINE N 0 -128 64 -128 
            LINE N 256 -96 192 -96 
            ARC N 96 -144 192 -48 144 -48 144 -144 
            LINE N 144 -48 64 -48 
            LINE N 64 -144 144 -144 
            LINE N 64 -48 64 -144 
        END BLOCKDEF
        BEGIN BLOCKDEF and4
            TIMESTAMP 2001 5 11 10 43 14
            LINE N 144 -112 64 -112 
            ARC N 96 -208 192 -112 144 -112 144 -208 
            LINE N 64 -208 144 -208 
            LINE N 64 -64 64 -256 
            LINE N 256 -160 192 -160 
            LINE N 0 -256 64 -256 
            LINE N 0 -192 64 -192 
            LINE N 0 -128 64 -128 
            LINE N 0 -64 64 -64 
        END BLOCKDEF
        BEGIN BLOCK XLXI_16 fdrs
            PIN C CLK
            PIN D XLXN_14
            PIN R XLXN_10
            PIN S XLXN_46
            PIN Q XLXN_29
        END BLOCK
        BEGIN BLOCK XLXI_17 vcc
            PIN P XLXN_14
        END BLOCK
        BEGIN BLOCK XLXI_18 and2
            PIN I0 A10
            PIN I1 XLXN_38
            PIN O B10
        END BLOCK
        BEGIN BLOCK XLXI_19 and2
            PIN I0 A9
            PIN I1 XLXN_38
            PIN O B9
        END BLOCK
        BEGIN BLOCK XLXI_20 and2
            PIN I0 A8
            PIN I1 XLXN_38
            PIN O B8
        END BLOCK
        BEGIN BLOCK XLXI_22 inv
            PIN I NIO_SEL
            PIN O XLXN_46
        END BLOCK
        BEGIN BLOCK XLXI_29 inv
            PIN I XLXN_29
            PIN O NOE
        END BLOCK
        BEGIN BLOCK XLXI_30 and4
            PIN I0 A8
            PIN I1 A9
            PIN I2 A10
            PIN I3 XLXN_38
            PIN O XLXN_10
        END BLOCK
        BEGIN BLOCK XLXI_31 inv
            PIN I NIO_STB
            PIN O XLXN_38
        END BLOCK
    END NETLIST
    BEGIN SHEET 1 3520 2720
        BEGIN BRANCH A10
            WIRE 320 704 592 704
            WIRE 592 704 704 704
            WIRE 592 704 592 992
            WIRE 592 992 1088 992
        END BRANCH
        BEGIN BRANCH A9
            WIRE 320 768 528 768
            WIRE 528 768 704 768
            WIRE 528 768 528 1136
            WIRE 528 1136 1088 1136
        END BRANCH
        BEGIN BRANCH A8
            WIRE 320 832 464 832
            WIRE 464 832 704 832
            WIRE 464 832 464 1280
            WIRE 464 1280 1088 1280
        END BRANCH
        IOMARKER 320 704 A10 R180 28
        IOMARKER 320 768 A9 R180 28
        IOMARKER 320 832 A8 R180 28
        BEGIN BRANCH CLK
            WIRE 320 576 912 576
            WIRE 912 576 912 640
            WIRE 912 640 992 640
        END BRANCH
        BEGIN BRANCH B10
            WIRE 1344 960 1360 960
            WIRE 1360 960 1664 960
        END BRANCH
        BEGIN BRANCH B9
            WIRE 1344 1104 1360 1104
            WIRE 1360 1104 1664 1104
        END BRANCH
        BEGIN BRANCH B8
            WIRE 1344 1248 1360 1248
            WIRE 1360 1248 1664 1248
        END BRANCH
        BEGIN BRANCH NOE
            WIRE 1616 512 1664 512
        END BRANCH
        BEGIN BRANCH XLXN_29
            WIRE 1376 512 1392 512
        END BRANCH
        BEGIN BRANCH NIO_SEL
            WIRE 320 368 352 368
        END BRANCH
        BEGIN BRANCH NIO_STB
            WIRE 320 640 336 640
        END BRANCH
        IOMARKER 320 368 NIO_SEL R180 28
        IOMARKER 320 640 NIO_STB R180 28
        INSTANCE XLXI_31 336 672 R0
        BEGIN BRANCH XLXN_38
            WIRE 560 640 672 640
            WIRE 672 640 704 640
            WIRE 672 640 672 928
            WIRE 672 928 1088 928
            WIRE 672 928 672 1072
            WIRE 672 1072 1088 1072
            WIRE 672 1072 672 1216
            WIRE 672 1216 1088 1216
        END BRANCH
        INSTANCE XLXI_30 704 896 R0
        BEGIN BRANCH XLXN_10
            WIRE 960 736 976 736
            WIRE 976 736 992 736
        END BRANCH
        BEGIN BRANCH XLXN_14
            WIRE 848 496 848 512
            WIRE 848 512 992 512
        END BRANCH
        IOMARKER 320 576 CLK R180 28
        INSTANCE XLXI_17 784 496 R0
        INSTANCE XLXI_22 352 400 R0
        BEGIN BRANCH XLXN_46
            WIRE 576 368 592 368
            WIRE 592 368 992 368
            WIRE 992 368 992 416
        END BRANCH
        INSTANCE XLXI_16 992 768 R0
        INSTANCE XLXI_29 1392 544 R0
        IOMARKER 1664 512 NOE R0 28
        INSTANCE XLXI_18 1088 1056 R0
        INSTANCE XLXI_19 1088 1200 R0
        INSTANCE XLXI_20 1088 1344 R0
        IOMARKER 1664 960 B10 R0 28
        IOMARKER 1664 1104 B9 R0 28
        IOMARKER 1664 1248 B8 R0 28
    END SHEET
END SCHEMATIC
