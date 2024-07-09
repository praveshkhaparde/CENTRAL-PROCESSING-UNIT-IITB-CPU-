library ieee;
use ieee.std_logic_1164.all;


entity IITB_CPU is 
	port(clk, reset : in std_logic);
end entity;

architecture ultimate of IITB_CPU is
	component fsm is 
	port( opcode:in std_logic_vector(3 downto 0);
			clk:in std_logic;
			output_state: out std_logic_vector(3 downto 0)
		 );
end component fsm;
	
	component datapath is
	port( clk: in std_logic; 
	      reset : in std_logic;
	      state: in std_logic_vector(3 downto 0); 
		   C_FLAG, Z_FLAG: out std_logic;
			opcode: out std_logic_vector(3 downto 0));
end component datapath;
	
	
	
	signal state: std_logic_vector(3 downto 0);
	signal opcode: std_logic_vector(3 downto 0) ;
	signal c_out, z_out: std_logic;
	
	begin
		cpudatapath: component datapath
			port map(clk,reset ,  state, c_out, z_out, opcode);
			
		fsmincpu: component fsm
			port map(opcode, clk, state);
end architecture;