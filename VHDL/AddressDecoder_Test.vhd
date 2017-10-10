--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:42:22 10/10/2017
-- Design Name:   
-- Module Name:   C:/Git/AppleIISd/VHDL/AddressDecoder_Test.vhd
-- Project Name:  AppleIISd
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: AddressDecoder
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
 
ENTITY AddressDecoder_Test IS
END AddressDecoder_Test;
 
ARCHITECTURE behavior OF AddressDecoder_Test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT AddressDecoder
    PORT(
         A : IN  std_logic_vector(10 downto 8);
         B : OUT  std_logic_vector(10 downto 8);
         RNW : IN  std_logic;
         NDEV_SEL : IN  std_logic;
         NIO_SEL : IN  std_logic;
         NIO_STB : IN  std_logic;
         NRESET : IN  std_logic;
         DATA_EN : OUT  std_logic;
         NG : OUT  std_logic;
         NOE : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(10 downto 8) := "101";
   signal RNW : std_logic := '1';
   signal NDEV_SEL : std_logic := '1';
   signal NIO_SEL : std_logic := '1';
   signal NIO_STB : std_logic := '1';
   signal NRESET : std_logic := '1';

 	--Outputs
   signal B : std_logic_vector(10 downto 8);
   signal DATA_EN : std_logic;
   signal NG : std_logic;
   signal NOE : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: AddressDecoder PORT MAP (
          A => A,
          B => B,
          RNW => RNW,
          NDEV_SEL => NDEV_SEL,
          NIO_SEL => NIO_SEL,
          NIO_STB => NIO_STB,
          NRESET => NRESET,
          DATA_EN => DATA_EN,
          NG => NG,
          NOE => NOE
        );
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 50 ns;	
      NRESET <= '0';
      wait for 50 ns;
      NRESET <= '1';
      wait for 50 ns;

      -- insert stimulus here 
      -- CPLD access
      NDEV_SEL <= '0';
      wait for 10 ns;
      NDEV_SEL <= '1';
      wait for 20 ns;
      -- CnXX access
      NIO_SEL <= '0';
      wait for 10 ns;
      NIO_SEL <= '1';
      wait for 20 ns;
      -- C8xx access, selected
      NIO_STB <= '0';
      wait for 10 ns;
      NIO_STB <= '1';
      wait for 20 ns;
      -- CPLD access
      NDEV_SEL <= '0';
      wait for 10 ns;
      NDEV_SEL <= '1';
      wait for 20 ns;
      -- CFFF access
      A <= "111";
      NIO_STB <= '0';
      wait for 10 ns;
      A <= "000";
      NIO_STB <= '1';
      wait for 20 ns;
      -- C8xx access, unselected
      NIO_STB <= '0';
      wait for 10 ns;
      NIO_STB <= '1';
      wait for 20 ns;

      wait;
   end process;

END;
