library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- FPGA projects using Verilog code VHDL code
-- fpga4student.com: FPGA projects, Verilog projects, VHDL projects
-- VHDL project: VHDL code for counters with testbench  
-- VHDL project: Testbench VHDL code for up counter
entity tb_counters is
end tb_counters;

architecture Behavioral of tb_counters is

component  HW1_TwoCounter is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           count1_out : out STD_LOGIC_VECTOR (7 downto 0);
           count2_out : out STD_LOGIC_VECTOR (7 downto 0));
end component;
signal rst,clk: std_logic;
signal count1_out, count2_out : STD_LOGIC_VECTOR (7 downto 0);

begin
dut: HW1_TwoCounter port map (clk => clk, rst=>rst, count1_out => count1_out, count2_out => count2_out);
   -- Clock process definitions
   
clock_process :process
begin
     clk <= '0';
     wait for 10 ns;
     clk <= '1';
     wait for 10 ns;
end process;


-- Stimulus process
stim_proc: process
begin        
   -- hold reset state for 100 ns.
    rst <= '0';
   wait for 20 ns;    
    rst <= '1';
   wait;
end process;
end Behavioral;