--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:21:20 10/09/2017
-- Design Name:   
-- Module Name:   U:/AppleIISd/VHDL/AppleIISd_Test.vhd
-- Project Name:  AppleIISd
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: AppleIISd
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY AppleIISd_Test IS
END AppleIISd_Test;
 
ARCHITECTURE behavior OF AppleIISd_Test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT AppleIISd
    PORT(
         data_in : IN  std_logic_vector(7 downto 0);
         data_out : OUT  std_logic_vector(7 downto 0);
         is_read : IN  std_logic;
         reset : IN  std_logic;
         addr : IN  std_logic_vector(1 downto 0);
         phi0 : IN  std_logic;
         selected : IN  std_logic;
         clk : IN  std_logic;
         miso : IN  std_logic;
         mosi : OUT  std_logic;
         sclk : OUT  std_logic;
         nsel : OUT  std_logic;
         wp : IN  std_logic;
         card : IN  std_logic;
         led : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal data_in : std_logic_vector(7 downto 0) := (others => '1');
   signal is_read : std_logic := '0';
   signal reset : std_logic := '0';
   signal addr : std_logic_vector(1 downto 0) := (others => '0');
   signal phi0 : std_logic := '1';
   signal selected : std_logic := '0';
   signal clk : std_logic := '0';
   signal miso : std_logic := '0';
   signal wp : std_logic := '0';
   signal card : std_logic := '0';

 	--Outputs
   signal data_out : std_logic_vector(7 downto 0);
   signal mosi : std_logic;
   signal sclk : std_logic;
   signal nsel : std_logic;
   signal led : std_logic;

   -- Clock period definitions
   constant clk_period : time := 142 ns;    -- 7MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: AppleIISd PORT MAP (
          data_in => data_in,
          data_out => data_out,
          is_read => is_read,
          reset => reset,
          addr => addr,
          phi0 => phi0,
          selected => selected,
          clk => clk,
          miso => miso,
          mosi => mosi,
          sclk => sclk,
          nsel => nsel,
          wp => wp,
          card => card,
          led => led
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process; 
   
   phi0_process :process(clk)
   variable counter : integer range 0 to 7;
   begin
        if rising_edge(clk) or falling_edge(clk) then
            counter := counter + 1;
            if counter = 7 then
                phi0 <= not phi0;
                counter := 0;
            end if;
        end if;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state.
      wait for clk_period * 20;	
      reset <= '1';
      wait for clk_period * 20;
      reset <= '0';
      wait for clk_period * 5;
      wait until rising_edge(phi0);
      -- insert stimulus here 
      selected <= '1';
      wait for clk_period;
      data_in <= (others => '0');
      wait until falling_edge(phi0);
      selected <= '0';
      wait for clk_period;
      data_in <= (others => '1');
      wait;
   end process;

END;
