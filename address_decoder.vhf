--------------------------------------------------------------------------------
-- Copyright (c) 1995-2003 Xilinx, Inc.
-- All Right Reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 6.3.03i
--  \   \         Application : 
--  /   /         Filename : address_decoder.vhf
-- /___/   /\     Timestamp : 05/11/2017 02:05:37
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: 
--Design Name: FD_MXILINX_address_decoder
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
-- synopsys translate_off
library UNISIM;
use UNISIM.Vcomponents.ALL;
-- synopsys translate_on

entity FD_MXILINX_address_decoder is
   port ( C : in    std_logic; 
          D : in    std_logic; 
          Q : out   std_logic);
end FD_MXILINX_address_decoder;

architecture BEHAVIORAL of FD_MXILINX_address_decoder is
   attribute BOX_TYPE   : string ;
   signal XLXN_4 : std_logic;
   component GND
      port ( G : out   std_logic);
   end component;
   attribute BOX_TYPE of GND : component is "BLACK_BOX";
   
   component FDCP
      port ( C   : in    std_logic; 
             CLR : in    std_logic; 
             D   : in    std_logic; 
             PRE : in    std_logic; 
             Q   : out   std_logic);
   end component;
   attribute BOX_TYPE of FDCP : component is "BLACK_BOX";
   
begin
   I_36_43 : GND
      port map (G=>XLXN_4);
   
   U0 : FDCP
      port map (C=>C,      
                CLR=>XLXN_4,      
                D=>D,      
                PRE=>XLXN_4,      
                Q=>Q);
   
end BEHAVIORAL;


--------------------------------------------------------------------------------
-- Copyright (c) 1995-2003 Xilinx, Inc.
-- All Right Reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 6.3.03i
--  \   \         Application : 
--  /   /         Filename : address_decoder.vhf
-- /___/   /\     Timestamp : 05/11/2017 02:05:37
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: 
--Design Name: FDRS_MXILINX_address_decoder
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
-- synopsys translate_off
library UNISIM;
use UNISIM.Vcomponents.ALL;
-- synopsys translate_on

entity FDRS_MXILINX_address_decoder is
   port ( C : in    std_logic; 
          D : in    std_logic; 
          R : in    std_logic; 
          S : in    std_logic; 
          Q : out   std_logic);
end FDRS_MXILINX_address_decoder;

architecture BEHAVIORAL of FDRS_MXILINX_address_decoder is
   attribute BOX_TYPE   : string ;
   attribute HU_SET     : string ;
   signal XLXN_6 : std_logic;
   signal XLXN_7 : std_logic;
   signal XLXN_8 : std_logic;
   component AND2B1
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of AND2B1 : component is "BLACK_BOX";
   
   component OR2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of OR2 : component is "BLACK_BOX";
   
   component FD_MXILINX_address_decoder
      port ( C : in    std_logic; 
             D : in    std_logic; 
             Q : out   std_logic);
   end component;
   
   attribute HU_SET of U0 : label is "U0_0";
begin
   I_36_112 : AND2B1
      port map (I0=>R,      
                I1=>S,      
                O=>XLXN_6);
   
   I_36_113 : AND2B1
      port map (I0=>R,      
                I1=>D,      
                O=>XLXN_8);
   
   I_36_120 : OR2
      port map (I0=>XLXN_6,      
                I1=>XLXN_8,      
                O=>XLXN_7);
   
   U0 : FD_MXILINX_address_decoder
      port map (C=>C,      
                D=>XLXN_7,      
                Q=>Q);
   
end BEHAVIORAL;


--------------------------------------------------------------------------------
-- Copyright (c) 1995-2003 Xilinx, Inc.
-- All Right Reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 6.3.03i
--  \   \         Application : 
--  /   /         Filename : address_decoder.vhf
-- /___/   /\     Timestamp : 05/11/2017 02:05:37
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: 
--Design Name: address_decoder
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
-- synopsys translate_off
library UNISIM;
use UNISIM.Vcomponents.ALL;
-- synopsys translate_on

entity address_decoder is
   port ( A8      : in    std_logic; 
          A9      : in    std_logic; 
          A10     : in    std_logic; 
          CLK     : in    std_logic; 
          NIO_SEL : in    std_logic; 
          NIO_STB : in    std_logic; 
          A8_B    : out   std_logic; 
          A9_B    : out   std_logic; 
          A10_B   : out   std_logic; 
          NOE     : out   std_logic);
end address_decoder;

architecture BEHAVIORAL of address_decoder is
   attribute BOX_TYPE   : string ;
   attribute HU_SET     : string ;
   signal XLXN_4  : std_logic;
   signal XLXN_10 : std_logic;
   signal XLXN_11 : std_logic;
   signal XLXN_14 : std_logic;
   signal XLXN_19 : std_logic;
   component NAND2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of NAND2 : component is "BLACK_BOX";
   
   component FDRS_MXILINX_address_decoder
      port ( C : in    std_logic; 
             D : in    std_logic; 
             R : in    std_logic; 
             S : in    std_logic; 
             Q : out   std_logic);
   end component;
   
   component VCC
      port ( P : out   std_logic);
   end component;
   attribute BOX_TYPE of VCC : component is "BLACK_BOX";
   
   component AND2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of AND2 : component is "BLACK_BOX";
   
   component INV
      port ( I : in    std_logic; 
             O : out   std_logic);
   end component;
   attribute BOX_TYPE of INV : component is "BLACK_BOX";
   
   component AND4B1
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             I2 : in    std_logic; 
             I3 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of AND4B1 : component is "BLACK_BOX";
   
   attribute HU_SET of XLXI_16 : label is "XLXI_16_1";
begin
   XLXI_13 : NAND2
      port map (I0=>NIO_SEL,      
                I1=>NIO_STB,      
                O=>XLXN_4);
   
   XLXI_14 : NAND2
      port map (I0=>XLXN_11,      
                I1=>XLXN_4,      
                O=>NOE);
   
   XLXI_16 : FDRS_MXILINX_address_decoder
      port map (C=>CLK,      
                D=>XLXN_14,      
                R=>XLXN_10,      
                S=>XLXN_19,      
                Q=>XLXN_11);
   
   XLXI_17 : VCC
      port map (P=>XLXN_14);
   
   XLXI_18 : AND2
      port map (I0=>A10,      
                I1=>NIO_SEL,      
                O=>A10_B);
   
   XLXI_19 : AND2
      port map (I0=>A9,      
                I1=>NIO_SEL,      
                O=>A9_B);
   
   XLXI_20 : AND2
      port map (I0=>A8,      
                I1=>NIO_SEL,      
                O=>A8_B);
   
   XLXI_22 : INV
      port map (I=>NIO_SEL,      
                O=>XLXN_19);
   
   XLXI_23 : AND4B1
      port map (I0=>NIO_STB,      
                I1=>A10,      
                I2=>A9,      
                I3=>A8,      
                O=>XLXN_10);
   
end BEHAVIORAL;


