----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:44:25 10/09/2017 
-- Design Name: 
-- Module Name:    IO - Behavioral 
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

entity IO is
Port (
    ADD_HIGH : in std_logic_vector(10 downto 8);
    ADD_LOW : in std_logic_vector(1 downto 0);
    B : out std_logic_vector(10 downto 8);
    CARD : in std_logic;
    DATA : inout std_logic_vector (7 downto 0);
    CLK : in std_logic;
    LED : out std_logic;
    NDEV_SEL : in std_logic;
    NG : out std_logic;
    NIO_SEL : in std_logic;
    NIO_STB : in std_logic;
    NOE : out std_logic;
    PHI0 : in std_logic;
    NRESET : in std_logic;
    RNW : in std_logic;
    MISO : in std_logic;
    MOSI : out std_logic;
    NSEL : out std_logic;
    SCLK : out std_logic;
    WP : in std_logic
    
    -- synthesis translate_off
    ;
    data_dbg : out std_logic_vector (7 downto 0);
    add_dbg : out std_logic_vector (1 downto 0)
    -- synthesis translate_on
    
    );
end IO;

architecture Behavioral of IO is

    signal data_in : std_logic_vector (7 downto 0);
    signal data_out : std_logic_vector (7 downto 0);
    signal addr_low_int : std_logic_vector (1 downto 0);
    signal wp_int : std_logic;
    signal card_int : std_logic;
    signal miso_int : std_logic;
    
    signal ndev_sel_int : std_logic;
    signal rnw_int : std_logic;
    signal data_en : std_logic;
        
component AppleIISd is
Port (
        data_in : in std_logic_vector (7 downto 0);
        data_out : out std_logic_vector (7 downto 0);
        is_read : in  std_logic;
        nreset : in  std_logic;
        addr : in  std_logic_vector (1 downto 0);
        phi0 : in  std_logic;
        ndev_sel : in  std_logic;
        clk : in  std_logic;
        miso: in std_logic;
        mosi : out  std_logic;
        sclk : out  std_logic;
        nsel : out  std_logic;
        wp : in  std_logic;
        card : in  std_logic;
        led : out  std_logic
    );
end component;

component AddressDecoder
Port ( 
        A : in  std_logic_vector (10 downto 8);
        B : out  std_logic_vector (10 downto 8);
        RNW : in  std_logic;
        NDEV_SEL : in  std_logic;
        NIO_SEL : in  std_logic;
        NIO_STB : in  std_logic;
        NRESET : in std_logic;
        DATA_EN : out  std_logic;
        NG : out  std_logic;
        NOE : out  std_logic
      );
end component;

begin
    spi: AppleIISd port map(
        data_in => data_in,
        data_out => data_out,
        is_read => rnw_int,
        nreset => NRESET,
        addr => addr_low_int,
        phi0 => PHI0,
        ndev_sel => ndev_sel_int,
        clk => CLK,
        miso => miso_int,
        mosi => MOSI,
        sclk => SCLK,
        nsel => NSEL,
        wp => wp_int,
        card => card_int,
        led => LED
    );
    
    addDec: AddressDecoder port map(
        A => ADD_HIGH,
        B => B,
        RNW => RNW,
        NDEV_SEL => NDEV_SEL,
        NIO_SEL => NIO_SEL,
        NIO_STB => NIO_STB,
        NRESET => NRESET,
        DATA_EN => data_en,
        NOE => NOE,
        NG => NG
    );
    
    ctrl_latch: process(CLK, NRESET)
    begin
        if(NRESET = '0') then
            ndev_sel_int <= '1';
            rnw_int <= '1';
            wp_int <= '1';
            card_int <= '1';
            miso_int <= '1';
        elsif rising_edge(CLK) then
            ndev_sel_int <= NDEV_SEL;
            rnw_int <= RNW;
            wp_int <= WP;
            card_int <= CARD;
            miso_int <= MISO;
        end if;
    end process;
    
    DATA <= data_out when (data_en = '1') else (others => 'Z');      -- data bus tristate
    
    -- synthesis translate_off
    --data_dbg <= data_in;
    --add_dbg <= addr_low_int;
    -- synthesis translate_on
    
    data_latch: process(CLK)
    begin
        --if(rising_edge(CLK) and NDEV_SEL = '0') and (RNW = '0')) then
        --if rising_edge(CLK) and (NDEV_SEL = '0') then
        if rising_edge(CLK) then
            if (NDEV_SEL = '0') then
                data_in <= DATA;
            end if;
        end if;
    end process;
    
    add_latch: process(NDEV_SEL)
    begin
        if falling_edge(NDEV_SEL) then
            addr_low_int <= ADD_LOW;
        end if;
    end process;

end Behavioral;

