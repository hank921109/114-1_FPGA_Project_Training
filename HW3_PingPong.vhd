library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity HW3_PingPong is
    Port ( clk   : in STD_LOGIC;
           rst   : in STD_LOGIC;
		   i_swL : in STD_LOGIC;
		   i_swR : in STD_LOGIC;
           out_led : out STD_LOGIC_VECTOR (7 downto 0));
end HW3_PingPong;

architecture Behavioral of HW3_PingPong is
type STATE_TYPE is (Moving_Left, Moving_Right, Lwin, Rwin);
signal state      : STATE_TYPE;
signal prev_state : STATE_TYPE;
signal led_r      : STD_LOGIC_VECTOR(7 downto 0);
signal score_L    : STD_LOGIC_VECTOR(3 downto 0);
signal score_R    : STD_LOGIC_VECTOR(3 downto 0);

signal div_clk : STD_LOGIC;
signal cnt : unsigned(25 downto 0) := (others => '0');

begin

------ 乒乓球對打燈號顯示 ------
out_led <= led_r;

------ 加上除頻 ------
clk_div:process(clk, rst)
begin
    if rst = '0' then
        cnt <= (others => '0');
        div_clk <= '0';
    elsif rising_edge(clk) then
        cnt <= cnt + 1;
        div_clk <= cnt(24);  -- cnt(x) x決定速度快慢，x越大速度越慢，燒錄板子把1改為23
    end if;
end process;

FSM:process(clk, rst, i_swL, i_swR, led_r)
begin
    if rst='0' then
        state <= Moving_Right;
    elsif clk'event and clk='1' then
        case state is
            when Moving_Right => --S0 右移中
                if (led_r < "00000001") or (led_r > "00000001" and i_swR = '1') then --右lost或提早
                --if (led_r > "00000001" and i_swR = '1') then --右lost或提早
                    state <= Lwin;
                elsif led_r(0)='1' and i_swR ='1' then --右打到 then
                    state <= Moving_Left;                     
                end if;
            when Moving_Left => --S1 左移中
                if (led_r="00000000") or (led_r < "10000000" and i_swL = '1') then--左lost或提早
                --if (led_r < "10000000" and i_swL = '1') then--左lost或提早
                    state <= Rwin;
                elsif led_r(7)='1' and i_swL ='1' then --左打到 then
                    state <= Moving_Right;                                          
                end if;
            when Lwin =>    --S3 
                if i_swL ='1' then --左邊發球，方向往右
                    state <= Moving_Right;
                end if;
            when Rwin =>    --S2
                if i_swR ='1' then --右邊發球，方向往左
                    state <= Moving_Left;
                end if;
            when others => 
                null;
        end case;
    end if;
end process;

LED_P:process(div_clk, rst, state, prev_state)
begin
    if rst='0' then
        led_r <= "10000000";
    elsif div_clk'event and div_clk='1' then
	    prev_state <= state;
        case state is
			when Moving_Right => --S0 右移中
				if (prev_state = Lwin) then
					led_r <= "10000000";
				elsif (prev_state <= Moving_Left or prev_state <= Moving_Right) then
					led_r(7         ) <= '0';
					led_r(6 downto 0) <= led_r(7 downto 1); --led_r >> 1
				end if;          
			when Moving_Left => --S1 左移中
				if (prev_state = Rwin) then
					led_r <= "00000001";
				elsif (prev_state <= Moving_Right or prev_state <= Moving_Left) then            
					led_r(7 downto 1) <= led_r(6 downto 0); --led_r << 1            
					led_r(         0) <= '0';
				end if;
			when Lwin =>    --S3 
				if (prev_state = Moving_Right) then
					led_r <= "11110000";
				end if;
			when Rwin =>    --S2
				if (prev_state = Moving_Left) then
					led_r <= "00001111";
				end if;
			when others => 
				null;
		end case;    
	end if;
end process;

score_L_p:process(div_clk, rst, state)
begin
    if rst='0' then
        score_L <= "0000";
    elsif div_clk'event and div_clk='1' then
        case state is
            when Moving_Right => --S0 右移中
                null;
            when Moving_Left  => --S1 左移中
                null;
            when Lwin =>    --S3 
		    if (prev_state = Moving_Right) then
                    score_L <= score_L + '1';
			end if;
            when Rwin =>    --S2
                null;
            when others => 
                null;
        end case;    
    end if;
end process;

score_R_p:process(div_clk, rst, state)
begin
    if rst='0' then
        score_R <= "0000";
    elsif div_clk'event and div_clk='1' then
         case state is
            when Moving_Right => --S0 右移中
                null;
            when Moving_Left  => --S1 左移中
                null;
            when Lwin =>    --S3 
                 null; 
            when Rwin =>    --S2
			    if (prev_state = Moving_Left) then
                    score_R <= score_R + '1';
				end if;
            when others => 
                 null;
         end case;    
    end if;
end process;

end Behavioral;
