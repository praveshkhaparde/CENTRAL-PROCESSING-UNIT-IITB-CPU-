library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Alu is 
    port (
	 
	 
        IP : in std_logic_vector(15 downto 0);  -- Operation select: 00 for addition, 01 for subtraction
        REGA : in std_logic_vector(15 downto 0);
        REGB : in std_logic_vector(15 downto 0);
        OUTPUT : out std_logic_vector(15 downto 0);
		  Z : out std_logic
    );
end Alu;

architecture Behavioral of Alu is
    signal temp : std_logic_vector(15 downto 0);
    
begin
    output_1 : process (IP, REGA, REGB)
        variable temp_result : integer;
		  variable temp : std_logic_vector(15 downto 0); 
		  variable temp_rega_ls4, temp_regb_ls4: std_logic_vector(3 downto 0);
		  
    begin
	 
	 
        -- Extract least significant 4 bits from REGA and REGB
        temp_rega_ls4 := REGA(3 downto 0);
        temp_regb_ls4 := REGB(3 downto 0);
		
		
        case IP(15 downto 12)  is
            when "0000" =>
                temp_result := to_integer(unsigned(REGA)) + to_integer(unsigned(REGB));
			   when "0010" =>
                temp_result := to_integer(unsigned(REGA)) - to_integer(unsigned(REGB));
            when "0011" =>
                temp_result := to_integer(unsigned(temp_rega_ls4)) * to_integer(unsigned(temp_regb_ls4)); 
            when "0100" =>
                temp := REGA AND REGB;  -- Bitwise AND
            when "0101" =>
                temp := REGA OR REGB;  -- Bitwise OR
            when "0110" =>
                temp := not(REGA) OR REGB;  -- Logical Implication
				when "1000" =>
                temp := IP(7 DOWNTO 0) & "00000000" ;
				when "1001" =>
                temp :=  "00000000"  & IP(7 DOWNTO 0) ;	 
					
				
			
		
		
            when others =>
                temp_result := 0;  -- Default case: Set result to 0
        end case;
		  
		  
		  
		    case IP(15 downto 12) is
            when "0000" =>
					OUTPUT <= std_logic_vector(to_unsigned(temp_result, 16));
			   when "0010" =>
					OUTPUT <= std_logic_vector(to_unsigned(temp_result, 16));
            when "0011" =>
               OUTPUT <= std_logic_vector(to_unsigned(temp_result, 16));
            when "0100" =>
                OUTPUT <= temp;  -- Bitwise AND
            when "0101" =>
                OUTPUT <= temp;  -- Bitwise OR
            when "0110" =>
                OUTPUT <= temp;  -- Logical Implication 
				when "1000" =>
                OUTPUT <= temp;
				when "1001" =>
                OUTPUT <= temp;	
					 
            when others =>
                OUTPUT 	<= "0000000000000000";  -- Default case: Set result to 0
		  
				end case ;
				
		   if (to_integer(unsigned(REGA)) - to_integer(unsigned(REGB)) = 0) then 
			   Z <= '1';
			   else 
			   Z <= '0';
			end if ;		
        
    end process;
				
end Behavioral;