----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/24/2018 08:16:12 PM
-- Design Name: 
-- Module Name: ro_buf_mux - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

entity ro_buf_mux is
    Port ( INPUT : in STD_LOGIC;
           MUX_IN : in STD_LOGIC_VECTOR(1 downto 0);
           OUTPUT : out STD_LOGIC);
end ro_buf_mux;

architecture Behavioral of ro_buf_mux is
    
    attribute KEEP : string;
    attribute S : string;
    
    signal buf_1 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal latch : STD_LOGIC;
    
    signal t_mux_out : STD_LOGIC;
    
    attribute KEEP of buf_1 : signal is "True";
    attribute S of buf_1 : signal is "True";
    attribute KEEP of latch : signal is "True";
    attribute S of latch : signal is "True";
    
begin

    -- latch process
    process(INPUT)
    begin
        latch <= INPUT;
    end process;

    buf_1(0) <= not INPUT;
    buf_1(1) <= not latch;
    buf_1(2) <= not INPUT;
    buf_1(3) <= not latch;
    
    process(buf_1, MUX_IN)
    begin
        case MUX_IN is
            when "00" => t_mux_out <= buf_1(0);
            when "01" => t_mux_out <= buf_1(1);
            when "10" => t_mux_out <= buf_1(2);
            when "11" => t_mux_out <= buf_1(3);
        end case;
    end process;

    OUTPUT <= t_mux_out;

end Behavioral;
