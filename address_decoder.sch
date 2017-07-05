VERSION 6
BEGIN SCHEMATIC
    BEGIN ATTR DeviceFamilyName "xc9500xl"
        DELETE all:0
        EDITNAME all:0
        EDITTRAIT all:0
    END ATTR
    BEGIN NETLIST
        SIGNAL NIO_STB
        SIGNAL XLXN_4
        SIGNAL A10
        SIGNAL A9
        SIGNAL A8
        SIGNAL XLXN_10
        SIGNAL XLXN_11
        SIGNAL NOE
        SIGNAL CLK
        SIGNAL XLXN_14
        SIGNAL A10_B
        SIGNAL A9_B
        SIGNAL A8_B
        SIGNAL NIO_SEL
        SIGNAL XLXN_19
        PORT Input NIO_STB
        PORT Input A10
        PORT Input A9
        PORT Input A8
        PORT Output NOE
        PORT Input CLK
        PORT Output A10_B
        PORT Output A9_B
        PORT Output A8_B
        PORT Input NIO_SEL
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
        BEGIN BLOCKDEF nand2
            TIMESTAMP 2001 3 9 11 23 50
            LINE N 0 -64 64 -64 
            LINE N 0 -128 64 -128 
            LINE N 256 -96 216 -96 
            CIRCLE N 192 -108 216 -84 
            LINE N 64 -48 64 -144 
            LINE N 64 -144 144 -144 
            LINE N 144 -48 64 -48 
            ARC N 96 -144 192 -48 144 -48 144 -144 
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
        BEGIN BLOCKDEF and4b1
            TIMESTAMP 2001 5 11 10 43 32
            LINE N 0 -64 40 -64 
            CIRCLE N 40 -76 64 -52 
            LINE N 0 -128 64 -128 
            LINE N 0 -192 64 -192 
            LINE N 0 -256 64 -256 
            LINE N 256 -160 192 -160 
            LINE N 64 -64 64 -256 
            LINE N 144 -112 64 -112 
            ARC N 96 -208 192 -112 144 -112 144 -208 
            LINE N 64 -208 144 -208 
        END BLOCKDEF
        BEGIN BLOCK XLXI_13 nand2
            PIN I0 NIO_SEL
            PIN I1 NIO_STB
            PIN O XLXN_4
        END BLOCK
        BEGIN BLOCK XLXI_14 nand2
            PIN I0 XLXN_11
            PIN I1 XLXN_4
            PIN O NOE
        END BLOCK
        BEGIN BLOCK XLXI_16 fdrs
            PIN C CLK
            PIN D XLXN_14
            PIN R XLXN_10
            PIN S XLXN_19
            PIN Q XLXN_11
        END BLOCK
        BEGIN BLOCK XLXI_17 vcc
            PIN P XLXN_14
        END BLOCK
        BEGIN BLOCK XLXI_18 and2
            PIN I0 A10
            PIN I1 NIO_SEL
            PIN O A10_B
        END BLOCK
        BEGIN BLOCK XLXI_19 and2
            PIN I0 A9
            PIN I1 NIO_SEL
            PIN O A9_B
        END BLOCK
        BEGIN BLOCK XLXI_20 and2
            PIN I0 A8
            PIN I1 NIO_SEL
            PIN O A8_B
        END BLOCK
        BEGIN BLOCK XLXI_22 inv
            PIN I NIO_SEL
            PIN O XLXN_19
        END BLOCK
        BEGIN BLOCK XLXI_23 and4b1
            PIN I0 NIO_STB
            PIN I1 A10
            PIN I2 A9
            PIN I3 A8
            PIN O XLXN_10
        END BLOCK
    END NETLIST
    BEGIN SHEET 1 3520 2720
        IOMARKER 320 496 NIO_STB R180 28
        IOMARKER 320 560 NIO_SEL R180 28
        BEGIN BRANCH NIO_STB
            WIRE 320 496 368 496
            WIRE 368 496 368 640
            WIRE 368 640 608 640
            WIRE 368 496 1120 496
        END BRANCH
        BEGIN BRANCH XLXN_4
            WIRE 1376 528 1744 528
        END BRANCH
        BEGIN BRANCH A10
            WIRE 320 704 592 704
            WIRE 592 704 608 704
            WIRE 592 704 592 1168
            WIRE 592 1168 1088 1168
        END BRANCH
        BEGIN BRANCH A9
            WIRE 320 768 528 768
            WIRE 528 768 608 768
            WIRE 528 768 528 1312
            WIRE 528 1312 1088 1312
        END BRANCH
        BEGIN BRANCH A8
            WIRE 320 832 480 832
            WIRE 480 832 608 832
            WIRE 480 832 480 1456
            WIRE 480 1456 1088 1456
        END BRANCH
        IOMARKER 320 704 A10 R180 28
        IOMARKER 320 768 A9 R180 28
        IOMARKER 320 832 A8 R180 28
        BEGIN BRANCH NOE
            WIRE 2000 560 2032 560
        END BRANCH
        BEGIN BRANCH CLK
            WIRE 320 928 1392 928
        END BRANCH
        IOMARKER 320 928 CLK R180 28
        INSTANCE XLXI_18 1088 1232 R0
        INSTANCE XLXI_19 1088 1376 R0
        INSTANCE XLXI_20 1088 1520 R0
        BEGIN BRANCH A10_B
            WIRE 1344 1136 1744 1136
        END BRANCH
        BEGIN BRANCH A9_B
            WIRE 1344 1280 1744 1280
        END BRANCH
        BEGIN BRANCH A8_B
            WIRE 1344 1424 1744 1424
        END BRANCH
        INSTANCE XLXI_17 976 800 R0
        BEGIN BRANCH XLXN_14
            WIRE 1040 800 1392 800
        END BRANCH
        INSTANCE XLXI_13 1120 624 R0
        BEGIN BRANCH XLXN_11
            WIRE 1728 592 1744 592
            WIRE 1728 592 1728 656
            WIRE 1728 656 1840 656
            WIRE 1840 656 1840 800
            WIRE 1776 800 1840 800
        END BRANCH
        IOMARKER 1744 1136 A10_B R0 28
        IOMARKER 1744 1280 A9_B R0 28
        IOMARKER 1744 1424 A8_B R0 28
        IOMARKER 2032 560 NOE R0 28
        INSTANCE XLXI_14 1744 656 R0
        INSTANCE XLXI_16 1392 1056 R0
        BEGIN BRANCH XLXN_10
            WIRE 864 736 880 736
            WIRE 880 736 880 1024
            WIRE 880 1024 1392 1024
        END BRANCH
        BEGIN BRANCH NIO_SEL
            WIRE 320 560 944 560
            WIRE 944 560 1088 560
            WIRE 1088 560 1120 560
            WIRE 1088 560 1088 704
            WIRE 1088 704 1120 704
            WIRE 944 560 944 1104
            WIRE 944 1104 1088 1104
            WIRE 944 1104 944 1248
            WIRE 944 1248 944 1392
            WIRE 944 1392 1088 1392
            WIRE 944 1248 1088 1248
        END BRANCH
        BEGIN BRANCH XLXN_19
            WIRE 1344 704 1360 704
            WIRE 1360 704 1392 704
        END BRANCH
        INSTANCE XLXI_22 1120 736 R0
        INSTANCE XLXI_23 608 576 M180
    END SHEET
END SCHEMATIC
