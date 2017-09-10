----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:26:04 09/09/2017 
-- Design Name: 
-- Module Name:    sr_latch - Behavioral 
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


entity SR_Latch is  
Port ( S,R : in STD_LOGIC;  
       Q : inout STD_LOGIC;  
       Q_n : inout STD_LOGIC;  
       Reset : in STD_LOGIC;
       Clk : in STD_LOGIC);
end SR_Latch;  
   
architecture SR_Latch_arch of SR_Latch is  
begin  
    process (S,R,Q,Q_n, Reset, Clk)  
    begin  
        if(rising_edge(Clk)) then
            if(Reset = '1') then
                Q <= '0';
                Q_n <= '1';
            else
                Q <= R NOR Q_n;  
                Q_n <= S NOR Q; 
            end if; 
        end if;
   end process;  
end SR_Latch_arch;
