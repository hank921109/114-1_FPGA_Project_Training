library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity HW2_BreathLight_tb is
end entity HW2_BreathLight_tb;

architecture test of HW2_BreathLight_tb is
  signal clk    : std_logic := '0';
  signal rst    : std_logic := '0';
  signal out_led: std_logic := '0';
  
    component HW2_BreathLight
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
           out_led : out STD_LOGIC
         );
    end component;  
begin

-- Clock process definitions
clk_gen: process
 begin
    clk <= '0';
    wait for 10ns;
    clk <= '1';
    wait for 10ns;
 end process;
  
  -- Instantiate the design under test
  dut: HW2_BreathLight
    Port map( 
           clk => clk,
           rst => rst,
           out_led => out_led
         );
    
  -- Generate the test stimulus
  stimulus:
  process begin
      rst <= '0';
      wait for 6 ns;
      rst <= '1';

    -- Testing complete
    wait;
  end process stimulus;
  
end architecture test;