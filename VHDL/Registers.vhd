----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:04:43 04/08/2019 
-- Design Name: 
-- Module Name:    Registers - Behavioral 
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

entity Registers is
    Port ( ADDR : in  STD_LOGIC_VECTOR (1 downto 0);
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
           IS_READ : in STD_LOGIC);
           
end Registers;

architecture Behavioral of Registers is

    signal s_pgmen : STD_LOGIC;
    signal s_ece : STD_LOGIC;
    signal s_frx : STD_LOGIC;
    signal s_slavesel : STD_LOGIC;
    signal s_sdhc : STD_LOGIC;
    signal s_inited : STD_LOGIC;
begin

    PGMEN <= s_pgmen;
    ECE <= s_ece;
    FRX <= s_frx;
    SLAVESEL <= s_slavesel;
    LED <= not (BSY or not s_slavesel);
    
    --------------------------
    -- cpu register section
    -- cpu read
    cpu_read: process(ADDR, SPI_DATA_IN, tc, bsy, s_frx, s_pgmen,
            s_ece, s_slavesel, wp, CARD, s_sdhc, s_inited)
    begin
        case ADDR is
            when "00" =>        -- read SPI data in
                BUS_DATA_OUT <= SPI_DATA_IN;
            when "01" =>        -- read status register
                BUS_DATA_OUT(0) <= s_pgmen;
                BUS_DATA_OUT(1) <= '0';
                BUS_DATA_OUT(2) <= s_ece;
                BUS_DATA_OUT(3) <= '0';
                BUS_DATA_OUT(4) <= s_frx;
                BUS_DATA_OUT(5) <= BSY;
                BUS_DATA_OUT(6) <= '0';
                BUS_DATA_OUT(7) <= TC;
            -- "10" is unused
            when "11" =>        -- read slave select / slave interrupt state
                BUS_DATA_OUT(0) <= s_slavesel;
                BUS_DATA_OUT(3 downto 1) <= (others => '0');
                BUS_DATA_OUT(4) <= s_sdhc;
                BUS_DATA_OUT(5) <= WP;
                BUS_DATA_OUT(6) <= CARD;
                BUS_DATA_OUT(7) <= s_inited;
            when others => 
                BUS_DATA_OUT <= (others => '0');
        end case;
    end process;

    -- cpu write 
    cpu_write: process(NRESET, NDEV_SEL, IS_READ, ADDR, BUS_DATA_IN, CARD)
    begin
        if (NRESET = '0') then
            s_ece <= '0';
            s_frx <= '0';
            s_slavesel <= '1';
            SPI_DATA_OUT <= (others => '1');
            s_sdhc <= '0';
            s_inited <= '0';
            s_pgmen <= '0';
        elsif (CARD = '1') then
            s_sdhc <= '0';
            s_inited <= '0';
        elsif (rising_edge(NDEV_SEL) and IS_READ = '0') then
            case ADDR is
                when "00" =>        -- write SPI data out (see other process above)
                    SPI_DATA_OUT <= BUS_DATA_IN;
                when "01" =>        -- write status register
                    s_pgmen <= BUS_DATA_IN(0);
                    s_ece <= BUS_DATA_IN(2);
                    s_frx <= BUS_DATA_IN(4);
                    -- no bit 5 - 7
                -- "10" is unused
                when "11" =>        -- write slave select / slave interrupt enable
                    s_slavesel <= BUS_DATA_IN(0);
                    -- no bit 1 - 3
                    s_sdhc <= BUS_DATA_IN(4);
                    -- no bit 5 - 6
                    s_inited <= BUS_DATA_IN(7);
                when others =>
            end case;
        end if;
    end process;
    
end Behavioral;

