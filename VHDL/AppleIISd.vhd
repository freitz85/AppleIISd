----------------------------------------------------------------------------------
-- Company: n/a
-- Engineer: A. Fachat
-- 
-- Create Date:    12:37:11 05/07/2011 
-- Design Name: 	 SPI65B
-- Module Name:    SPI6502B - Behavioral 
-- Project Name:   CS/A NETUSB 2.0
-- Target Devices: CS/A NETUSB 2.0
-- Tool versions: 
-- Description: 	 An SPI interface for 6502-based computers (or compatible).
--						 modelled after the SPI65 interface by Daryl Rictor 
--						 (see http://sbc.rictor.org/io/65spi.html )
-- 					 This implementation here, however, is a complete reimplementation
-- 					 as the ABEL language of the original implementation is not supported
--						 by ISE anymore. 
--						 Also I added the interrupt input handling, replacing four of the 
--						 original SPI select outputs with four interrupt inputs
--						 Also folded out the single MISO input into one input for each of the
--						 four supported devices, reducing external parts count again by one.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - removed spiclk and replaced with clksrc and clkcnt_is_zero combination,
--						 to drive up SPI clock to half of input clock (and not one fourth only as before)
--						 unfortunately that costed one divisor bit to fit into the CPLD
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use AddressDecoder.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AppleIISd is
Port ( data : inout  STD_LOGIC_VECTOR (7 downto 0);
       nrw : in  STD_LOGIC;
       nirq : out  STD_LOGIC;
       nreset : in  STD_LOGIC;
       addr : in  STD_LOGIC_VECTOR (1 downto 0);
       nphi2 : in  STD_LOGIC;
       ndev_sel : in  STD_LOGIC;
       extclk : in  STD_LOGIC;
       spi_miso: in std_logic;
       spi_mosi : out  STD_LOGIC;
       spi_sclk : out  STD_LOGIC;
       spi_Nsel : out  STD_LOGIC;
       wp : in  STD_LOGIC;
       card : in  STD_LOGIC;
       led : out  STD_LOGIC;

       a8 : in  std_logic;
       a9 : in  std_logic;
       a10 : in  std_logic;
       nio_sel : in  std_logic;
       nio_stb : in  std_logic;
       b8 : out  std_logic;
       b9 : out  std_logic;
       b10 : out  std_logic;
       noe : out  std_logic;
       ng : out  std_logic
     );

    constant DIV_WIDTH : integer := 3;

end AppleIISd;

architecture Behavioral of AppleIISd is
	
	-- interface signals
	signal selected: std_logic;
	signal reset: std_logic;
	signal int_out: std_logic;
	signal is_read: std_logic;
	signal int_din: std_logic_vector (7 downto 0);
	signal int_dout: std_logic_vector (7 downto 0);
	
	signal int_mosi: std_logic;
	signal int_miso: std_logic;
	signal int_sclk: std_logic;
	
	--------------------------
	-- internal state
	signal spidatain: std_logic_vector (7 downto 0);
	signal spidataout: std_logic_vector (7 downto 0);
	signal spiint: std_logic;	-- spi interrupt state
    signal inited: std_logic;   -- card initialized
	
	-- spi register flags
	signal tc: std_logic;		-- transmission complete; cleared on spi data read
	signal ier: std_logic;		-- enable general SPI interrupts
	signal bsy: std_logic;		-- SPI busy
	signal frx: std_logic;		-- fast receive mode
	signal tmo: std_logic;		-- tri-state mosi
	signal ece: std_logic;		-- external clock enable; 0=phi2, 1=external clock
	signal cpol: std_logic;		-- shift clock polarity; 0=rising edge, 1=falling edge
	signal cpha: std_logic;		-- shift clock phase; 0=leading edge, 1=rising edge
	
	signal divisor: std_logic_vector(DIV_WIDTH-1 downto 0);
	
	signal slavesel: std_logic;		-- slave select output (0=selected)
	signal slaveinten: std_logic;	-- slave interrupt enable (1=enabled)
	
	--------------------------
	-- helper signals

	-- shift engine
	signal start_shifting: std_logic;	-- shifting data
	signal shifting2: std_logic;	-- shifting data
	signal shiftdone: std_logic;	-- shifting data done
	signal shiftcnt: std_logic_vector(3 downto 0);			-- shift counter (5 bit)
	
	-- spi clock
	signal clksrc: std_logic;									-- clock source (phi2 or extclk)
	signal divcnt: std_logic_vector(DIV_WIDTH-1 downto 0);			-- divisor counter
	
	signal shiftclk : std_logic;

	component AddressDecoder
   port ( A8     : in    std_logic; 
          A9     : in    std_logic; 
          A10    : in    std_logic; 
          CLK : in    std_logic; 
          NDEV_SEL : in std_logic;
          NIO_SEL : in    std_logic; 
          NIO_STB : in    std_logic; 
          B8   : out   std_logic; 
          B9   : out   std_logic; 
          B10  : out   std_logic; 
          NOE     : out   std_logic);
	end component;
	
begin
	add_dec : AddressDecoder
      port map (A8=>a8,      
                A9=>a9,
			 A10=>a10,
			 CLK=>extclk,
			 NDEV_SEL=>ndev_sel,
			 NIO_SEL=>nio_sel,
			 NIO_STB=>nio_stb,
			 B8=>b8,
			 B9=>b9,
			 B10=>b10,
			 NOE=>noe);
	
			
	led <= not (bsy or not slavesel); --'0'; --shifting2; --shiftdone; --shiftcnt(2);
	ng <=  ndev_sel and nio_sel and nio_stb;
	--------------------------
	
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

	process(shiftcnt, reset, shiftclk) 
	begin
		if (reset = '1') then
			shiftdone <= '0';
		elsif (rising_edge(shiftclk)) then
			if (shiftcnt = "1111") then
				shiftdone <= '1';
			else
				shiftdone <= '0';
			end if;
		end if;
	end process;
	
	process(reset, shifting2, shiftcnt, shiftclk)
	begin
		if (reset='1') then
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

	inproc: process(reset, shifting2,  
						shiftcnt, shiftclk, spidatain, int_miso)
	begin
		if (reset='1') then
			spidatain <= (others => '0');
		elsif (rising_edge(shiftclk)) then
			if (shifting2 = '1' and shiftcnt(0) = '1') then
					-- shift in to input register
					spidatain (7 downto 1) <= spidatain (6 downto 0);
					spidatain (0) <= int_miso;
			end if;
		end if;
	end process;

	outproc: process(reset, shifting2, spidataout, cpol, cpha, 
						shiftcnt, shiftclk)
	begin
		if (reset='1') then
			int_mosi <= '1';
			int_sclk <= cpol;
		else
			-- clock is sync'd
			if (rising_edge(shiftclk)) then
				if (shifting2='0' or shiftdone = '1') then
					int_mosi <= '1';
					int_sclk <= cpol;
				else
					-- output data directly from output register
					case shiftcnt(3 downto 1) is
						when "000" => int_mosi <= spidataout(7);
						when "001" => int_mosi <= spidataout(6);
						when "010" => int_mosi <= spidataout(5);
						when "011" => int_mosi <= spidataout(4);
						when "100" => int_mosi <= spidataout(3);
						when "101" => int_mosi <= spidataout(2);
						when "110" => int_mosi <= spidataout(1);
						when "111" => int_mosi <= spidataout(0);
						when others => int_mosi <= '1';
					end case;
					int_sclk <= cpol xor cpha xor shiftcnt(0);
				end if;
			end if;
		end if;
	end process;


	-- shift operation enable
	shiften: process(reset, selected, nrw, addr, frx, shiftdone)
	begin
		-- start shifting
		if (reset='1' or shiftdone='1') then
			start_shifting <= '0';
		elsif (falling_edge(selected) and addr="00" and (frx='1' or nrw='0')) then
			-- access to register 00, either write (nrw=0) or fast receive bit set (frx)
			-- then both types of access (write but also read)
			start_shifting <= '1';
		end if;
	end process;

	--------------------------
	-- spiclk - spi clock generation
	-- spiclk is still 2 times the freq. than sclk
	clksrc <= nphi2 when (ece = '0') else extclk;
	
	-- is a pulse signal to allow for divisor==0
	--shiftclk <= clksrc when divcnt = "000000" else '0';
	shiftclk <= clksrc when bsy = '1' else '0';
	
	clkgen: process(reset, divisor, clksrc)
	begin
		if (reset='1') then
			divcnt <= divisor;
			--spiclk <= '0';
		elsif (falling_edge(clksrc)) then
			if (shiftclk = '1') then
				divcnt <= divisor;
				--spiclk <= not(spiclk);
			else
				divcnt <= divcnt - 1;
			end if;
		end if;
	end process;
	
	--------------------------
	-- interrupt generation
	int_out <= spiint and slaveinten;

	--------------------------
	-- interface section
	-- inputs
	reset <= not (nreset);
	selected <= not(ndev_sel); -- and cpu_phi2;
	is_read <= selected and nphi2 and nrw;
	int_din <= data;	

	int_miso <= (spi_miso and not slavesel);
	
	-- outputs
	data <= int_dout when (is_read='1') else (others => 'Z');		-- data bus tristate
	nirq <= '0' when (int_out='1') else 'Z';			-- wired-or
	spi_sclk <= int_sclk;
	spi_mosi <= int_mosi when tmo='0' else 'Z';		-- mosi tri-state
	spi_Nsel <= slavesel;
	
	tc_proc: process (selected, shiftdone) 
	begin
		if (shiftdone = '1') then
			tc <= '1';
		elsif (falling_edge(selected) and addr="00"
		--elsif (falling_edge(cpu_phi2) and selected='1' and addr="00" 
				--and nrw='1'		-- both reads _and_ writes clear the interrupt
				) then
			tc <= '0';
		end if;
	end process;
	
	spiint <= tc and ier;

	--------------------------
	-- cpu register section
	-- cpu read
	cpu_read: process (is_read, addr, 
			spidatain, tc, ier, bsy, frx, tmo, ece, cpol, cpha, divisor,
			slavesel, slaveinten, wp, card, inited)
	begin
		if (is_read = '1') then 
			case addr is
				when "00" =>		-- read SPI data in
					int_dout <= spidatain;
				when "01" => 		-- read status register
					int_dout(0) <= cpha;
					int_dout(1) <= cpol;
					int_dout(2) <= ece;
					int_dout(3) <= tmo;
					int_dout(4) <= frx;
					int_dout(5) <= bsy;
					int_dout(6) <= ier;
					int_dout(7) <= tc;
				when "10" =>		-- read sclk divisor
					int_dout(DIV_WIDTH-1 downto 0) <= divisor;
					int_dout(7 downto 3) <= (others => '0');
				when "11" =>		-- read slave select / slave interrupt state
					int_dout(0) <= slavesel;
					int_dout(3 downto 1) <= (others => '0');
					int_dout(4) <= slaveinten;
					int_dout(5) <= wp;
					int_dout(6) <= card;
					int_dout(7) <= inited;
				when others => 
					int_dout <= (others => '0');
			end case;
		else
			int_dout <= (others => '0');
		end if;
	end process;

	-- cpu write 
	cpu_write: process(reset, selected, nrw, addr, int_din, inited)
	begin
		if (reset = '1') then
			cpha <= '0';
			cpol <= '0';
			ece <= '0';
			tmo <= '0';
			frx <= '0';
			ier <= '0';
			slavesel <= '1';
			slaveinten <= '0';
            inited <= '0';
			divisor <= (others => '0');
		elsif (falling_edge(selected) and nrw = '0') then
		--elsif (falling_edge(cpu_phi2) and selected='1' and nrw='0') then
			case addr is
				when "00" =>		-- write SPI data out (see other process above)
					spidataout <= int_din;
				when "01" =>		-- write status register
					cpha <= int_din(0);
					cpol <= int_din(1);
					ece <= int_din(2);
					tmo <= int_din(3);
					frx <= int_din(4);
					-- no bit 5
					ier <= int_din(6);
					-- no bit 7;
				when "10" => 		-- write divisor
					divisor <= int_din(DIV_WIDTH-1 downto 0);
				when "11" =>		-- write slave select / slave interrupt enable
					slavesel <= int_din(0);
					slaveinten <= int_din(4);
                    inited <= int_din(7);
				when others =>
			end case;
		end if;
	end process;
	
end Behavioral;

