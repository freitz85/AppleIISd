<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="xc9500xl" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="A10" />
        <signal name="A9" />
        <signal name="A8" />
        <signal name="XLXN_10" />
        <signal name="CLK" />
        <signal name="XLXN_14" />
        <signal name="B10" />
        <signal name="B9" />
        <signal name="B8" />
        <signal name="NIO_SEL" />
        <signal name="NIO_STB" />
        <signal name="XLXN_38" />
        <signal name="XLXN_46" />
        <signal name="XLXN_47" />
        <signal name="NDEV_SEL" />
        <signal name="NOE" />
        <signal name="XLXN_53" />
        <signal name="RNW" />
        <signal name="XLXN_55" />
        <port polarity="Input" name="A10" />
        <port polarity="Input" name="A9" />
        <port polarity="Input" name="A8" />
        <port polarity="Input" name="CLK" />
        <port polarity="Output" name="B10" />
        <port polarity="Output" name="B9" />
        <port polarity="Output" name="B8" />
        <port polarity="Input" name="NIO_SEL" />
        <port polarity="Input" name="NIO_STB" />
        <port polarity="Input" name="NDEV_SEL" />
        <port polarity="Output" name="NOE" />
        <port polarity="Input" name="RNW" />
        <blockdef name="fdrs">
            <timestamp>2001-3-9T11:23:0</timestamp>
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="64" y1="-256" y2="-256" x1="0" />
            <line x2="320" y1="-256" y2="-256" x1="384" />
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="64" y1="-352" y2="-352" x1="0" />
            <rect width="256" x="64" y="-320" height="256" />
            <line x2="192" y1="-64" y2="-32" x1="192" />
            <line x2="64" y1="-32" y2="-32" x1="192" />
            <line x2="80" y1="-112" y2="-128" x1="64" />
            <line x2="64" y1="-128" y2="-144" x1="80" />
            <line x2="192" y1="-320" y2="-352" x1="192" />
            <line x2="64" y1="-352" y2="-352" x1="192" />
        </blockdef>
        <blockdef name="inv">
            <timestamp>2001-3-9T11:23:50</timestamp>
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="160" y1="-32" y2="-32" x1="224" />
            <line x2="128" y1="-64" y2="-32" x1="64" />
            <line x2="64" y1="-32" y2="0" x1="128" />
            <line x2="64" y1="0" y2="-64" x1="64" />
            <circle r="16" cx="144" cy="-32" />
        </blockdef>
        <blockdef name="vcc">
            <timestamp>2001-3-9T11:23:11</timestamp>
            <line x2="32" y1="-64" y2="-64" x1="96" />
            <line x2="64" y1="0" y2="-32" x1="64" />
            <line x2="64" y1="-32" y2="-64" x1="64" />
        </blockdef>
        <blockdef name="and2">
            <timestamp>2001-5-11T10:41:37</timestamp>
            <line x2="64" y1="-64" y2="-64" x1="0" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="192" y1="-96" y2="-96" x1="256" />
            <arc ex="144" ey="-144" sx="144" sy="-48" r="48" cx="144" cy="-96" />
            <line x2="64" y1="-48" y2="-48" x1="144" />
            <line x2="144" y1="-144" y2="-144" x1="64" />
            <line x2="64" y1="-48" y2="-144" x1="64" />
        </blockdef>
        <blockdef name="and4">
            <timestamp>2001-5-11T10:43:14</timestamp>
            <line x2="64" y1="-112" y2="-112" x1="144" />
            <arc ex="144" ey="-208" sx="144" sy="-112" r="48" cx="144" cy="-160" />
            <line x2="144" y1="-208" y2="-208" x1="64" />
            <line x2="64" y1="-64" y2="-256" x1="64" />
            <line x2="192" y1="-160" y2="-160" x1="256" />
            <line x2="64" y1="-256" y2="-256" x1="0" />
            <line x2="64" y1="-192" y2="-192" x1="0" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="64" y1="-64" y2="-64" x1="0" />
        </blockdef>
        <blockdef name="nand2">
            <timestamp>2001-3-9T11:23:50</timestamp>
            <line x2="64" y1="-64" y2="-64" x1="0" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="216" y1="-96" y2="-96" x1="256" />
            <circle r="12" cx="204" cy="-96" />
            <line x2="64" y1="-48" y2="-144" x1="64" />
            <line x2="144" y1="-144" y2="-144" x1="64" />
            <line x2="64" y1="-48" y2="-48" x1="144" />
            <arc ex="144" ey="-144" sx="144" sy="-48" r="48" cx="144" cy="-96" />
        </blockdef>
        <blockdef name="or2">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-64" y2="-64" x1="0" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="192" y1="-96" y2="-96" x1="256" />
            <arc ex="192" ey="-96" sx="112" sy="-48" r="88" cx="116" cy="-136" />
            <arc ex="48" ey="-144" sx="48" sy="-48" r="56" cx="16" cy="-96" />
            <line x2="48" y1="-144" y2="-144" x1="112" />
            <arc ex="112" ey="-144" sx="192" sy="-96" r="88" cx="116" cy="-56" />
            <line x2="48" y1="-48" y2="-48" x1="112" />
        </blockdef>
        <block symbolname="fdrs" name="XLXI_16">
            <blockpin signalname="CLK" name="C" />
            <blockpin signalname="XLXN_14" name="D" />
            <blockpin signalname="XLXN_10" name="R" />
            <blockpin signalname="XLXN_46" name="S" />
            <blockpin signalname="XLXN_47" name="Q" />
        </block>
        <block symbolname="vcc" name="XLXI_17">
            <blockpin signalname="XLXN_14" name="P" />
        </block>
        <block symbolname="and2" name="XLXI_18">
            <blockpin signalname="A10" name="I0" />
            <blockpin signalname="XLXN_38" name="I1" />
            <blockpin signalname="B10" name="O" />
        </block>
        <block symbolname="and2" name="XLXI_19">
            <blockpin signalname="A9" name="I0" />
            <blockpin signalname="XLXN_38" name="I1" />
            <blockpin signalname="B9" name="O" />
        </block>
        <block symbolname="and2" name="XLXI_20">
            <blockpin signalname="A8" name="I0" />
            <blockpin signalname="XLXN_38" name="I1" />
            <blockpin signalname="B8" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_22">
            <blockpin signalname="NIO_SEL" name="I" />
            <blockpin signalname="XLXN_46" name="O" />
        </block>
        <block symbolname="and4" name="XLXI_30">
            <blockpin signalname="A8" name="I0" />
            <blockpin signalname="A9" name="I1" />
            <blockpin signalname="A10" name="I2" />
            <blockpin signalname="XLXN_38" name="I3" />
            <blockpin signalname="XLXN_10" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_31">
            <blockpin signalname="NIO_STB" name="I" />
            <blockpin signalname="XLXN_38" name="O" />
        </block>
        <block symbolname="nand2" name="XLXI_32">
            <blockpin signalname="XLXN_47" name="I0" />
            <blockpin signalname="NDEV_SEL" name="I1" />
            <blockpin signalname="XLXN_55" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_33">
            <blockpin signalname="RNW" name="I" />
            <blockpin signalname="XLXN_53" name="O" />
        </block>
        <block symbolname="or2" name="XLXI_34">
            <blockpin signalname="XLXN_55" name="I0" />
            <blockpin signalname="XLXN_53" name="I1" />
            <blockpin signalname="NOE" name="O" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <branch name="A10">
            <wire x2="592" y1="704" y2="704" x1="320" />
            <wire x2="704" y1="704" y2="704" x1="592" />
            <wire x2="592" y1="704" y2="992" x1="592" />
            <wire x2="1088" y1="992" y2="992" x1="592" />
        </branch>
        <branch name="A9">
            <wire x2="528" y1="768" y2="768" x1="320" />
            <wire x2="704" y1="768" y2="768" x1="528" />
            <wire x2="528" y1="768" y2="1136" x1="528" />
            <wire x2="1088" y1="1136" y2="1136" x1="528" />
        </branch>
        <branch name="A8">
            <wire x2="464" y1="832" y2="832" x1="320" />
            <wire x2="704" y1="832" y2="832" x1="464" />
            <wire x2="464" y1="832" y2="1280" x1="464" />
            <wire x2="1088" y1="1280" y2="1280" x1="464" />
        </branch>
        <iomarker fontsize="28" x="320" y="704" name="A10" orien="R180" />
        <iomarker fontsize="28" x="320" y="768" name="A9" orien="R180" />
        <iomarker fontsize="28" x="320" y="832" name="A8" orien="R180" />
        <branch name="CLK">
            <wire x2="912" y1="576" y2="576" x1="320" />
            <wire x2="912" y1="576" y2="640" x1="912" />
            <wire x2="992" y1="640" y2="640" x1="912" />
        </branch>
        <branch name="B10">
            <wire x2="1664" y1="960" y2="960" x1="1344" />
        </branch>
        <branch name="B9">
            <wire x2="1664" y1="1104" y2="1104" x1="1344" />
        </branch>
        <branch name="B8">
            <wire x2="1664" y1="1248" y2="1248" x1="1344" />
        </branch>
        <branch name="NIO_SEL">
            <wire x2="352" y1="368" y2="368" x1="320" />
        </branch>
        <branch name="NIO_STB">
            <wire x2="336" y1="640" y2="640" x1="320" />
        </branch>
        <iomarker fontsize="28" x="320" y="368" name="NIO_SEL" orien="R180" />
        <iomarker fontsize="28" x="320" y="640" name="NIO_STB" orien="R180" />
        <instance x="336" y="672" name="XLXI_31" orien="R0" />
        <branch name="XLXN_38">
            <wire x2="672" y1="640" y2="640" x1="560" />
            <wire x2="704" y1="640" y2="640" x1="672" />
            <wire x2="672" y1="640" y2="928" x1="672" />
            <wire x2="1088" y1="928" y2="928" x1="672" />
            <wire x2="672" y1="928" y2="1072" x1="672" />
            <wire x2="1088" y1="1072" y2="1072" x1="672" />
            <wire x2="672" y1="1072" y2="1216" x1="672" />
            <wire x2="1088" y1="1216" y2="1216" x1="672" />
        </branch>
        <instance x="704" y="896" name="XLXI_30" orien="R0" />
        <branch name="XLXN_10">
            <wire x2="992" y1="736" y2="736" x1="960" />
        </branch>
        <branch name="XLXN_14">
            <wire x2="848" y1="496" y2="512" x1="848" />
            <wire x2="992" y1="512" y2="512" x1="848" />
        </branch>
        <iomarker fontsize="28" x="320" y="576" name="CLK" orien="R180" />
        <instance x="784" y="496" name="XLXI_17" orien="R0" />
        <instance x="352" y="400" name="XLXI_22" orien="R0" />
        <branch name="XLXN_46">
            <wire x2="992" y1="368" y2="368" x1="576" />
            <wire x2="992" y1="368" y2="416" x1="992" />
        </branch>
        <instance x="992" y="768" name="XLXI_16" orien="R0" />
        <instance x="1088" y="1056" name="XLXI_18" orien="R0" />
        <instance x="1088" y="1200" name="XLXI_19" orien="R0" />
        <instance x="1088" y="1344" name="XLXI_20" orien="R0" />
        <iomarker fontsize="28" x="1664" y="960" name="B10" orien="R0" />
        <iomarker fontsize="28" x="1664" y="1104" name="B9" orien="R0" />
        <iomarker fontsize="28" x="1664" y="1248" name="B8" orien="R0" />
        <instance x="1424" y="432" name="XLXI_32" orien="R0" />
        <branch name="XLXN_47">
            <wire x2="1392" y1="512" y2="512" x1="1376" />
            <wire x2="1424" y1="368" y2="368" x1="1392" />
            <wire x2="1392" y1="368" y2="512" x1="1392" />
        </branch>
        <branch name="NDEV_SEL">
            <wire x2="1424" y1="304" y2="304" x1="320" />
        </branch>
        <iomarker fontsize="28" x="320" y="304" name="NDEV_SEL" orien="R180" />
        <instance x="352" y="272" name="XLXI_33" orien="R0" />
        <branch name="NOE">
            <wire x2="2016" y1="272" y2="272" x1="2000" />
        </branch>
        <branch name="XLXN_53">
            <wire x2="1744" y1="240" y2="240" x1="576" />
        </branch>
        <branch name="RNW">
            <wire x2="352" y1="240" y2="240" x1="320" />
        </branch>
        <iomarker fontsize="28" x="320" y="240" name="RNW" orien="R180" />
        <instance x="1744" y="368" name="XLXI_34" orien="R0" />
        <branch name="XLXN_55">
            <wire x2="1696" y1="336" y2="336" x1="1680" />
            <wire x2="1744" y1="304" y2="304" x1="1696" />
            <wire x2="1696" y1="304" y2="336" x1="1696" />
        </branch>
        <iomarker fontsize="28" x="2016" y="272" name="NOE" orien="R0" />
    </sheet>
</drawing>