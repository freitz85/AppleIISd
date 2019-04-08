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

entity AppleIISd is
Port (
    ADD_HIGH : in std_logic_vector(11 downto 8);
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
    NWE : out std_logic;
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
    add_dbg : out std_logic_vector (1 downto 0);
    data_en_dbg : out std_logic
    -- synthesis translate_on
    
    );
end AppleIISd;

architecture Behavioral of AppleIISd is

    signal data_in : std_logic_vector (7 downto 0);
    signal data_out : std_logic_vector (7 downto 0);
    signal addr_low_int : std_logic_vector (1 downto 0);
    signal s_spi_data_in : std_logic_vector(7 downto 0);
    signal s_spi_data_out : std_logic_vector(7 downto 0);
    signal s_bsy : std_logic;
    signal s_tc : std_logic;
    signal s_ece : std_logic;
    signal s_frx : std_logic;
    
    signal data_en : std_logic;
    signal pgm_en : std_logic;

component Registers is
Port ( 
        ADDR : in  STD_LOGIC_VECTOR (1 downto 0);
        BUS_DATA_IN : in  STD_LOGIC_VECTOR (7 downto 0);
        BUS_DATA_OUT : out  STD_LOGIC_VECTOR (7 downto 0);
        SPI_DATA_IN : in  STD_LOGIC_VECTOR (7 downto 0);
        SPI_DATA_OUT : out  STD_LOGIC_VECTOR (7 downto 0);

        PGMEN : out STD_LOGIC;
        ECE : out STD_LOGIC;
        FRX : out STD_LOGIC;
        SLAVESEL : out STD_LOGIC;
        LED : out STD_LOGIC;
                  
        BSY : in STD_LOGIC;
        TC : in STD_LOGIC;
        WP : in STD_LOGIC;
        CARD : in STD_LOGIC;
        NRESET : in STD_LOGIC;
        NDEV_SEL : in STD_LOGIC;
        IS_READ : in STD_LOGIC
   ); 
end component;
        
component SpiController is
Port (
        BUS_DATA : in STD_LOGIC_VECTOR (7 downto 0);
        SPI_DATA : out STD_LOGIC_VECTOR (7 downto 0);
        IS_READ : in  STD_LOGIC;
        NRESET : in  STD_LOGIC;
        ADDR : in  STD_LOGIC_VECTOR (1 downto 0);
        CLK_SLOW : in  STD_LOGIC;
        NDEV_SEL : in  STD_LOGIC;
        CLK_FAST : in  STD_LOGIC;
        MISO: in std_logic;
        MOSI : out  STD_LOGIC;
        SCLK : out  STD_LOGIC;
        
        BSY : out STD_LOGIC;
        TC : out STD_LOGIC;
        FRX : in std_logic;
        ECE : in std_logic
    );
end component;

component AddressDecoder
Port ( 
        A : in  std_logic_vector (11 downto 8);
        B : out  std_logic_vector (10 downto 8);
        CLK : in std_logic;
        PHI0 : in std_logic;
        RNW : in  std_logic;
        NDEV_SEL : in  std_logic;
        NIO_SEL : in  std_logic;
        NIO_STB : in  std_logic;
        NRESET : in std_logic;
        DATA_EN : out  std_logic;
        PGM_EN : in std_logic;
        NG : out  std_logic;
        NOE : out  std_logic;
        NWE : out std_logic
      );
end component;


begin
    regs: Registers port map(
        ADDR => addr_low_int,
        BUS_DATA_IN => data_in,
        BUS_DATA_OUT => data_out,
        SPI_DATA_IN => s_spi_data_in,
        SPI_DATA_OUT => s_spi_data_out,
        PGMEN => pgm_en,
        ECE => s_ece,
        FRX => s_frx,
        SLAVESEL => NSEL,
        LED => LED,
        BSY => s_bsy,
        TC => s_tc,
        WP => WP,
        CARD => CARD,
        NRESET => NRESET,
        NDEV_SEL => NDEV_SEL,
        IS_READ => RNW
    );
    
    spi: SpiController port map(
        BUS_DATA => s_spi_data_out,
        SPI_DATA => s_spi_data_in,
        IS_READ => RNW,
        NRESET => NRESET,
        ADDR => addr_low_int,
        CLK_SLOW => PHI0,
        CLK_FAST => CLK,
        NDEV_SEL => NDEV_SEL,
        MISO => MISO,
        MOSI => MOSI,
        SCLK => SCLK,
        BSY => s_bsy,
        TC => s_tc,
        FRX => s_frx,
        ECE => s_ece
    );
    
    addDec: AddressDecoder port map(
        A => ADD_HIGH,
        B => B,
        CLK => CLK,
        PHI0 => PHI0,
        RNW => RNW,
        NDEV_SEL => NDEV_SEL,
        NIO_SEL => NIO_SEL,
        NIO_STB => NIO_STB,
        NRESET => NRESET,
        DATA_EN => data_en,
        PGM_EN => pgm_en,
        NOE => NOE,
        NWE => NWE,
        NG => NG
    );
    
    DATA <= data_out when (data_en = '1') else (others => 'Z');      -- data bus tristate
    
    -- synthesis translate_off
    data_dbg <= data_in;
    add_dbg <= addr_low_int;
    data_en_dbg <= data_en;
    -- synthesis translate_on
    
    data_latch: process(CLK)
    begin
        if falling_edge(CLK) then
            addr_low_int <= ADD_LOW;
            if (NDEV_SEL = '0') then
                data_in <= DATA;
            end if;
        end if;
    end process;

end Behavioral;

