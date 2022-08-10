----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/29/2018 05:29:33 PM
-- Design Name: 
-- Module Name: config_ro_puf - Behavioral
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

entity config_ro_puf is
    Port ( CLK : in STD_LOGIC;
           ENABLE : in STD_LOGIC;
           RESET : in STD_LOGIC;
           CHALLENGE : in STD_LOGIC_VECTOR (7 downto 0);
           SET : out STD_LOGIC;
           RESPONSE : out STD_LOGIC_VECTOR (7 downto 0));
end config_ro_puf;

architecture Behavioral of config_ro_puf is

signal ro_out : std_logic_vector(3 downto 0);

signal count_ro : std_logic;
signal count_clk : std_logic;

signal clk_count_out : std_logic_vector(9 downto 0);
signal ro_count_out : std_logic_vector(9 downto 0);
signal count_enable : std_logic;

signal t_response : std_logic_vector(7 downto 0);
signal t_set : std_logic;

component clock_divider is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           SUB_CLK : out STD_LOGIC);
end component;

component configurable_ro is
    Port ( INPUT : in STD_LOGIC_VECTOR (5 downto 0);
           ENABLE : in STD_LOGIC;
           OUTPUT : out STD_LOGIC);
end component;

component count_up is
    Port ( RESET : in STD_LOGIC;
           INPUT : in STD_LOGIC;
           ENABLE : in STD_LOGIC;
           OUTPUT : out STD_LOGIC_VECTOR (9 downto 0));
end component;

begin

    clk_div : clock_divider port map ( CLK => CLK,
                                       RESET => RESET,
                                       SUB_CLK => count_clk );

    GEN_RO : 
    for i in 0 to 3 generate
        ring_osc : configurable_ro port map ( INPUT => CHALLENGE(5 downto 0),
                                              ENABLE => ENABLE,
                                              OUTPUT => ro_out(i));
    end generate GEN_RO;

    clock_counter : count_up port map ( RESET => RESET,
                                        INPUT => count_clk,
                                        ENABLE => count_enable,
                                        OUTPUT => clk_count_out);
    
    ro_counter : count_up port map ( RESET => RESET,
                                     INPUT => count_ro,
                                     ENABLE => count_enable,
                                     OUTPUT => ro_count_out);
    
    -- MUX to determine which RO should be fed into the RO counter module
    process (CHALLENGE(7 downto 6))
    begin
        case CHALLENGE(7 downto 6) is
            when "00" => count_ro <= ro_out(0);
            when "01" => count_ro <= ro_out(1);
            when "10" => count_ro <= ro_out(2);
            when "11" => count_ro <= ro_out(3);
        end case;
    end process;
    
    process (clk_count_out, RESET) 
    begin
        if RESET = '1' then
            count_enable <= '1';
            t_set <= '0';
            t_response <= (others => '0');
        elsif clk_count_out = "0011111111" then
            count_enable <= '0';
            t_set <= '1';
            t_response <= ro_count_out(9 downto 2);
        elsif ENABLE = '1' then
            count_enable <= '1';
        end if;
    end process;
    
    RESPONSE <= t_response;
    SET <= t_set;

end Behavioral;
