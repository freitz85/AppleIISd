----------------------------------------------------------------------------------
-- Company: n/a
-- Engineer: A. Fachat
-- 
-- Create Date:    12:37:11 05/07/2011 
-- Design Name:    SPI65B
-- Module Name:    SPI6502B - Behavioral 
-- Project Name:   CS/A NETUSB 2.0
-- Target Devices: CS/A NETUSB 2.0
-- Tool versions: 
-- Description:      An SPI interface for 6502-based computers (or compatible).
--                   modelled after the SPI65 interface by Daryl Rictor 
--                   (see http://sbc.rictor.org/io/65spi.html )
--                   This implementation here, however, is a complete reimplementation
--                   as the ABEL language of the original implementation is not supported
--                   by ISE anymore. 
--                   Also I added the interrupt input handling, replacing four of the 
--                   original SPI select outputs with four interrupt inputs
--                   Also folded out the single MISO input into one input for each of the
--                   four supported devices, reducing external parts count again by one.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - removed spiclk and replaced with clksrc and clkcnt_is_zero combination,
--                 to drive up SPI clock to half of input clock (and not one fourth only as before)
--                 unfortunately that costed one divisor bit to fit into the CPLD
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity AppleIISd is
Port (
        data_in : in STD_LOGIC_VECTOR (7 downto 0);
        data_out : out STD_LOGIC_VECTOR (7 downto 0);
        is_read : in  STD_LOGIC;
        nreset : in  STD_LOGIC;
        addr : in  STD_LOGIC_VECTOR (1 downto 0);
        phi0 : in  STD_LOGIC;
        ndev_sel : in  STD_LOGIC;
        clk : in  STD_LOGIC;
        miso: in std_logic;
        mosi : out  STD_LOGIC;
        sclk : out  STD_LOGIC;
        nsel : out  STD_LOGIC;
        wp : in  STD_LOGIC;
        card : in  STD_LOGIC;
        led : out  STD_LOGIC
    );

    constant DIV_WIDTH : integer := 3;

end AppleIISd;

architecture Behavioral of AppleIISd is
    
    --------------------------
    -- internal state
    signal spidatain: std_logic_vector (7 downto 0);
    signal spidataout: std_logic_vector (7 downto 0);
    signal inited: std_logic;   -- card initialized
    
    -- spi register flags
    signal tc: std_logic;       -- transmission complete; cleared on spi data read
    signal bsy: std_logic;      -- SPI busy
    signal frx: std_logic;      -- fast receive mode
    signal ece: std_logic;      -- external clock enable; 0=phi2, 1=external clock
    
    signal divisor: std_logic_vector(DIV_WIDTH-1 downto 0);
    signal slavesel: std_logic := '1';     -- slave select output (0=selected)
    signal int_miso: std_logic;
    --------------------------
    -- helper signals

    -- shift engine
    signal start_shifting: std_logic := '0';   -- shifting data
    signal shifting2: std_logic := '0';    -- shifting data
    signal shiftdone: std_logic;    -- shifting data done
    signal shiftcnt: std_logic_vector(3 downto 0);          -- shift counter (5 bit)
    
    -- spi clock
    signal clksrc: std_logic;                                   -- clock source (phi2 or clk_7m)
    -- TODO divcnt is not used at all??
    --signal divcnt: std_logic_vector(DIV_WIDTH-1 downto 0);          -- divisor counter
    signal shiftclk : std_logic;
    
begin    
    --led <= not (inited);
    led <= not (bsy or not slavesel);
    bsy <= start_shifting or shifting2;
    
    process(start_shifting, shiftdone, shiftclk)
    begin
        if (rising_edge(shiftclk)) then
            if (shiftdone = '1') then
                shifting2 <= '0';
            else
                shifting2 <= start_shifting;
            end if;
        end if; 
    end process;

    process(shiftcnt, nreset, shiftclk) 
    begin
        if (nreset = '0') then
            shiftdone <= '0';
        elsif (rising_edge(shiftclk)) then
            if (shiftcnt = "1111") then
                shiftdone <= '1';
            else
                shiftdone <= '0';
            end if;
        end if;
    end process;
    
    process(nreset, shifting2, shiftcnt, shiftclk)
    begin
        if (nreset = '0') then
            shiftcnt <= (others => '0');
        elsif (rising_edge(shiftclk)) then
            if (shifting2 = '1') then
                -- count phase
                shiftcnt <= shiftcnt + 1;               
            else
                shiftcnt <= (others => '0');
            end if;
        end if;
    end process;

    inproc: process(nreset, shifting2, shiftcnt, shiftclk, spidatain, miso)
    begin
        if (nreset = '0') then
            spidatain <= (others => '0');
        elsif (rising_edge(shiftclk)) then
            if (shifting2 = '1' and shiftcnt(0) = '1') then
                    -- shift in to input register
                    spidatain (7 downto 1) <= spidatain (6 downto 0);
                    spidatain (0) <= int_miso;
            end if;
        end if;
    end process;

    outproc: process(nreset, shifting2, spidataout, shiftcnt, shiftclk)
    begin
        if (nreset = '0') then
            mosi <= '1';
            sclk <= '0';
        else
            -- clock is sync'd
            if (rising_edge(shiftclk)) then
                if (shifting2='0' or shiftdone = '1') then
                    mosi <= '1';
                    sclk <= '0';
                else
                    -- output data directly from output register
                    case shiftcnt(3 downto 1) is
                        when "000" => mosi <= spidataout(7);
                        when "001" => mosi <= spidataout(6);
                        when "010" => mosi <= spidataout(5);
                        when "011" => mosi <= spidataout(4);
                        when "100" => mosi <= spidataout(3);
                        when "101" => mosi <= spidataout(2);
                        when "110" => mosi <= spidataout(1);
                        when "111" => mosi <= spidataout(0);
                        when others => mosi <= '1';
                    end case;
                    sclk <= '0' xor '0' xor shiftcnt(0);
                end if;
            end if;
        end if;
    end process;


    -- shift operation enable
    shiften: process(nreset, ndev_sel, is_read, addr, frx, shiftdone)
    begin
        -- start shifting
        if (nreset = '0' or shiftdone = '1') then
            start_shifting <= '0';
        elsif (rising_edge(ndev_sel) and addr="00" and (frx='1' or is_read='0')) then
            -- access to register 00, either write (is_read=0) or fast receive bit set (frx)
            -- then both types of access (write but also read)
            start_shifting <= '1';
        end if;
    end process;

    --------------------------
    -- spiclk - spi clock generation
    -- spiclk is still 2 times the freq. than sclk
    clksrc <= phi0 when (ece = '0') else clk;
    
    -- is a pulse signal to allow for divisor==0
    --shiftclk <= clksrc when divcnt = "000000" else '0';
    shiftclk <= clksrc when bsy = '1' else '0';
    
--    clkgen: process(nreset, divisor, clksrc)
--    begin
--        if (nreset = '0') then
--            divcnt <= divisor;
--        elsif (falling_edge(clksrc)) then
--            if (shiftclk = '1') then
--                divcnt <= divisor;
--            else
--                divcnt <= divcnt - 1;
--            end if;
--        end if;
--    end process;
    
    --------------------------
    -- interface section
    -- inputs
    int_miso <= (miso and not slavesel);
        
    -- outputs
    nsel <= slavesel;

    tc_proc: process (ndev_sel, shiftdone) 
    begin
        if (shiftdone = '1') then
            tc <= '1';
        elsif (rising_edge(ndev_sel) and addr="00") then
            tc <= '0';
        end if;
    end process;
    
    --------------------------
    -- cpu register section
    -- cpu read
    cpu_read: process(addr, spidatain, tc, bsy, frx, 
            ece, divisor, slavesel, wp, card, inited)
    begin
        case addr is
            when "00" =>        -- read SPI data in
                data_out <= spidatain;
            when "01" =>        -- read status register
                data_out(0) <= '0';
                data_out(1) <= '0';
                data_out(2) <= ece;
                data_out(3) <= '0';
                data_out(4) <= frx;
                data_out(5) <= bsy;
                data_out(6) <= '0';
                data_out(7) <= tc;
            when "10" =>        -- read sclk divisor
                data_out(DIV_WIDTH-1 downto 0) <= divisor;
                data_out(7 downto 3) <= (others => '0');
            when "11" =>        -- read slave select / slave interrupt state
                data_out(0) <= slavesel;
                data_out(4 downto 1) <= (others => '0');
                data_out(5) <= wp;
                data_out(6) <= card;
                data_out(7) <= inited;
            when others => 
                data_out <= (others => '0');
        end case;
    end process;

    -- cpu write 
    cpu_write: process(nreset, ndev_sel, is_read, addr, data_in, card, inited)
    begin
        if (nreset = '0') then
            ece <= '0';
            frx <= '0';
            slavesel <= '1';
            divisor <= (others => '0');
            spidataout <= (others => '1');
            inited <= '0';
        elsif (card = '1') then
            inited <= '0';
        elsif (rising_edge(ndev_sel) and is_read = '0') then
            case addr is
                when "00" =>        -- write SPI data out (see other process above)
                    spidataout <= data_in;
                when "01" =>        -- write status register
                    ece <= data_in(2);
                    frx <= data_in(4);
                    -- no bit 5 - 7
                when "10" =>        -- write divisor
                    divisor <= data_in(DIV_WIDTH-1 downto 0);
                when "11" =>        -- write slave select / slave interrupt enable
                    slavesel <= data_in(0);
                    -- no bit 1 - 6
                    inited <= data_in(7);
                when others =>
            end case;
        end if;
    end process;
    
end Behavioral;

