library IEEE;
use IEEE.std_logic_1164.all;
 
ENTITY HW3_PingPong_tb IS
END HW3_PingPong_tb;
 
ARCHITECTURE behavior OF HW3_PingPong_tb IS
 
-- Component Declaration for the Unit Under Test (UUT)
 
COMPONENT HW3_PingPong
    Port (
           clk     : in STD_LOGIC;
           rst     : in STD_LOGIC;
           i_swL   : in STD_LOGIC;
           i_swR   : in STD_LOGIC;
           out_led : out STD_LOGIC_VECTOR (7 downto 0)
           );
END COMPONENT;
 
--Inputs
signal clock : std_logic := '0';
signal reset : std_logic := '0';
signal swL   : std_logic;
signal swR   : std_logic; 
signal led   : std_logic_vector(7 downto 0);
--Outputs
--signal counter : std_logic_vector(3 downto 0);
 
-- Clock period definitions
constant clock_period : time := 20 ns;
 
BEGIN
 
-- Instantiate the Unit Under Test (UUT)
uut: HW3_PingPong PORT MAP (
           clk     => clock,
           rst     => reset, 
           i_swL   => swL,
           i_swR   => swR,
           out_led => led
);
 
-- Clock process definitions
clock_process :process
begin
clock <= '0';
wait for clock_period/2;
clock <= '1';
wait for clock_period/2;
end process;
 
-- Stimulus process
stim_proc: process
begin
    reset <= '0';
    swL <= '0';
    swR <= '0';
    wait for 23 ns;
    reset <= '1';
    
    --一開始由左方發球
    wait for 530 ns; --右方接球
    swR <= '1';
    wait for 80 ns;
    swR <= '0';

    wait for 300 ns; --左方提早打 右方得分並發球
    swL <= '1';
    wait for 80 ns;
    swL <= '0';
    wait for 80 ns; --右方發球
    swR <= '1';
    wait for 80 ns;
    swR <= '0';
    
    wait for 500 ns; --左方接球
    swL <= '1';
    wait for 80 ns;
    swL <= '0';
    
    wait for 100 ns; --右方提早打 左方得分並發球
    swR <= '1';
    wait for 80 ns;
    swR <= '0';
    wait for 80 ns; --左方發球
    swL <= '1';
    wait for 80 ns;
    swL <= '0';
    
    wait for 550 ns; --右方接球
    swR <= '1';
    wait for 80 ns;
    swR <= '0';
    
    wait for 680 ns; --左方漏接 右方得分並發球
    swR <= '1';
    wait for 80 ns;
    swR <= '0';
    
    wait for 550 ns; --左方接球
    swL <= '1';
    wait for 80 ns;
    swL <= '0';
    --右方漏接 左方得分 結束
    wait;
end process;
 
END;
