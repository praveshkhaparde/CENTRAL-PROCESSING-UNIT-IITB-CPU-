library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.ALL;

entity instruction_reg is
	port (input:in std_logic_vector(15 downto 0);
			reset : in std_logic;
			w_enable, clk: in std_logic;
			IR_out: out std_logic_vector(15 downto 0));
end instruction_reg;

architecture Behavioral of instruction_reg is
    signal ir_register : std_logic_vector(15 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            ir_register <= (others => '0');
        elsif rising_edge(clk) then
            if w_enable = '1' then
                ir_register <= input;
            end if;
        end if;
    end process;

    IR_out <= ir_register;
end Behavioral;
