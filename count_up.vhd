----------------------------------------------------------------------------------
-- Company: Cal Poly
-- Engineer: Benjamin Davis
-- 
-- Create Date: 10/18/2018 04:07:34 PM
-- Design Name: Count and Hold
-- Module Name: Count_and_hold - Behavioral
-- Project Name: Ring_Oscillator_PUF
-- Target Devices: BASYS 3
-- Description: 
--      Implements a counter which holds when it reaches its max value
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

entity count_up is
    Port ( RESET : in STD_LOGIC;
           INPUT : in STD_LOGIC;
           ENABLE : in STD_LOGIC;
           OUTPUT : out STD_LOGIC_VECTOR (9 downto 0));
end count_up;

architecture Behavioral of count_up is

attribute KEEP : string;
attribute S : string;

signal count_out : std_logic_vector(9 downto 0) := "0000000000";

attribute KEEP of count_out : signal is "True";
attribute S of count_out : signal is "True";

begin

    process (RESET, INPUT, ENABLE)
    begin
        if (RESET = '1') then
            count_out <= (others => '0');
        elsif (ENABLE = '1') then
            if rising_edge(INPUT) then
                count_out <= count_out + 1;
            end if;
        end if;
    end process;
    
    OUTPUT <= count_out;

end Behavioral;
