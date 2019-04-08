----------------------------------------------------------------------------------
--
-- Spi controller for 6502 systems
-- based on a design by A. Fachat
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity SpiController is
Port (
        BUS_DATA : in STD_LOGIC_VECTOR (7 downto 0);
        SPI_DATA : out STD_LOGIC_VECTOR (7 downto 0);
        IS_READ : in  STD_LOGIC;
        NRESET : in  STD_LOGIC;
        ADDR : in  STD_LOGIC_VECTOR (1 downto 0);
        CLK_SLOW : in  STD_LOGIC;
        CLK_FAST : in  STD_LOGIC;
        NDEV_SEL : in  STD_LOGIC;
        MISO: in std_logic;
        MOSI : out  STD_LOGIC;
        SCLK : out  STD_LOGIC;
        
        BSY : out STD_LOGIC;
        TC : out STD_LOGIC;
        FRX : in std_logic;
        ECE : in std_logic
    );

end SpiController;

architecture Behavioral of SpiController is
    
    --------------------------
    -- internal state
    signal spidatain: std_logic_vector (7 downto 0);
    
    --------------------------
    -- helper signals

    -- shift engine
    signal s_start_shifting: std_logic := '0';   -- shifting data
    signal s_shifting2: std_logic := '0';    -- shifting data
    signal s_shiftdone: std_logic;    -- shifting data done
    signal s_shiftcnt: std_logic_vector(3 downto 0);          -- shift counter (5 bit)
    
    -- spi clock
    signal s_clksrc: std_logic;                                   -- clock source (phi2 or clk_7m)
    signal s_shiftclk : std_logic;
    
begin    
    --------------------------
    -- spiclk - spi clock generation
    -- spiclk is still 2 times the freq. than SCLK
    s_clksrc <= CLK_SLOW when (ECE = '0') else CLK_FAST;
    
    -- is a pulse signal to allow for divisor==0
    s_shiftclk <= s_clksrc when (s_start_shifting or s_shifting2) = '1' else '0';
    
    
    BSY <= s_start_shifting or s_shifting2;
    SPI_DATA <= spidatain;
    
    process(s_start_shifting, s_shiftdone, s_shiftclk)
    begin
        if (rising_edge(s_shiftclk)) then
            if (s_shiftdone = '1') then
                s_shifting2 <= '0';
            else
                s_shifting2 <= s_start_shifting;
            end if;
        end if; 
    end process;

    process(s_shiftcnt, NRESET, s_shiftclk) 
    begin
        if (NRESET = '0') then
            s_shiftdone <= '0';
        elsif (rising_edge(s_shiftclk)) then
            if (s_shiftcnt = "1111") then
                s_shiftdone <= '1';
            else
                s_shiftdone <= '0';
            end if;
        end if;
    end process;
    
    process(NRESET, s_shifting2, s_shiftcnt, s_shiftclk)
    begin
        if (NRESET = '0') then
            s_shiftcnt <= (others => '0');
        elsif (rising_edge(s_shiftclk)) then
            if (s_shifting2 = '1') then
                -- count phase
                s_shiftcnt <= s_shiftcnt + 1;               
            else
                s_shiftcnt <= (others => '0');
            end if;
        end if;
    end process;

    inproc: process(NRESET, s_shifting2, s_shiftcnt, s_shiftclk, spidatain, miso)
    begin
        if (NRESET = '0') then
            spidatain <= (others => '0');
        elsif (rising_edge(s_shiftclk)) then
            if (s_shifting2 = '1' and s_shiftcnt(0) = '1') then
                    -- shift in to input register
                    spidatain (7 downto 1) <= spidatain (6 downto 0);
                    spidatain (0) <= MISO;
            end if;
        end if;
    end process;

    outproc: process(NRESET, s_shifting2, BUS_DATA, s_shiftcnt, s_shiftclk)
    begin
        if (NRESET = '0') then
            MOSI <= '1';
            SCLK <= '1';
        else
            -- clock is sync'd
            if (rising_edge(s_shiftclk)) then
                if (s_shifting2='0' or s_shiftdone = '1') then
                    MOSI <= '1';
                    SCLK <= '1';
                else
                    -- output data directly from output register
                    case s_shiftcnt(3 downto 1) is
                        when "000" => MOSI <= BUS_DATA(7);
                        when "001" => MOSI <= BUS_DATA(6);
                        when "010" => MOSI <= BUS_DATA(5);
                        when "011" => MOSI <= BUS_DATA(4);
                        when "100" => MOSI <= BUS_DATA(3);
                        when "101" => MOSI <= BUS_DATA(2);
                        when "110" => MOSI <= BUS_DATA(1);
                        when "111" => MOSI <= BUS_DATA(0);
                        when others => MOSI <= '1';
                    end case;
                    SCLK <= s_shiftcnt(0);
                end if;
            end if;
        end if;
    end process;


    -- shift operation enable
    shiften: process(NRESET, NDEV_SEL, IS_READ, ADDR, FRX, s_shiftdone)
    begin
        -- start shifting
        if (NRESET = '0' or s_shiftdone = '1') then
            s_start_shifting <= '0';
        elsif (rising_edge(NDEV_SEL) and ADDR="00" and (FRX='1' or IS_READ='0')) then
            -- access to register 00, either write (IS_READ=0) or fast receive bit set (frx)
            -- then both types of access (write but also read)
            s_start_shifting <= '1';
        end if;
    end process;
    
    tc_proc: process (NDEV_SEL, s_shiftdone) 
    begin
        if (s_shiftdone = '1') then
            TC <= '1';
        elsif (rising_edge(NDEV_SEL) and ADDR="00") then
            TC <= '0';
        end if;
    end process;
    
end Behavioral;
