----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/10/08 17:57:59
-- Design Name: 
-- Module Name: HW2_BreathLight - Behavioral
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
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HW2_BreathLight is
    Port ( clk     : in STD_LOGIC;
           rst     : in STD_LOGIC;
           out_led : out STD_LOGIC);
end HW2_BreathLight;

architecture Behavioral of HW2_BreathLight is
    component HW1_TwoCounter
	    port (
		    clk            : in STD_LOGIC;
			rst            : in STD_LOGIC;
			in_upperBound1 : in STD_LOGIC_VECTOR(7 downto 0);
			in_upperBound2 : in STD_LOGIC_VECTOR(7 downto 0);
			out_state      : out STD_LOGIC
			 );
    end component;
	type STATE2TYPE is (gettingBright, gettingDark);
	signal              upbnd1 : STD_LOGIC_VECTOR(7 downto 0);
	signal              upbnd2 : STD_LOGIC_VECTOR(7 downto 0);
	signal              state2 : STATE2TYPE;
	signal alreadyP_PWM_cycles : STD_LOGIC;
	signal              pwmCnt : STD_LOGIC_VECTOR(7 downto 0);
    constant                 P : STD_LOGIC_VECTOR(7 downto 0) := "00000011"; --3
	signal           pwm_pedge : STD_LOGIC;
	--type FSM is(S0,S1,S2);
	signal pwm     : STD_LOGIC;
	signal pwm_old : STD_LOGIC;
begin

    HW1: HW1_TwoCounter
	    port map (
		    clk => clk,
			rst => rst,
			in_upperBound1 => upbnd1,
			in_upperBound2 => upbnd2,
			out_state => pwm
		);
		
    FSM2: process(clk, rst, upbnd1, upbnd2)
    begin
        if rst = '0' then
            state2 <= gettingBright;
        elsif clk'event and clk = '1' then
            case state2 is
                when gettingBright =>
                    if upbnd1 = "1111"&"1111" then -- å·²ç?“æ?äº? then
                        state2 <= gettingDark;
                    end if;
                when gettingDark =>
                    if upbnd1 = "0000"&"0000" then -- å·²ç?“æ???? then
                        state2 <= gettingBright;
                    end if;
                when others =>
                    null;
            end case;
        end if;        
    end process;
	
	upbnd1p: process(clk, rst, state2, alreadyP_PWM_cycles)
    begin
        if rst = '0' then
            upbnd1 <= "00000000";
        elsif clk'event and clk = '1' then
            case state2 is
                when gettingBright =>
                   if alreadyP_PWM_cycles = '1' then
                       upbnd1 <= upbnd1 + '1';
                       --upbnd2 <= upbnd2 - '1';
                   end if;
                when gettingDark =>
                   if alreadyP_PWM_cycles = '1' then
                       upbnd1 <= upbnd1 - '1';
                   end if;
                when others =>
                    null;
            end case;
        end if;
    end process upbnd1p;

    upbnd2p: process(clk, rst, state2, alreadyP_PWM_cycles)
    begin
        if rst = '0' then
            upbnd2 <= "11111111";
        elsif clk'event and clk = '1' then
            case state2 is
                when gettingBright =>
                   if alreadyP_PWM_cycles = '1' then
                       upbnd2 <= upbnd2 - '1';
                       --upbnd1 <= upbnd2 + '1';
                   end if;
                when gettingDark =>
                   if alreadyP_PWM_cycles = '1' then                
                      upbnd2 <= upbnd2 + '1';
                      --upbnd1<=upbnd1-'1';
                   end if;
                when others =>
                    null;
            end case;
        end if;
    end process upbnd2p;
        
    P_PWM_cycles:  process(clk, rst)
    begin
        if rst = '0' then
            pwmCnt <= (others => '0');
			alreadyP_PWM_cycles <= '0';
        elsif clk'event and clk = '1' then  
		    if pwm_pedge = '1' then
                if pwmCnt >= P - 1 then
                    pwmCnt <= (others => '0');
                    alreadyP_PWM_cycles <= '1';
                else
				    pwmCnt <= pwmCnt+'1';
			        alreadyP_PWM_cycles <= '0';
				end if;
			else
			    alreadyP_PWM_cycles <= '0';
			end if;
        end if;
    end process P_PWM_cycles;
	
	detect_PWM_edge: process(clk, rst, pwm)
    begin
        if rst = '0' then
            pwm_pedge <= '0';
			pwm_old <='0';
        elsif clk'event and clk = '1' then    
		    pwm_old <= pwm;
		    if pwm_old = '0' and pwm='1' then
			    pwm_pedge <= '1';
			else
			    pwm_pedge <= '0';
			end if;
        end if;
    end process;
	out_led <= pwm ;
end Behavioral;
