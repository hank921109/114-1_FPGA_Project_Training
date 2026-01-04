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
    wait for 30 ns;
    reset <= '1';
    
    -- 球經過每一顆LED時間為160 ns，160*8=1280
	-- 情況一:從左邊開始發球，右邊提前打
    wait for 530 ns; -- 右邊接球(提早打，左邊會得分) 
    swR <= '1';
    wait for 80 ns;
    swR <= '0';
	-- 結果:左邊得分 1:0

    -- 情況二:左邊發球，右邊漏接
    wait for 150 ns; 
    swL <= '1';
    wait for 80 ns;
    swL <= '0';
    wait for 1300 ns;
	-- 結果:左邊得分 2:0
    
	-- 情況三:左邊發球，右邊回擊，左邊提前回擊
    wait for 150 ns; 
    swL <= '1';
    wait for 80 ns;
    swL <= '0';
	
	-- 右邊回擊
    wait for 1300 ns;
	swR <= '1';
	wait for 80 ns;
	swR <= '0';
	
	-- 左邊提前回擊
	wait for 480 ns;
    swL <= '1';
    wait for 80 ns;
    swL <= '0';
	-- 結果:右邊得分 2:1
	
	-- 情況四:右邊發球，左邊漏接
    wait for 150 ns;
	swR <= '1';
	wait for 80 ns;
	swR <= '0';	
	wait for 1300 ns;
	-- 結果:右邊得分 2:2
	
	-- 情況五:右邊發球，左邊回擊，右邊提早打
    wait for 250 ns;
	swR <= '1';
	wait for 80 ns;
	swR <= '0';

    -- 左邊回擊	
    wait for 1250 ns;
	swL <= '1';
	wait for 80 ns;
	swL <= '0';
	
	-- 右邊提前回擊
	wait for 480 ns;
    swR <= '1';
    wait for 80 ns;
    swR <= '0';
	-- 結果:左邊得分 3:2
	
	-- 後面情況不限制，繼續打
	
	-- 重複情況二:左邊發球，右邊提前打
    wait for 150 ns; -- 左邊發球
    swL <= '1';
    wait for 80 ns;
    swL <= '0';
	
	wait for 500 ns;
	swR <= '1'; -- 右邊提前打
    wait for 80 ns;
    swR <= '0';
	-- 結果:左邊得分 4:2
	
	-- 重複情況三:左邊發球，右邊回擊，左邊提前回擊
    wait for 150 ns; 
    swL <= '1';
    wait for 80 ns;
    swL <= '0';
	
	-- 右邊回擊
    wait for 1200 ns;
	swR <= '1';
	wait for 80 ns;
	swR <= '0';
	
	-- 左邊提前回擊
	wait for 480 ns;
    swL <= '1';
    wait for 80 ns;
    swL <= '0';
	-- 結果:右邊得分 4:3
	
	-- 重複情況四:右邊發球，左邊漏接
    wait for 150 ns;
	swR <= '1';
	wait for 80 ns;
	swR <= '0';	
	wait for 1300 ns;
	-- 結果:右邊得分 4:4
	
	
	wait for 300 ns;
    -- 結束測試
end process;
 
END;
