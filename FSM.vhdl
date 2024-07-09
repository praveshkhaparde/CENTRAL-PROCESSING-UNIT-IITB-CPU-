library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity FSM is 
	port( opcode:in std_logic_vector(3 downto 0);
			clk:in std_logic;
			output_state: out std_logic_vector(3 downto 0));
end entity;

architecture beh of FSM is


--Represents id for each state we we using
constant S0  :  std_logic_vector(3 downto 0):= "0000";
constant S1  :  std_logic_vector(3 downto 0):= "0001";  
constant S2  :  std_logic_vector(3 downto 0):= "0010";
constant S3  :  std_logic_vector(3 downto 0):= "0011";
constant S4  :  std_logic_vector(3 downto 0):= "0100";
constant S5  :  std_logic_vector(3 downto 0):= "0101";
constant S6  :  std_logic_vector(3 downto 0):= "0110";
constant S7  :  std_logic_vector(3 downto 0):= "0111";
constant S8  :  std_logic_vector(3 downto 0):= "1000";
constant S9  :  std_logic_vector(3 downto 0):= "1001";

constant S10  :  std_logic_vector(3 downto 0):= "1010";
constant S11  :  std_logic_vector(3 downto 0):= "1011";
constant S12  :  std_logic_vector(3 downto 0):= "1100";
constant S13  :  std_logic_vector(3 downto 0):= "1101";
constant S14  :  std_logic_vector(3 downto 0):= "1110";
constant S15  :  std_logic_vector(3 downto 0):= "1111";




----Signals which represent present and next state id
signal y_present: std_logic_vector(3 downto 0) :=S0;
signal y_next: std_logic_vector(3 downto 0) :=S0;


begin
		output_state <= y_present;
		
	FSM_process: process(clk)
	
	begin
			if(rising_edge(clk)) then
				y_present <= y_next;
			end if;
			
	end process;

	next_state:process(y_present,opcode)
   begin
		case y_present is
		
		   when S0 =>
			y_next <= S1;
		
			when S1=>
				case opcode is
					when "0000" | "0010" |"0011"|"0100"|"1011"|"0110"|"0101"|"1100" | "0001"|"1010" =>	-- RTYPE, SW,LW ,ADI ,BEQ	
						y_next<=S2;   
					when "1000" | "1001" =>   
						y_next<=S3;               -- LLI, LHI
					when "1111" | "1101" =>     
						y_next<=S4;               -- JAL, JLR
					when others =>
						y_next<=S1;
				end case;
				
			when S2=>
				case opcode is
					
					when "0000" | "0010" | "0011" |"0100"| "0101" | "0110" |"1100" =>
						y_next<= S5;
					when "1011" |"0001"|"1010" => 
						y_next<= S6;
					when others =>
						y_next <= S0;
				end case;
	
			when S3 =>                  --LLI, LHI
				case opcode is 
					when "1000" | "1001" =>
						y_next <= S12;
					when others =>
						y_next <= S0;
				end case;

         when S4 =>
				case opcode is
					
					when "1101" =>
						y_next <= S13;
					when "1111" => 
						y_next <= S14;
					when others =>
						y_next <= S0;
				end case;	
				
			when S13=> 
			case opcode is
					
					when "1101" =>
						y_next <= S15;
					when others =>
						y_next <= S0;
				end case;
				
			when S14=> 
			case opcode is
					
					when "1111" =>
						y_next <= S15;
					when others =>
						y_next <= S0;
				end case;	
				
			when S5=>
				case opcode is
					when "0000" | "0010" |"0011" | "0100" | "0101" | "0110"  =>    --RTYPE 
						y_next<=S7;
					when "1100" =>  --BEQ
					   y_next<=S8;
					when others =>
						y_next <= S0;
				end case;
			
			when S7 => --last
				y_next<=S0;
				
		   when S8=> --last
				y_next<=S0;
				
			when S9=> --last
				y_next<=S0;
				
			when S10=> --last
				y_next<=S0;
				
			when S12=> --last
				y_next<=S0;
			
		   when S15=> --last
				y_next<=S0;	
			
				
			
				
			when S6=>
				case opcode is
					when "0001" =>
						y_next<=S9;
					when "1011" =>
						y_next<=S10;
	            when "1010" =>
						y_next<=S11;
					when others =>
						y_next <= S0;
				end case;
			
		
				
			when S11 => 
				case opcode is
			      when "1010" =>
						y_next<=S12;          --LW
					when others =>
						y_next <= S0;
				end case;
				
			
				
			
				
			
				
			when others =>
				 y_next <= S0;
				
end case;
end process;
end architecture;