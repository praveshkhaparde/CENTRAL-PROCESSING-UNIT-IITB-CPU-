library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY f_reg is
port (c_in, z_in :std_logic;
			c_en, z_en, clk :in std_logic;
			c_out, z_out: out std_logic
		);
end ENTITY f_reg;

architecture f_r of f_reg is 
begin 
process(clk, c_in, c_en, z_in, z_en)
    begin
       z_out <= c_in and c_en and z_in and z_en ;
       c_out <= c_in and c_en and z_in and z_en ; 
    end process;
	 
end f_r;