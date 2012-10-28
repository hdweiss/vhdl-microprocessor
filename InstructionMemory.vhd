library ieee; 
 use ieee.std_logic_1164.all; 
 use work.pro_types.all; 
  
 entity InstructionMemory is 
 port ( 
     clk         : in std_logic; 
     disable     : in std_logic; 
     address     : in bit_16; 
     q           : out bit_16 
 ); 
 end InstructionMemory; 
  
 architecture im of InstructionMemory is 
  
     signal areg     : bit_16; 
     signal data     : bit_16; 
  
 begin 
  
 process(clk) begin 
  
     --if (rising_edge(clk) AND disable='0')then 
       --  areg <= address; 
     --end if; 
  
     if (rising_edge(clk))then 
         if (disable='0') then 
 			areg <= address; 
         end if; 
     end if; 
 end process; 
  
     q <= data; 
  
 process(areg) begin 
  
   case areg is 
when "0000000000000000" => data <= "0000000000000000";
when "0000000000000001" => data <= "1000101001001000";
when "0000000000000010" => data <= "1000001000000010";
when "0000000000000011" => data <= "0010101000001111";
when "0000000000000100" => data <= "0000000000000000";
when "0000000000000101" => data <= "0001000100001110";
when "0000000000000110" => data <= "0000000000000000";
when "0000000000000111" => data <= "0000000000000000";
when "0000000000001000" => data <= "0000000000000000";
when "0000000000001001" => data <= "0000000000000000";
when "0000000000001010" => data <= "1001000100100011";
when "0000000000001011" => data <= "0000000000000000";
when "0000000000001100" => data <= "0011001100000100";
when "0000000000001101" => data <= "0000000000000000";
when "0000000000001110" => data <= "0000000000000000";
when "0000000000001111" => data <= "0100000000000001";
when "0000000000010000" => data <= "0000000000000000";
when "0000000000010001" => data <= "0000000000000000";
when "0000000000010010" => data <= "0000000000000000";
when "0000000000010011" => data <= "0000000000000000";
when "0000000000010100" => data <= "0001010000001111";
when "0000000000010101" => data <= "0000000000000000";
when "0000000000010110" => data <= "0000000000000000";
when "0000000000010111" => data <= "0000000000000000";
when "0000000000011000" => data <= "0000000000000000";
when "0000000000011001" => data <= "0010010000001111";
when "0000000000011010" => data <= "0000000000000000";
when "0000000000011011" => data <= "0110010000000001";
when "0000000000011100" => data <= "0010010000001111";
when "0000000000011101" => data <= "0000000000000000";
when "0000000000011110" => data <= "0110010000000001";
when "0000000000011111" => data <= "0010010000001111";
when "0000000000100000" => data <= "0000000000000000";
when "0000000000100001" => data <= "0000000000000000";

when others => data <= "0000000000000000";
    end case;
end process;

end im;