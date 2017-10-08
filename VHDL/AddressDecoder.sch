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
        <signal name="B10" />
        <signal name="B9" />
        <signal name="B8" />
        <signal name="NIO_SEL" />
        <signal name="XLXN_10" />
        <signal name="NDEV_SEL" />
        <signal name="NOE" />
        <signal name="RNW" />
        <signal name="NG" />
        <signal name="DATA_EN" />
        <signal name="XLXN_46" />
        <signal name="XLXN_103" />
        <signal name="NIO_STB" />
        <signal name="XLXN_110" />
        <signal name="XLXN_116" />
        <signal name="XLXN_117" />
        <signal name="XLXN_118" />
        <signal name="XLXN_119" />
        <signal name="XLXN_120" />
        <port polarity="Input" name="A10" />
        <port polarity="Input" name="A9" />
        <port polarity="Input" name="A8" />
        <port polarity="Output" name="B10" />
        <port polarity="Output" name="B9" />
        <port polarity="Output" name="B8" />
        <port polarity="Input" name="NIO_SEL" />
        <port polarity="Input" name="NDEV_SEL" />
        <port polarity="Output" name="NOE" />
        <port polarity="Input" name="RNW" />
        <port polarity="Output" name="NG" />
        <port polarity="Output" name="DATA_EN" />
        <port polarity="Input" name="NIO_STB" />
        <blockdef name="inv">
            <timestamp>2001-3-9T11:23:50</timestamp>
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="160" y1="-32" y2="-32" x1="224" />
            <line x2="128" y1="-64" y2="-32" x1="64" />
            <line x2="64" y1="-32" y2="0" x1="128" />
            <line x2="64" y1="0" y2="-64" x1="64" />
            <circle r="16" cx="144" cy="-32" />
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
        <blockdef name="and2b1">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-48" y2="-144" x1="64" />
            <line x2="144" y1="-144" y2="-144" x1="64" />
            <line x2="64" y1="-48" y2="-48" x1="144" />
            <arc ex="144" ey="-144" sx="144" sy="-48" r="48" cx="144" cy="-96" />
            <line x2="192" y1="-96" y2="-96" x1="256" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="40" y1="-64" y2="-64" x1="0" />
            <circle r="12" cx="52" cy="-64" />
        </blockdef>
        <blockdef name="fdp">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="80" y1="-112" y2="-128" x1="64" />
            <line x2="64" y1="-128" y2="-144" x1="80" />
            <rect width="256" x="64" y="-320" height="256" />
            <line x2="320" y1="-256" y2="-256" x1="384" />
            <line x2="192" y1="-320" y2="-352" x1="192" />
            <line x2="64" y1="-352" y2="-352" x1="192" />
            <line x2="64" y1="-256" y2="-256" x1="0" />
            <line x2="64" y1="-352" y2="-352" x1="0" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
        </blockdef>
        <blockdef name="gnd">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-128" y2="-96" x1="64" />
            <line x2="64" y1="-64" y2="-80" x1="64" />
            <line x2="40" y1="-64" y2="-64" x1="88" />
            <line x2="60" y1="-32" y2="-32" x1="68" />
            <line x2="52" y1="-48" y2="-48" x1="76" />
            <line x2="64" y1="-64" y2="-96" x1="64" />
        </blockdef>
        <blockdef name="and4b1">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="40" y1="-64" y2="-64" x1="0" />
            <circle r="12" cx="52" cy="-64" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="64" y1="-192" y2="-192" x1="0" />
            <line x2="64" y1="-256" y2="-256" x1="0" />
            <line x2="192" y1="-160" y2="-160" x1="256" />
            <line x2="64" y1="-64" y2="-256" x1="64" />
            <line x2="64" y1="-112" y2="-112" x1="144" />
            <arc ex="144" ey="-208" sx="144" sy="-112" r="48" cx="144" cy="-160" />
            <line x2="144" y1="-208" y2="-208" x1="64" />
        </blockdef>
        <blockdef name="or4">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="48" y1="-64" y2="-64" x1="0" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="64" y1="-192" y2="-192" x1="0" />
            <line x2="48" y1="-256" y2="-256" x1="0" />
            <line x2="192" y1="-160" y2="-160" x1="256" />
            <arc ex="112" ey="-208" sx="192" sy="-160" r="88" cx="116" cy="-120" />
            <line x2="48" y1="-208" y2="-208" x1="112" />
            <line x2="48" y1="-112" y2="-112" x1="112" />
            <line x2="48" y1="-256" y2="-208" x1="48" />
            <line x2="48" y1="-64" y2="-112" x1="48" />
            <arc ex="48" ey="-208" sx="48" sy="-112" r="56" cx="16" cy="-160" />
            <arc ex="192" ey="-160" sx="112" sy="-112" r="88" cx="116" cy="-200" />
        </blockdef>
        <block symbolname="and2" name="XLXI_36">
            <blockpin signalname="NOE" name="I0" />
            <blockpin signalname="NDEV_SEL" name="I1" />
            <blockpin signalname="NG" name="O" />
        </block>
        <block symbolname="and2b1" name="XLXI_50">
            <blockpin signalname="NDEV_SEL" name="I0" />
            <blockpin signalname="RNW" name="I1" />
            <blockpin signalname="DATA_EN" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_22">
            <blockpin signalname="NIO_SEL" name="I" />
            <blockpin signalname="XLXN_46" name="O" />
        </block>
        <block symbolname="fdp" name="XLXI_61">
            <blockpin signalname="XLXN_46" name="C" />
            <blockpin signalname="XLXN_103" name="D" />
            <blockpin signalname="XLXN_10" name="PRE" />
            <blockpin signalname="XLXN_110" name="Q" />
        </block>
        <block symbolname="gnd" name="XLXI_63">
            <blockpin signalname="XLXN_103" name="G" />
        </block>
        <block symbolname="and4b1" name="XLXI_66">
            <blockpin signalname="NIO_STB" name="I0" />
            <blockpin signalname="A8" name="I1" />
            <blockpin signalname="A9" name="I2" />
            <blockpin signalname="A10" name="I3" />
            <blockpin signalname="XLXN_10" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_72">
            <blockpin signalname="RNW" name="I" />
            <blockpin signalname="XLXN_116" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_73">
            <blockpin signalname="NDEV_SEL" name="I" />
            <blockpin signalname="XLXN_117" name="O" />
        </block>
        <block symbolname="or4" name="XLXI_74">
            <blockpin signalname="XLXN_110" name="I0" />
            <blockpin signalname="NIO_STB" name="I1" />
            <blockpin signalname="XLXN_117" name="I2" />
            <blockpin signalname="XLXN_116" name="I3" />
            <blockpin signalname="NOE" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_75">
            <blockpin signalname="NIO_STB" name="I" />
            <blockpin signalname="XLXN_119" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_76">
            <blockpin signalname="NIO_STB" name="I" />
            <blockpin signalname="XLXN_120" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_77">
            <blockpin signalname="NIO_STB" name="I" />
            <blockpin signalname="XLXN_118" name="O" />
        </block>
        <block symbolname="and2" name="XLXI_78">
            <blockpin signalname="A10" name="I0" />
            <blockpin signalname="XLXN_118" name="I1" />
            <blockpin signalname="B10" name="O" />
        </block>
        <block symbolname="and2" name="XLXI_79">
            <blockpin signalname="A9" name="I0" />
            <blockpin signalname="XLXN_119" name="I1" />
            <blockpin signalname="B9" name="O" />
        </block>
        <block symbolname="and2" name="XLXI_80">
            <blockpin signalname="A8" name="I0" />
            <blockpin signalname="XLXN_120" name="I1" />
            <blockpin signalname="B8" name="O" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <branch name="A10">
            <wire x2="592" y1="1072" y2="1072" x1="320" />
            <wire x2="592" y1="1072" y2="1360" x1="592" />
            <wire x2="1152" y1="1360" y2="1360" x1="592" />
            <wire x2="1184" y1="1360" y2="1360" x1="1152" />
            <wire x2="672" y1="1072" y2="1072" x1="592" />
        </branch>
        <branch name="A9">
            <wire x2="528" y1="1136" y2="1136" x1="320" />
            <wire x2="528" y1="1136" y2="1504" x1="528" />
            <wire x2="1152" y1="1504" y2="1504" x1="528" />
            <wire x2="1184" y1="1504" y2="1504" x1="1152" />
            <wire x2="672" y1="1136" y2="1136" x1="528" />
        </branch>
        <branch name="A8">
            <wire x2="464" y1="1200" y2="1200" x1="320" />
            <wire x2="464" y1="1200" y2="1648" x1="464" />
            <wire x2="1152" y1="1648" y2="1648" x1="464" />
            <wire x2="1184" y1="1648" y2="1648" x1="1152" />
            <wire x2="672" y1="1200" y2="1200" x1="464" />
        </branch>
        <branch name="B10">
            <wire x2="1472" y1="1328" y2="1328" x1="1440" />
            <wire x2="1664" y1="1328" y2="1328" x1="1472" />
        </branch>
        <branch name="B9">
            <wire x2="1472" y1="1472" y2="1472" x1="1440" />
            <wire x2="1664" y1="1472" y2="1472" x1="1472" />
        </branch>
        <branch name="B8">
            <wire x2="1472" y1="1616" y2="1616" x1="1440" />
            <wire x2="1664" y1="1616" y2="1616" x1="1472" />
        </branch>
        <branch name="XLXN_10">
            <wire x2="960" y1="1168" y2="1168" x1="928" />
            <wire x2="992" y1="1104" y2="1104" x1="960" />
            <wire x2="960" y1="1104" y2="1168" x1="960" />
        </branch>
        <branch name="NOE">
            <wire x2="1872" y1="704" y2="704" x1="1760" />
            <wire x2="2208" y1="704" y2="704" x1="1872" />
            <wire x2="1904" y1="512" y2="512" x1="1872" />
            <wire x2="1872" y1="512" y2="704" x1="1872" />
        </branch>
        <branch name="RNW">
            <wire x2="1072" y1="608" y2="608" x1="320" />
            <wire x2="1232" y1="608" y2="608" x1="1072" />
            <wire x2="1072" y1="304" y2="608" x1="1072" />
            <wire x2="1872" y1="304" y2="304" x1="1072" />
        </branch>
        <branch name="NG">
            <wire x2="2208" y1="480" y2="480" x1="2160" />
        </branch>
        <iomarker fontsize="28" x="320" y="1072" name="A10" orien="R180" />
        <iomarker fontsize="28" x="320" y="1136" name="A9" orien="R180" />
        <iomarker fontsize="28" x="320" y="1200" name="A8" orien="R180" />
        <iomarker fontsize="28" x="1664" y="1328" name="B10" orien="R0" />
        <iomarker fontsize="28" x="1664" y="1472" name="B9" orien="R0" />
        <iomarker fontsize="28" x="1664" y="1616" name="B8" orien="R0" />
        <iomarker fontsize="28" x="320" y="672" name="NDEV_SEL" orien="R180" />
        <iomarker fontsize="28" x="320" y="608" name="RNW" orien="R180" />
        <branch name="DATA_EN">
            <wire x2="2208" y1="336" y2="336" x1="2128" />
        </branch>
        <branch name="NDEV_SEL">
            <wire x2="1136" y1="672" y2="672" x1="320" />
            <wire x2="1232" y1="672" y2="672" x1="1136" />
            <wire x2="1136" y1="448" y2="672" x1="1136" />
            <wire x2="1392" y1="448" y2="448" x1="1136" />
            <wire x2="1904" y1="448" y2="448" x1="1392" />
            <wire x2="1872" y1="368" y2="368" x1="1392" />
            <wire x2="1392" y1="368" y2="448" x1="1392" />
        </branch>
        <branch name="NIO_SEL">
            <wire x2="544" y1="880" y2="880" x1="320" />
        </branch>
        <instance x="992" y="752" name="XLXI_61" orien="M180" />
        <instance x="544" y="912" name="XLXI_22" orien="R0" />
        <branch name="XLXN_46">
            <wire x2="992" y1="880" y2="880" x1="768" />
        </branch>
        <iomarker fontsize="28" x="320" y="880" name="NIO_SEL" orien="R180" />
        <branch name="XLXN_103">
            <wire x2="976" y1="960" y2="960" x1="928" />
            <wire x2="976" y1="960" y2="1008" x1="976" />
            <wire x2="992" y1="1008" y2="1008" x1="976" />
        </branch>
        <instance x="800" y="896" name="XLXI_63" orien="R90" />
        <iomarker fontsize="28" x="320" y="1264" name="NIO_STB" orien="R180" />
        <instance x="672" y="1328" name="XLXI_66" orien="R0" />
        <branch name="NIO_STB">
            <wire x2="400" y1="1264" y2="1264" x1="320" />
            <wire x2="640" y1="1264" y2="1264" x1="400" />
            <wire x2="672" y1="1264" y2="1264" x1="640" />
            <wire x2="640" y1="1264" y2="1296" x1="640" />
            <wire x2="640" y1="1296" y2="1440" x1="640" />
            <wire x2="640" y1="1440" y2="1584" x1="640" />
            <wire x2="928" y1="1584" y2="1584" x1="640" />
            <wire x2="928" y1="1440" y2="1440" x1="640" />
            <wire x2="928" y1="1296" y2="1296" x1="640" />
            <wire x2="1504" y1="736" y2="736" x1="400" />
            <wire x2="400" y1="736" y2="1264" x1="400" />
        </branch>
        <branch name="XLXN_110">
            <wire x2="1440" y1="1008" y2="1008" x1="1376" />
            <wire x2="1440" y1="800" y2="1008" x1="1440" />
            <wire x2="1504" y1="800" y2="800" x1="1440" />
        </branch>
        <instance x="1872" y="432" name="XLXI_50" orien="R0" />
        <iomarker fontsize="28" x="2208" y="336" name="DATA_EN" orien="R0" />
        <iomarker fontsize="28" x="2208" y="480" name="NG" orien="R0" />
        <iomarker fontsize="28" x="2208" y="704" name="NOE" orien="R0" />
        <instance x="1904" y="576" name="XLXI_36" orien="R0" />
        <instance x="1232" y="640" name="XLXI_72" orien="R0" />
        <instance x="1232" y="704" name="XLXI_73" orien="R0" />
        <instance x="1504" y="864" name="XLXI_74" orien="R0" />
        <branch name="XLXN_116">
            <wire x2="1504" y1="608" y2="608" x1="1456" />
        </branch>
        <branch name="XLXN_117">
            <wire x2="1504" y1="672" y2="672" x1="1456" />
        </branch>
        <instance x="928" y="1328" name="XLXI_77" orien="R0" />
        <instance x="928" y="1472" name="XLXI_75" orien="R0" />
        <instance x="928" y="1616" name="XLXI_76" orien="R0" />
        <branch name="XLXN_118">
            <wire x2="1184" y1="1296" y2="1296" x1="1152" />
        </branch>
        <instance x="1184" y="1424" name="XLXI_78" orien="R0" />
        <instance x="1184" y="1568" name="XLXI_79" orien="R0" />
        <instance x="1184" y="1712" name="XLXI_80" orien="R0" />
        <branch name="XLXN_119">
            <wire x2="1184" y1="1440" y2="1440" x1="1152" />
        </branch>
        <branch name="XLXN_120">
            <wire x2="1184" y1="1584" y2="1584" x1="1152" />
        </branch>
    </sheet>
</drawing>