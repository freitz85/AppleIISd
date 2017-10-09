-- Vhdl test bench created from schematic U:\AppleIISd\VHDL\AddressDecoder.sch - Mon Oct 09 20:12:16 2017
--
-- Notes: 
-- 1) This testbench template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the unit under test.
-- Xilinx recommends that these types always be used for the top-level
-- I/O of a design in order to guarantee that the testbench will bind
-- correctly to the timing (post-route) simulation model.
-- 2) To use this template as your testbench, change the filename to any
-- name of your choice with the extension .vhd, and use the "Source->Add"
-- menu in Project Navigator to import the testbench. Then
-- edit the user defined section below, adding code to generate the 
-- stimulus for your design.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;
ENTITY AddressDecoder_AddressDecoder_sch_tb IS
END AddressDecoder_AddressDecoder_sch_tb;
ARCHITECTURE behavioral OF AddressDecoder_AddressDecoder_sch_tb IS 

   COMPONENT AddressDecoder
   PORT( A10	:	IN	STD_LOGIC; 
          A9	:	IN	STD_LOGIC; 
          A8	:	IN	STD_LOGIC; 
          B10	:	OUT	STD_LOGIC; 
          B9	:	OUT	STD_LOGIC; 
          B8	:	OUT	STD_LOGIC; 
          NIO_SEL	:	IN	STD_LOGIC; 
          NDEV_SEL	:	IN	STD_LOGIC; 
          NOE	:	OUT	STD_LOGIC; 
          RNW	:	IN	STD_LOGIC; 
          NG	:	OUT	STD_LOGIC; 
          DATA_EN	:	OUT	STD_LOGIC; 
          NIO_STB	:	IN	STD_LOGIC);
   END COMPONENT;

   SIGNAL A10	:	STD_LOGIC := '0';
   SIGNAL A9	:	STD_LOGIC := '0';
   SIGNAL A8	:	STD_LOGIC := '0';
   SIGNAL B10	:	STD_LOGIC;
   SIGNAL B9	:	STD_LOGIC;
   SIGNAL B8	:	STD_LOGIC;
   SIGNAL NIO_SEL	:	STD_LOGIC := '1';
   SIGNAL NDEV_SEL	:	STD_LOGIC := '1';
   SIGNAL NOE	:	STD_LOGIC;
   SIGNAL RNW	:	STD_LOGIC := '1';
   SIGNAL NG	:	STD_LOGIC;
   SIGNAL DATA_EN	:	STD_LOGIC;
   SIGNAL NIO_STB	:	STD_LOGIC := '1';

BEGIN

   UUT: AddressDecoder PORT MAP(
		A10 => A10, 
		A9 => A9, 
		A8 => A8, 
		B10 => B10, 
		B9 => B9, 
		B8 => B8, 
		NIO_SEL => NIO_SEL, 
		NDEV_SEL => NDEV_SEL, 
		NOE => NOE, 
		RNW => RNW, 
		NG => NG, 
		DATA_EN => DATA_EN, 
		NIO_STB => NIO_STB
   );

-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      WAIT; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
