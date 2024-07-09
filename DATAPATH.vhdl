library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
	port( clk: in std_logic; 
	      reset : in std_logic;
	      state: in std_logic_vector(3 downto 0); 
		   C_FLAG, Z_FLAG: out std_logic;
			opcode: out std_logic_vector(3 downto 0)
		);
end entity datapath;

architecture Beh of datapath is

component instruction_reg is
		port (input:in std_logic_vector(15 downto 0);
			reset : in std_logic;
			w_enable, clk: in std_logic;
			IR_out: out std_logic_vector(15 downto 0));
			
			end component instruction_reg;

component temp_reg is
    Port ( clk : in std_logic;
           reset : in std_logic;
           load : in std_logic;
           data_input : in std_logic_vector(15 downto 0);
           data_output : out std_logic_vector(15 downto 0));
end component temp_reg;

component f_reg is
port (c_in, z_in :std_logic;
			c_en, z_en, clk :in std_logic;
			c_out, z_out: out std_logic
		);
end component f_reg;

component LeftShifter is
    Port ( input : in std_logic_vector(15 downto 0);
           output : out std_logic_vector(15 downto 0)
    );
end component LeftShifter;

component sign_extender is
  port(
   inp_6bit : in std_logic_vector(5 downto 0);
	outp_16bit : out std_logic_vector(15 downto 0)
  ) ;	
end component; 

component Memory is
    port (
        clk : in std_logic;
        address : in std_logic_vector(15 downto 0);
        data_in : in std_logic_vector(15 downto 0);
        write_enable : in std_logic;
        data_out : out std_logic_vector(15 downto 0)
    );
end component Memory;

component Register_File is
    port (
        clk : in std_logic;
        reg_write_enable : in std_logic;
        write_address : in std_logic_vector(2 downto 0);
        write_data : in std_logic_vector(15 downto 0);
        read_address1 : in std_logic_vector(2 downto 0);
        read_address2 : in std_logic_vector(2 downto 0);
        data_out1 : out std_logic_vector(15 downto 0);
        data_out2 : out std_logic_vector(15 downto 0)
    );
end component Register_File;

component ALU is 
    port (
	 
        IP : in std_logic_vector(15 downto 0);  -- Operation select: 00 for addition, 01 for subtraction
        REGA : in std_logic_vector(15 downto 0);
        REGB : in std_logic_vector(15 downto 0);
        OUTPUT : out std_logic_vector(15 downto 0);
		  Z : out std_logic
    );
end component ALU;


   signal alu_a, alu_b, alu_out ,IR_inp, IR_out,wr_d, da1, da2, T1_inp, T1_data, T2_inp, T2_data, T3_inp,
	T3_data,T4_inp,T4_data,se_out, LS_out, Memo_addr, m_in, m_out: std_logic_vector(15 downto 0):=(others=>'0');
	
	signal wr_add, ra1, ra2: std_logic_vector(2 downto 0):=(others=>'0');
	signal alu_ctrl: std_logic_vector(15 downto 0);
	signal IR_wr, T1_w, T2_w, T3_w,T4_w, Mem_Write, c_en,c_in, z_en, c_out, z_in, z_out, wr_en: std_logic;

		--Represents id for each state we we using
constant s1  :  std_logic_vector(3 downto 0):= "0001";  
constant s2  :  std_logic_vector(3 downto 0):= "0010";
constant s3  :  std_logic_vector(3 downto 0):= "0011";
constant s4  :  std_logic_vector(3 downto 0):= "0100";
constant s5  :  std_logic_vector(3 downto 0):= "0101";
constant s6  :  std_logic_vector(3 downto 0):= "0110";
constant s7  :  std_logic_vector(3 downto 0):= "0111";
constant s8  :  std_logic_vector(3 downto 0):= "1000";
constant s9  :  std_logic_vector(3 downto 0):= "1001";
constant s10 :  std_logic_vector(3 downto 0):= "1010";
constant s11 :  std_logic_vector(3 downto 0):= "1011";
constant s12 :  std_logic_vector(3 downto 0):= "1100";
constant s13 :  std_logic_vector(3 downto 0):= "1101";
constant s14 :  std_logic_vector(3 downto 0):= "1110";
constant s15 :  std_logic_vector(3 downto 0):= "1111";
constant s0 :  std_logic_vector(3 downto 0):= "0000"; 
--constant s31  :  std_logic_vector(3 downto 0):= "1111";

	
	 
	
begin
	
		--How many t_regs do we need? 5. The first one is a bit special though
		IR: component Instruction_reg
			port map(IR_inp, reset , IR_wr, clk, IR_out);
			
		temp_register_T1: component temp_reg
			port map(clk,reset,T1_w, T1_inp, T1_data);
			
		temp_register_T2: component temp_reg
			port map(clk,reset,T2_w, T2_inp, T2_data);
			
		temp_register_T3: component temp_reg
			port map(clk,reset,T3_w, T3_inp, T3_data);
			
		temp_register_T4: component temp_reg           --r7 
			port map(clk,reset,T4_w, T4_inp, T4_data);	

--		Instruction_Pointer_reg_7: component temp_reg
--			port map(clk,reset,IP_w,IP_inp, IP_data);
--			
			
	
		-- now the final 2 registers
		
		
		flag: component f_reg
			port map(c_in, z_in, c_en, z_en, clk, c_out, z_out);
			
		
		reg_file: component Register_File
			port map(clk ,wr_en ,wr_add ,wr_d ,ra1, ra2, da1 , da2);
			
			
			
		multiplyby2: component LeftShifter
			port map(se_out, LS_out);
			
		se6: component sign_extender
			port map(IR_out(5 downto 0), se_out);
			
		mem: component Memory
			port map(clk, Memo_addr,m_in, Mem_Write,  m_out);
			
		alu_main: component ALU
			port map(alu_ctrl, alu_a, alu_b, alu_out, z_in);
			


			
			--		only_process: process(state)
	   state_process: process(state, da1, m_out, alu_out, da2, T1_data, T2_data, T3_data,T4_data, se_out, LS_out, IR_out)
		begin
			
			
			case state is
				when s0	=>
				
				  
			      -- a1<="111";
					ra1<= "111";
					T4_inp <= da1;
					Memo_addr<=da1;
					alu_a<=da1;
					--s5_0<= d1;
					IR_inp<=m_out;
					alu_b<="0000000000000001";
					T2_inp<= alu_out;
					opcode<=m_out(15 downto 12);

					
					--Control Signals
					wr_en<='0';
					Mem_Write<='0';
					--Mem_Read<='1';
					IR_wr<='1';
					T1_w<='1';
					T2_w<='1';
					T3_w<='0';
					T4_w<='1';
					--IP_w<='1';					
					z_en<='1';
					c_en<='1';
					alu_ctrl<="0000000000000000";
					
				when s1 =>
			      wr_add <= "111";
					wr_d<=T2_data;
					opcode <= IR_out(15 downto 12);
					
					--Control Signals
					wr_en<='1';
					Mem_Write<='0';
					--Mem_Read<='1';
					IR_wr<='1';
					T1_w<='0';
					T2_w<='0';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='1';					
					z_en<='1';
					c_en<='1';
					alu_ctrl<="0000000000000000";
					

				when s2 =>
					--Data Flow
					ra1<=IR_out(11 downto 9);
					ra2<=IR_out(8 downto 6);
					T1_inp<=da1;
					T2_inp<=da2;
					opcode<=IR_out(15 downto 12);

					
					--Control Signals
					wr_en<='0';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='1';
					T2_w<='1';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl<="0000000000000000";
					
				when s5 => --S6 tha mera 
					
					alu_a<=T1_data;
					alu_b<=T2_data;
					T3_inp<=alu_out;
					
					opcode<=IR_out(15 downto 12);

					
					--Control Signal
					wr_en<='0';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='1';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl <= IR_out;
					
				when s7 =>
					--Data Flow
					wr_d<=T3_data;
					wr_add<=IR_out(5 downto 3);
					opcode<=IR_out(15 downto 12);

					
					--Control Signals
					wr_en<='1';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl<="0000000000000000";
					
					when s8 =>
				
			      --a1<="111";
					alu_a<=T4_data;
					--s1_2<=IR_50;
					if(z_out='1') then
					--s1_1<=se6_out;
					alu_b<=LS_out;
					else
					alu_b<="0000000000000000";
					end if;
					
					wr_add <= "111";
					wr_d<=alu_out;
					--a3<="111";0
					opcode<=IR_out(15 downto 12);

					
					--Control Signals
					wr_en<='1';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='1';
					z_en<='1';
					c_en<='1';
					alu_ctrl<=IR_out;
					
					
				when s6 =>
					--Data Flow
					alu_a<=T4_data;
					--s1_2<=IR_50;
					alu_b<=se_out;
					T3_inp<=alu_out;
					opcode<=IR_out(15 downto 12);

					
					--Control Signals
					wr_en<='0';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='1';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl<=IR_out;
					
				when s9 =>
					--Data Flow
					wr_d<=T3_data;
					wr_add<=IR_out(8 downto 6);
					opcode<=IR_out(15 downto 12);

					
					--Control Signals
					wr_en<='1';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl<="0000000000000000";	

				
			 when s11 =>          --LW
					
					Memo_addr<=T3_data;
					T1_inp<=m_out;
					opcode<=IR_out(15 downto 12);

					
					--Control Signals
					wr_en<='0';
					Mem_Write<='0';
					--Mem_Read<='1';
					IR_wr<='0';
					T1_w<='1';
					T2_w<='0';
					T3_w<='1';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl<="0000000000000000";
				
				
					
				when s10 =>   --SW

					Memo_addr<=T3_data;
					m_in<=T1_data;
					opcode<=IR_out(15 downto 12);

					
					--Control Signals
					wr_en<='0';
					Mem_Write<='1';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl<="0000000000000000";
					
				
					
					

					
					
						
				   when s3 =>
					
					alu_b<="0000000000000000";
					alu_a<=IR_out;
					T1_inp<=alu_out;
					
					opcode<=IR_out(15 downto 12);

					
					--Control Signal
					wr_en<='0';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='1';
					T2_w<='0';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl <=IR_out;
					
					when s12 => 
					
					wr_d <= T1_data;
					wr_add <= IR_out(11 downto 9);
				  
				   --Control Signal
					wr_en<='1';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl <="0000000000000000" ;
			      	
					
					
					when s4 => 
					
					wr_d<=T4_data;
					wr_add<=IR_out(11 downto 9);
					opcode<=IR_out(15 downto 12);
					
					--Control signal 
					wr_en<='1';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl <="0000000000000000";
					
					when s13 =>
					
					alu_a <= T4_data;
					alu_b <= LS_out;
					T3_inp <= alu_out;
					opcode <= IR_out(15 downto 12);
					
					--Control signal 
					wr_en<='0';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='1';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl <= "0000000000000000";
					
					when s14 =>
	            ra1 <= IR_out(8 downto 6);
					T3_inp <=  da1;
					opcode <= IR_out(15 downto 12);
					
					--Control signal 
					wr_en<='0';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='1';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl <="0000000000000000";
					
					when s15 => 
					
					if (IR_out(15 downto 12) = "1101") then 
					wr_d <= T3_data;
					wr_add<= IR_out(8 downto 6);
					elsif (IR_out(15 downto 12) = "1111") then 
					wr_d <= T1_data;
					wr_add <= "111";
					end if ;
					opcode <= IR_out(15 downto 12);
					
					--Control signal 
					wr_en<='1';
					Mem_Write<='0';
					--Mem_Read<='0';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl <="0000000000000000";
					

					
					
					---------------------			
				when others =>
					opcode<=IR_out(15 downto 12);
					
					wr_en<='0';
					Mem_Write<='0';
					--Mem_Read<='1';
					IR_wr<='0';
					T1_w<='0';
					T2_w<='0';
					T3_w<='0';
					T4_w<='0';
					--IP_w<='0';
					z_en<='1';
					c_en<='1';
					alu_ctrl<="0000000000000000";
			end case;
		end process;
		
		C_FLAG<=c_out;
		Z_FLAG<=z_out;
end Beh;