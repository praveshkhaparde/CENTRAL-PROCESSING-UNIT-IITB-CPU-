library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register_File is
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
end Register_File;

architecture Behavioral of Register_File is
    type reg_array is array (0 to 7) of std_logic_vector(15 downto 0);
    signal registers : reg_array := (others => (others => '0')); -- Initialize registers with 0s
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if reg_write_enable = '1' then
                registers(to_integer(unsigned(write_address))) <= write_data;
            end if;
        end if;
    end process;

    data_out1 <= registers(to_integer(unsigned(read_address1)));
    data_out2 <= registers(to_integer(unsigned(read_address2)));
end Behavioral;
