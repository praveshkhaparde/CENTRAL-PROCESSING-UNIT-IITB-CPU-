library ieee;
use ieee.std_logic_1164.all;

entity MUX is
    port (
        Sel : in std_logic;
        Input_1 : in std_logic_vector(5 downto 0);
        Input_2 : in std_logic_vector(5 downto 0);
        Output : out std_logic_vector(5 downto 0)
    );
end entity MUX;

architecture Behavioral of MUX is
begin
    process (Sel, Input_1, Input_2)
    begin
        if Sel = '0' then
            Output <= Input_1;
        else
            Output <= Input_2;
        end if;
    end process;
end architecture Behavioral;
