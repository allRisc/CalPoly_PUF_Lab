----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/24/2018 08:16:12 PM
-- Design Name: 
-- Module Name: configurable_ro - Behavioral
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

entity configurable_ro is
    Port ( INPUT : in STD_LOGIC_VECTOR (5 downto 0);
           ENABLE : in STD_LOGIC;
           OUTPUT : out STD_LOGIC);
end configurable_ro;

architecture Behavioral of configurable_ro is

attribute KEEP : string;
attribute S : string;

signal buf_out : STD_LOGIC_VECTOR(4 downto 0) := "00000";

attribute KEEP of buf_out : signal is "True";
attribute S of buf_out : signal is "True";

component ro_buf_mux is
    Port ( INPUT : in STD_LOGIC;
           MUX_IN : in STD_LOGIC_VECTOR(1 downto 0);
           OUTPUT : out STD_LOGIC);
end component;

begin

    GEN_BUF : 
    for i in 0 to 2 generate
        ro_buf : ro_buf_mux port map ( INPUT => buf_out(i),
                                       MUX_IN => INPUT((2*i + 1) downto (2*i)),
                                       OUTPUT => buf_out(i+1) );
    end generate GEN_BUF;

    buf_out(4) <= not buf_out(3);
    
    buf_out(0) <= buf_out(4) nand ENABLE;
    
    OUTPUT <= buf_out(0);

end Behavioral;
