----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/09/17 17:22:19
-- Design Name: 
-- Module Name: HW1_TwoCounter - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HW1_TwoCounter is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           count1_out : out STD_LOGIC_VECTOR (7 downto 0);
           count2_out : out STD_LOGIC_VECTOR (7 downto 0));
end HW1_TwoCounter;

architecture Behavioral of HW1_TwoCounter is
signal count1 : STD_LOGIC_VECTOR (7 downto 0);
signal count2 : STD_LOGIC_VECTOR (7 downto 0);

type PSM_STATE is (s0, s1); -- Define S0 : counter1 is counting ; S1: counter2 is counting
signal state: PSM_STATE;
begin

count1_out <= count1;
count2_out <= count2;

FSM: process(rst, clk, count1, count2)
begin
    if rst = '0' then
        state <= s0;
    elsif clk'event and clk = '1' then
        case state is
            when S0 => -- Counter1 counting...
                if (count1 > "00000111") and (count2 <= "11111101" )  then -- 數完  9 - 1 = 8
                    state <= s1 ;
				end if;
            when S1 => -- Counter2 counting...
                if (count2 < "01010001") then -- 數完  79 + 1 = 80
                    state <= s0 ;
				end if;
            when others =>
                null;
        end case;
    end if;
end process FSM;

counter1: process(clk, rst, state)
begin
    if rst = '0' then
        count1 <= "00000000";
    elsif clk'event and clk = '1' then
        case state is
            when S0 =>  -- Counter1 counting...
			    if (count2 <= "01001111") then -- 79
				    count1 <= count1;
				elsif (count1 >= "00000000") and (count2 = "11111101") then
				    count1 <= count1 + 1;
				end if;
            when S1 =>  -- Counter2 counting...
                count1 <= "00000000";
            when others =>
                null;
        end case;
    end if;
end process counter1;

counter2: process(clk, rst, state)
begin
    if rst = '0' then
        count2 <= "11111101";    -- 253 = bin 11111101 
    elsif clk'event and clk = '1' then
        case state is
            when S0 =>  -- Counter1 counting...
                count2 <= "11111101"; 
            when S1 =>  -- Counter2 counting...
			    if (count1 = "00001001") then  -- 00001001 = 9
				    count2 <= count2;
				elsif (count1 <= "00000000") then
                    count2 <= count2 - 1;
				end if;
            when others =>
                null;
        end case;
    end if;
end process counter2;           

end Behavioral;
