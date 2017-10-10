----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:03:22 10/10/2017 
-- Design Name: 
-- Module Name:    AddressDecoder - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AddressDecoder is
    Port ( A : in  std_logic_vector (10 downto 8);
           B : out  std_logic_vector (10 downto 8);
           RNW : in  std_logic;
           NDEV_SEL : in  std_logic;
           NIO_SEL : in  std_logic;
           NIO_STB : in  std_logic;
           NRESET : in std_logic;
           DATA_EN : out  std_logic;
           NG : out  std_logic;
           NOE : out  std_logic);
end AddressDecoder;

architecture Behavioral of AddressDecoder is

    signal cfxx : std_logic;
    signal noe_int : std_logic;
    signal ncs : std_logic;

begin

    B <= A when (NIO_STB = '0') else (others => '0');
    DATA_EN <= RNW and not NDEV_SEL;
    NG <= NDEV_SEL and noe_int;
    NOE <= noe_int;
    noe_int <= not RNW or not NDEV_SEL
            or (NIO_SEL and NIO_STB)
            or (NIO_SEL and ncs);
    
    cfxx <= A(8) and A(9) and A(10) and not NIO_STB;
    
    process(NRESET, NIO_SEL, cfxx)
    begin
        if (NRESET = '0' or cfxx = '1') then
            ncs <= '1';
        elsif falling_edge(NIO_SEL) then
            ncs <= '0';
        end if;
    end process;
    
end Behavioral;

