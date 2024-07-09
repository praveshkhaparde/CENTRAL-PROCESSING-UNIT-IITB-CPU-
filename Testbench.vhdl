LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity Testbench is
end entity Testbench;

architecture bhv of Testbench is
	component IITB_CPU is
		port (clk,reset: in std_logic);
	end component IITB_CPU;

signal reset,clk: std_logic := '1';
constant clk_period : time := 20 ns;
begin
	dut_instance: IITB_CPU port map(clk,reset);
	reset<= '1','0' after 30 ns;
	p1 : process
	begin 
			clk <= '0';
			wait for 10 ns;
			clk <= '1';
			wait for 10 ns;
	end process;
end bhv;