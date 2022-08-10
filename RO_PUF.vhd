----------------------------------------------------------------------------------
-- Company: Cal Poly    
-- Engineer: Benjamin Davis
-- 
-- Create Date: 10/19/2018 01:43:29 PM
-- Design Name: Ring Oscillator PUF
-- Module Name: RO_PUF - Behavioral
-- Project Name: Ring Oscillator PUF
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--      
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity RO_PUF is
    Port (    sw : in STD_LOGIC_VECTOR (15 downto 0);
             btn : in STD_LOGIC;
             clk : in STD_LOGIC;
              JB : in STD_LOGIC_VECTOR (7 downto 0);
             led : out STD_LOGIC_VECTOR (15 downto 0);
             seg : out STD_LOGIC_VECTOR (6 downto 0);
              an : out STD_LOGIC_VECTOR (3 downto 0);
           READY : out STD_LOGIC;
              JC : out STD_LOGIC_VECTOR (7 downto 0));
end RO_PUF;

architecture Behavioral of RO_PUF is

signal puf_output, puf_input : std_logic_vector(7 downto 0);
signal puf_last_input : std_logic_vector(7 downto 0) := x"00";
signal puf_all_set : std_logic;
signal puf_reset : std_logic;
signal puf_enable : std_logic;

signal sha128_start, sha128_ready : std_logic;
signal sha128_input, sha128_last_input : std_logic_vector(15 downto 0) := x"0000";
signal sha128_out : std_logic_vector(127 downto 0);

signal sseg_input : std_logic_vector(15 downto 0);

component config_ro_puf is
    Port ( CLK : in STD_LOGIC;
           ENABLE : in STD_LOGIC;
           RESET : in STD_LOGIC;
           CHALLENGE : in STD_LOGIC_VECTOR (7 downto 0);
           SET : out STD_LOGIC;
           RESPONSE : out STD_LOGIC_VECTOR (7 downto 0));
end component;

component sha128_simple is
    Port ( CLK : in STD_LOGIC;
           DATA_IN : in STD_LOGIC_VECTOR (15 downto 0);
           RESET : in STD_LOGIC;
           START : in STD_LOGIC;
           READY : out STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (127 downto 0));
end component;

component sseg_des is
    Port ( COUNT : in std_logic_vector(15 downto 0); 				  
           CLK : in std_logic;
		   VALID : in std_logic;
           DISP_EN : out std_logic_vector(3 downto 0);
           SEGMENTS : out std_logic_vector(6 downto 0));
end component;

begin

    seven_seg : sseg_des port map ( COUNT => sseg_input,
                                    CLK => clk,
                                    VALID => '1',
                                    DISP_EN => an,
                                    SEGMENTS => seg);
                                    

    c_ro_puf : config_ro_puf port map ( CLK => clk,
                                      ENABLE => puf_enable,
                                      RESET => puf_reset,
                                      CHALLENGE => puf_input,
                                      SET => puf_all_set,
                                      RESPONSE => puf_output);
    
    sha128 : sha128_simple port map ( CLK => clk,
                                      DATA_IN => sha128_input,
                                      RESET => btn,
                                      START => sha128_start,
                                      READY => sha128_ready,
                                      DATA_OUT => sha128_out);
                                      
    
    -- Process to handle puf reset
    process (btn, puf_input, clk)
    begin
        if btn = '1' then
            puf_reset <= '1';
        elsif rising_edge(clk)  then
            if puf_input /= puf_last_input then
                puf_last_input <= puf_input;
                puf_reset <= '1';
            else
                puf_reset <= '0';
            end if;
        end if;
    end process;
    
    -- Process to handle when sha128 should be re-run
    process (sha128_ready, sha128_input, clk)
    begin
        if sha128_ready = '0' then
            sha128_start <= '0';
        elsif rising_edge(clk) then
            if (sha128_input /= sha128_last_input) then
                sha128_start <= '1';
                sha128_last_input <= sha128_input;
            else
                sha128_start <= '0';
            end if;
        end if;
    end  process;
    
    -- Process to handle displaying to 7-segment display
    --  This is determined using sw(15 downto 12). When all
    --  are '0' then output is the concatenation of puf_input and puf_output
    --  when not all are zero is is displaying the correct byte from sha
    process (sw(15 downto 12), puf_input, puf_output, sha128_out)
    begin
        case sw(15 downto 12) is
            when x"0" => sseg_input <= puf_input & puf_output;
            when x"1" => sseg_input <= sha128_out(15 downto 0);
            when x"2" => sseg_input <= sha128_out(31 downto 16);
            when x"3" => sseg_input <= sha128_out(47 downto 32);
            when x"4" => sseg_input <= sha128_out(63 downto 48);
            when x"5" => sseg_input <= sha128_out(79 downto 64);
            when x"6" => sseg_input <= sha128_out(95 downto 80);
            when x"7" => sseg_input <= sha128_out(111 downto 96);
            when x"8" => sseg_input <= sha128_out(127 downto 112);
            when others => sseg_input <= x"0000";
        end case;
    end process;
    
    -- Internal Signal Assignments
    process (sw, JB)
    begin
        if sw(10) = '1' then
            puf_input <= JB;
        else
            puf_input <= sw(7 downto 0);    
        end if;
    end process;
    
    sha128_input <=  puf_input & puf_output;
    puf_enable <= not puf_reset;

    -- External Signal Assignments
    led(7 downto 0) <= puf_output;
    JC <= puf_output;
    led(14) <= puf_all_set;
    READY <= puf_all_set;
    led(15) <= sha128_ready;
    

end Behavioral;
