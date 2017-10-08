<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="xc9500xl" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="NIO_SEL" />
        <signal name="DATA(7:0)" />
        <signal name="CLK" />
        <signal name="RNW" />
        <signal name="XLXN_52(7:0)" />
        <signal name="XLXN_56" />
        <signal name="NIO_STB" />
        <signal name="NDEV_SEL" />
        <signal name="XLXN_65" />
        <signal name="XLXN_66" />
        <signal name="XLXN_77" />
        <signal name="XLXN_78" />
        <signal name="XLXN_79" />
        <signal name="XLXN_84" />
        <signal name="A8" />
        <signal name="A9" />
        <signal name="A10" />
        <signal name="PHI0" />
        <signal name="MISO" />
        <signal name="A0" />
        <signal name="A1" />
        <signal name="CARD" />
        <signal name="WP" />
        <signal name="add(1:0)" />
        <signal name="add(0)" />
        <signal name="add(1)" />
        <signal name="XLXN_100" />
        <signal name="XLXN_101" />
        <signal name="NRESET" />
        <signal name="XLXN_105(7:0)" />
        <signal name="B10" />
        <signal name="B9" />
        <signal name="B8" />
        <signal name="NOE" />
        <signal name="NG" />
        <signal name="MOSI" />
        <signal name="SCLK" />
        <signal name="NSEL" />
        <signal name="XLXN_126" />
        <signal name="XLXN_128" />
        <signal name="XLXN_129" />
        <signal name="XLXN_131" />
        <signal name="LED" />
        <port polarity="Input" name="NIO_SEL" />
        <port polarity="BiDirectional" name="DATA(7:0)" />
        <port polarity="Input" name="CLK" />
        <port polarity="Input" name="RNW" />
        <port polarity="Input" name="NIO_STB" />
        <port polarity="Input" name="NDEV_SEL" />
        <port polarity="Input" name="A8" />
        <port polarity="Input" name="A9" />
        <port polarity="Input" name="A10" />
        <port polarity="Input" name="PHI0" />
        <port polarity="Input" name="MISO" />
        <port polarity="Input" name="A0" />
        <port polarity="Input" name="A1" />
        <port polarity="Input" name="CARD" />
        <port polarity="Input" name="WP" />
        <port polarity="Input" name="NRESET" />
        <port polarity="Output" name="B10" />
        <port polarity="Output" name="B9" />
        <port polarity="Output" name="B8" />
        <port polarity="Output" name="NOE" />
        <port polarity="Output" name="NG" />
        <port polarity="Output" name="MOSI" />
        <port polarity="Output" name="SCLK" />
        <port polarity="Output" name="NSEL" />
        <port polarity="Output" name="LED" />
        <blockdef name="ld4">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-448" y2="-448" x1="0" />
            <line x2="64" y1="-384" y2="-384" x1="0" />
            <line x2="64" y1="-320" y2="-320" x1="0" />
            <line x2="64" y1="-256" y2="-256" x1="0" />
            <line x2="320" y1="-448" y2="-448" x1="384" />
            <line x2="320" y1="-384" y2="-384" x1="384" />
            <line x2="320" y1="-320" y2="-320" x1="384" />
            <line x2="320" y1="-256" y2="-256" x1="384" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <rect width="256" x="64" y="-512" height="448" />
        </blockdef>
        <blockdef name="ld8">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-256" y2="-256" x1="0" />
            <line x2="320" y1="-256" y2="-256" x1="384" />
            <rect width="256" x="64" y="-320" height="256" />
            <rect width="64" x="320" y="-268" height="24" />
            <rect width="64" x="0" y="-268" height="24" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
        </blockdef>
        <blockdef name="bufe8">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <rect width="96" x="128" y="-44" height="24" />
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="64" y1="-96" y2="-96" x1="0" />
            <line x2="64" y1="-64" y2="0" x1="64" />
            <line x2="64" y1="-32" y2="-64" x1="128" />
            <line x2="128" y1="0" y2="-32" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="128" y1="-32" y2="-32" x1="224" />
            <line x2="64" y1="-96" y2="-96" x1="96" />
            <line x2="96" y1="-48" y2="-96" x1="96" />
        </blockdef>
        <blockdef name="AddressDecoder">
            <timestamp>2017-10-8T19:38:25</timestamp>
            <line x2="384" y1="160" y2="160" x1="320" />
            <line x2="384" y1="96" y2="96" x1="320" />
            <line x2="0" y1="32" y2="32" x1="64" />
            <line x2="0" y1="-416" y2="-416" x1="64" />
            <line x2="0" y1="-352" y2="-352" x1="64" />
            <line x2="0" y1="-288" y2="-288" x1="64" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-416" y2="-416" x1="320" />
            <line x2="384" y1="-288" y2="-288" x1="320" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
            <rect width="256" x="64" y="-448" height="640" />
        </blockdef>
        <blockdef name="AppleIISd">
            <timestamp>2017-10-8T19:42:44</timestamp>
            <line x2="0" y1="-480" y2="-480" x1="64" />
            <line x2="0" y1="-416" y2="-416" x1="64" />
            <rect width="256" x="64" y="-896" height="860" />
            <line x2="64" y1="-816" y2="-816" x1="0" />
            <line x2="0" y1="-304" y2="-304" x1="64" />
            <line x2="0" y1="-240" y2="-240" x1="64" />
            <line x2="0" y1="-176" y2="-176" x1="64" />
            <rect width="64" x="0" y="-124" height="24" />
            <line x2="0" y1="-112" y2="-112" x1="64" />
            <rect width="64" x="0" y="-380" height="24" />
            <line x2="0" y1="-368" y2="-368" x1="64" />
            <line x2="0" y1="-768" y2="-768" x1="64" />
            <line x2="0" y1="-704" y2="-704" x1="64" />
            <line x2="384" y1="-752" y2="-752" x1="320" />
            <line x2="384" y1="-688" y2="-688" x1="320" />
            <line x2="384" y1="-816" y2="-816" x1="320" />
            <rect width="64" x="320" y="-524" height="24" />
            <line x2="384" y1="-512" y2="-512" x1="320" />
            <line x2="384" y1="-560" y2="-560" x1="320" />
        </blockdef>
        <blockdef name="inv">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="160" y1="-32" y2="-32" x1="224" />
            <line x2="128" y1="-64" y2="-32" x1="64" />
            <line x2="64" y1="-32" y2="0" x1="128" />
            <line x2="64" y1="0" y2="-64" x1="64" />
            <circle r="16" cx="144" cy="-32" />
        </blockdef>
        <block symbolname="ld8" name="XLXI_2">
            <blockpin signalname="DATA(7:0)" name="D(7:0)" />
            <blockpin signalname="CLK" name="G" />
            <blockpin signalname="XLXN_105(7:0)" name="Q(7:0)" />
        </block>
        <block symbolname="bufe8" name="XLXI_8">
            <blockpin signalname="XLXN_56" name="E" />
            <blockpin signalname="XLXN_52(7:0)" name="I(7:0)" />
            <blockpin signalname="DATA(7:0)" name="O(7:0)" />
        </block>
        <block symbolname="AddressDecoder" name="XLXI_11">
            <blockpin signalname="XLXN_79" name="A10" />
            <blockpin signalname="XLXN_78" name="A9" />
            <blockpin signalname="XLXN_77" name="A8" />
            <blockpin signalname="XLXN_65" name="NIO_SEL" />
            <blockpin signalname="XLXN_84" name="NDEV_SEL" />
            <blockpin signalname="XLXN_128" name="RNW" />
            <blockpin signalname="XLXN_66" name="NIO_STB" />
            <blockpin signalname="B10" name="B10" />
            <blockpin signalname="B9" name="B9" />
            <blockpin signalname="B8" name="B8" />
            <blockpin signalname="NOE" name="NOE" />
            <blockpin signalname="NG" name="NG" />
            <blockpin signalname="XLXN_56" name="DATA_EN" />
        </block>
        <block symbolname="AppleIISd" name="XLXI_17">
            <blockpin signalname="XLXN_128" name="is_read" />
            <blockpin signalname="XLXN_126" name="reset" />
            <blockpin signalname="PHI0" name="phi0" />
            <blockpin signalname="XLXN_129" name="selected" />
            <blockpin signalname="CLK" name="clk" />
            <blockpin signalname="XLXN_131" name="miso" />
            <blockpin signalname="XLXN_101" name="wp" />
            <blockpin signalname="XLXN_100" name="card" />
            <blockpin signalname="XLXN_105(7:0)" name="data_in(7:0)" />
            <blockpin signalname="add(1:0)" name="addr(1:0)" />
            <blockpin signalname="MOSI" name="mosi" />
            <blockpin signalname="SCLK" name="sclk" />
            <blockpin signalname="NSEL" name="nsel" />
            <blockpin signalname="LED" name="led" />
            <blockpin signalname="XLXN_52(7:0)" name="data_out(7:0)" />
        </block>
        <block symbolname="ld4" name="XLXI_3">
            <blockpin signalname="NIO_SEL" name="D0" />
            <blockpin signalname="NIO_STB" name="D1" />
            <blockpin signalname="NDEV_SEL" name="D2" />
            <blockpin signalname="RNW" name="D3" />
            <blockpin signalname="CLK" name="G" />
            <blockpin signalname="XLXN_65" name="Q0" />
            <blockpin signalname="XLXN_66" name="Q1" />
            <blockpin signalname="XLXN_84" name="Q2" />
            <blockpin signalname="XLXN_128" name="Q3" />
        </block>
        <block symbolname="ld4" name="XLXI_21">
            <blockpin signalname="WP" name="D0" />
            <blockpin signalname="CARD" name="D1" />
            <blockpin signalname="A1" name="D2" />
            <blockpin signalname="A0" name="D3" />
            <blockpin signalname="CLK" name="G" />
            <blockpin signalname="XLXN_101" name="Q0" />
            <blockpin signalname="XLXN_100" name="Q1" />
            <blockpin signalname="add(1)" name="Q2" />
            <blockpin signalname="add(0)" name="Q3" />
        </block>
        <block symbolname="ld4" name="XLXI_22">
            <blockpin signalname="MISO" name="D0" />
            <blockpin signalname="A10" name="D1" />
            <blockpin signalname="A9" name="D2" />
            <blockpin signalname="A8" name="D3" />
            <blockpin signalname="CLK" name="G" />
            <blockpin signalname="XLXN_131" name="Q0" />
            <blockpin signalname="XLXN_79" name="Q1" />
            <blockpin signalname="XLXN_78" name="Q2" />
            <blockpin signalname="XLXN_77" name="Q3" />
        </block>
        <block symbolname="inv" name="XLXI_23">
            <blockpin signalname="XLXN_84" name="I" />
            <blockpin signalname="XLXN_129" name="O" />
        </block>
        <block symbolname="inv" name="XLXI_24">
            <blockpin signalname="NRESET" name="I" />
            <blockpin signalname="XLXN_126" name="O" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <instance x="656" y="528" name="XLXI_2" orien="R0" />
        <iomarker fontsize="28" x="224" y="400" name="CLK" orien="R180" />
        <branch name="NIO_SEL">
            <wire x2="656" y1="1808" y2="1808" x1="528" />
        </branch>
        <branch name="DATA(7:0)">
            <wire x2="608" y1="272" y2="272" x1="560" />
            <wire x2="656" y1="272" y2="272" x1="608" />
            <wire x2="608" y1="144" y2="272" x1="608" />
            <wire x2="2800" y1="144" y2="144" x1="608" />
            <wire x2="2800" y1="144" y2="624" x1="2800" />
            <wire x2="2800" y1="624" y2="624" x1="2736" />
        </branch>
        <iomarker fontsize="28" x="560" y="272" name="DATA(7:0)" orien="R180" />
        <branch name="CLK">
            <wire x2="304" y1="400" y2="400" x1="224" />
            <wire x2="656" y1="400" y2="400" x1="304" />
            <wire x2="304" y1="400" y2="528" x1="304" />
            <wire x2="304" y1="528" y2="944" x1="304" />
            <wire x2="304" y1="944" y2="1472" x1="304" />
            <wire x2="656" y1="1472" y2="1472" x1="304" />
            <wire x2="304" y1="1472" y2="1648" x1="304" />
            <wire x2="304" y1="1648" y2="2128" x1="304" />
            <wire x2="656" y1="2128" y2="2128" x1="304" />
            <wire x2="656" y1="944" y2="944" x1="304" />
            <wire x2="1904" y1="528" y2="528" x1="304" />
            <wire x2="2000" y1="368" y2="368" x1="1904" />
            <wire x2="1904" y1="368" y2="528" x1="1904" />
        </branch>
        <branch name="RNW">
            <wire x2="656" y1="2000" y2="2000" x1="528" />
        </branch>
        <branch name="XLXN_56">
            <wire x2="2512" y1="2128" y2="2128" x1="1808" />
            <wire x2="2512" y1="688" y2="2128" x1="2512" />
        </branch>
        <branch name="NIO_STB">
            <wire x2="656" y1="1872" y2="1872" x1="528" />
        </branch>
        <branch name="NDEV_SEL">
            <wire x2="656" y1="1936" y2="1936" x1="528" />
        </branch>
        <branch name="XLXN_66">
            <wire x2="1424" y1="1872" y2="1872" x1="1040" />
        </branch>
        <instance x="656" y="1600" name="XLXI_22" orien="R0" />
        <branch name="XLXN_78">
            <wire x2="1216" y1="1280" y2="1280" x1="1040" />
            <wire x2="1216" y1="1280" y2="1616" x1="1216" />
            <wire x2="1424" y1="1616" y2="1616" x1="1216" />
        </branch>
        <branch name="XLXN_79">
            <wire x2="1248" y1="1216" y2="1216" x1="1040" />
            <wire x2="1248" y1="1216" y2="1552" x1="1248" />
            <wire x2="1424" y1="1552" y2="1552" x1="1248" />
        </branch>
        <instance x="1328" y="1328" name="XLXI_23" orien="R0" />
        <branch name="XLXN_84">
            <wire x2="1312" y1="1936" y2="1936" x1="1040" />
            <wire x2="1424" y1="1936" y2="1936" x1="1312" />
            <wire x2="1328" y1="1296" y2="1296" x1="1312" />
            <wire x2="1312" y1="1296" y2="1936" x1="1312" />
        </branch>
        <instance x="656" y="1072" name="XLXI_21" orien="R0" />
        <branch name="A8">
            <wire x2="656" y1="1344" y2="1344" x1="624" />
        </branch>
        <iomarker fontsize="28" x="624" y="1344" name="A8" orien="R180" />
        <branch name="A9">
            <wire x2="656" y1="1280" y2="1280" x1="624" />
        </branch>
        <iomarker fontsize="28" x="624" y="1280" name="A9" orien="R180" />
        <branch name="A10">
            <wire x2="656" y1="1216" y2="1216" x1="624" />
        </branch>
        <iomarker fontsize="28" x="624" y="1216" name="A10" orien="R180" />
        <branch name="PHI0">
            <wire x2="2000" y1="320" y2="320" x1="1776" />
        </branch>
        <branch name="MISO">
            <wire x2="656" y1="1152" y2="1152" x1="624" />
        </branch>
        <iomarker fontsize="28" x="624" y="1152" name="MISO" orien="R180" />
        <branch name="A0">
            <wire x2="656" y1="816" y2="816" x1="624" />
        </branch>
        <iomarker fontsize="28" x="624" y="816" name="A0" orien="R180" />
        <branch name="A1">
            <wire x2="656" y1="752" y2="752" x1="624" />
        </branch>
        <iomarker fontsize="28" x="624" y="752" name="A1" orien="R180" />
        <branch name="CARD">
            <wire x2="656" y1="688" y2="688" x1="624" />
        </branch>
        <iomarker fontsize="28" x="624" y="688" name="CARD" orien="R180" />
        <branch name="WP">
            <wire x2="656" y1="624" y2="624" x1="624" />
        </branch>
        <iomarker fontsize="28" x="624" y="624" name="WP" orien="R180" />
        <bustap x2="1168" y1="752" y2="752" x1="1264" />
        <bustap x2="1168" y1="816" y2="816" x1="1264" />
        <branch name="add(0)">
            <wire x2="1168" y1="816" y2="816" x1="1040" />
        </branch>
        <branch name="add(1)">
            <wire x2="1168" y1="752" y2="752" x1="1040" />
        </branch>
        <instance x="1552" y="1264" name="XLXI_24" orien="R0" />
        <iomarker fontsize="28" x="1536" y="1232" name="NRESET" orien="R180" />
        <branch name="NRESET">
            <wire x2="1552" y1="1232" y2="1232" x1="1536" />
        </branch>
        <branch name="XLXN_105(7:0)">
            <wire x2="1600" y1="272" y2="272" x1="1040" />
            <wire x2="1600" y1="272" y2="1024" x1="1600" />
            <wire x2="2000" y1="1024" y2="1024" x1="1600" />
        </branch>
        <instance x="2000" y="1136" name="XLXI_17" orien="R0">
        </instance>
        <branch name="XLXN_101">
            <wire x2="1056" y1="624" y2="624" x1="1040" />
            <wire x2="1056" y1="624" y2="656" x1="1056" />
            <wire x2="2000" y1="656" y2="656" x1="1056" />
        </branch>
        <branch name="XLXN_100">
            <wire x2="1056" y1="688" y2="688" x1="1040" />
            <wire x2="1056" y1="688" y2="720" x1="1056" />
            <wire x2="2000" y1="720" y2="720" x1="1056" />
        </branch>
        <branch name="add(1:0)">
            <wire x2="1264" y1="752" y2="768" x1="1264" />
            <wire x2="1264" y1="768" y2="816" x1="1264" />
            <wire x2="2000" y1="768" y2="768" x1="1264" />
        </branch>
        <instance x="656" y="2256" name="XLXI_3" orien="R0" />
        <branch name="XLXN_65">
            <wire x2="1424" y1="1808" y2="1808" x1="1040" />
        </branch>
        <iomarker fontsize="28" x="528" y="1936" name="NDEV_SEL" orien="R180" />
        <iomarker fontsize="28" x="528" y="1872" name="NIO_STB" orien="R180" />
        <iomarker fontsize="28" x="528" y="1808" name="NIO_SEL" orien="R180" />
        <iomarker fontsize="28" x="528" y="2000" name="RNW" orien="R180" />
        <instance x="1424" y="1968" name="XLXI_11" orien="R0">
        </instance>
        <branch name="XLXN_77">
            <wire x2="1184" y1="1344" y2="1344" x1="1040" />
            <wire x2="1184" y1="1344" y2="1680" x1="1184" />
            <wire x2="1424" y1="1680" y2="1680" x1="1184" />
        </branch>
        <branch name="B10">
            <wire x2="1840" y1="1552" y2="1552" x1="1808" />
        </branch>
        <iomarker fontsize="28" x="1840" y="1552" name="B10" orien="R0" />
        <branch name="B9">
            <wire x2="1840" y1="1680" y2="1680" x1="1808" />
        </branch>
        <iomarker fontsize="28" x="1840" y="1680" name="B9" orien="R0" />
        <branch name="B8">
            <wire x2="1840" y1="1808" y2="1808" x1="1808" />
        </branch>
        <iomarker fontsize="28" x="1840" y="1808" name="B8" orien="R0" />
        <branch name="NOE">
            <wire x2="1840" y1="1936" y2="1936" x1="1808" />
        </branch>
        <iomarker fontsize="28" x="1840" y="1936" name="NOE" orien="R0" />
        <branch name="NG">
            <wire x2="1840" y1="2064" y2="2064" x1="1808" />
        </branch>
        <iomarker fontsize="28" x="1840" y="2064" name="NG" orien="R0" />
        <iomarker fontsize="28" x="1776" y="320" name="PHI0" orien="R180" />
        <branch name="XLXN_126">
            <wire x2="1888" y1="1232" y2="1232" x1="1776" />
            <wire x2="2000" y1="896" y2="896" x1="1888" />
            <wire x2="1888" y1="896" y2="1232" x1="1888" />
        </branch>
        <branch name="XLXN_128">
            <wire x2="1280" y1="2000" y2="2000" x1="1040" />
            <wire x2="1424" y1="2000" y2="2000" x1="1280" />
            <wire x2="1280" y1="1168" y2="2000" x1="1280" />
            <wire x2="1680" y1="1168" y2="1168" x1="1280" />
            <wire x2="2000" y1="832" y2="832" x1="1680" />
            <wire x2="1680" y1="832" y2="1168" x1="1680" />
        </branch>
        <branch name="XLXN_129">
            <wire x2="1792" y1="1296" y2="1296" x1="1552" />
            <wire x2="1792" y1="960" y2="1296" x1="1792" />
            <wire x2="2000" y1="960" y2="960" x1="1792" />
        </branch>
        <branch name="XLXN_131">
            <wire x2="1520" y1="1152" y2="1152" x1="1040" />
            <wire x2="1520" y1="592" y2="1152" x1="1520" />
            <wire x2="1936" y1="592" y2="592" x1="1520" />
            <wire x2="2000" y1="432" y2="432" x1="1936" />
            <wire x2="1936" y1="432" y2="592" x1="1936" />
        </branch>
        <branch name="NSEL">
            <wire x2="2400" y1="448" y2="448" x1="2384" />
            <wire x2="2416" y1="448" y2="448" x1="2400" />
            <wire x2="2448" y1="448" y2="448" x1="2416" />
        </branch>
        <branch name="SCLK">
            <wire x2="2400" y1="384" y2="384" x1="2384" />
            <wire x2="2448" y1="384" y2="384" x1="2400" />
        </branch>
        <branch name="MOSI">
            <wire x2="2400" y1="320" y2="320" x1="2384" />
            <wire x2="2448" y1="320" y2="320" x1="2400" />
        </branch>
        <instance x="2512" y="592" name="XLXI_8" orien="M180" />
        <branch name="XLXN_52(7:0)">
            <wire x2="2512" y1="624" y2="624" x1="2384" />
        </branch>
        <iomarker fontsize="28" x="2448" y="448" name="NSEL" orien="R0" />
        <iomarker fontsize="28" x="2448" y="384" name="SCLK" orien="R0" />
        <iomarker fontsize="28" x="2448" y="320" name="MOSI" orien="R0" />
        <branch name="LED">
            <wire x2="2400" y1="576" y2="576" x1="2384" />
            <wire x2="2448" y1="576" y2="576" x1="2400" />
        </branch>
        <iomarker fontsize="28" x="2448" y="576" name="LED" orien="R0" />
    </sheet>
</drawing>