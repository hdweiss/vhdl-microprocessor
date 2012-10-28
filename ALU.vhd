library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pro_types.all;
 
entity alu is
   port
   (
      Data_in_1, Data_in_2 : in bit_16;
      Opcode : in bit_4;
      --Carry_Out : out std_logic;
      Result_Out : out bit_16 
   );
end entity alu;
 
architecture arch_alu of alu is
 
   signal Temp: std_logic_vector(16 downto 0);
 
begin
 
   process(Data_in_1, Data_in_2,Opcode,Temp) is
   begin
      case Opcode is
         when op_and => Result_out <= Data_in_1 and Data_in_2;
            --result = 0 Data_in_1 AND Data_in_2
         when op_or => Result_out <= Data_in_1 or Data_in_2;
            --result = result = 0 Data_in_1 OR Data_in_2
         when op_xor => Result_out <= Data_in_1 xor Data_in_2;
            --result = result = 0 Data_in_1 XOR Data_in_2
         when op_sub =>
            if (Data_in_1 >= Data_in_2) then
               Result_Out  <= std_logic_vector(unsigned(Data_in_1) - unsigned(Data_in_2));
               --Carry_Out   <= '0';
            else
               Result_Out  <= std_logic_vector(unsigned(Data_in_2) - unsigned(Data_in_1));
              -- Carry_Out   <= '1';
            end if;
            --result = result = 0 Data_in_1 - Data_in_2
         when op_add       =>--ADD Register with constant and --ADD Registers
               Temp        <= std_logic_vector((unsigned("0" & Data_in_1) + unsigned("0" & Data_in_2)));
               Result_Out  <= Temp(15 downto 0);
              -- Carry_Out   <= Temp(16);
        when op_movh   =>--Move constant to higher 8-bits of register
           Result_Out(15 downto 8)  <=  Data_in_2(7 downto 0);
           Result_Out(7 downto 0)  <=  Data_in_1(7 downto 0);
        when op_movl   =>--Move constant to lower 8-bits of register
           Result_Out(7 downto 0)  <=  Data_in_2(7 downto 0);
           Result_Out(15 downto 8)  <=  Data_in_1(15 downto 8);  
         when op_sf  =>--Shift Register  
           case Data_in_2(3 downto 0) is
              when "0000" => 
                Result_Out<=Data_in_1;
              when "0001" => 
                Result_Out(15 downto 1)<=Data_in_1(14 downto 0);
                Result_Out(0)<=Data_in_1(15);
              when "0010" => 
                Result_Out(15 downto 2)<=Data_in_1(13 downto 0);
                Result_Out(1 downto 0)<=Data_in_1(15 downto 14);
              when "0011" => 
                Result_Out(15 downto 3)<=Data_in_1(12 downto 0);
                Result_Out(2 downto 0)<=Data_in_1(15 downto 13);
              when "0100" => 
                Result_Out(15 downto 4)<=Data_in_1(11 downto 0);
                Result_Out(3 downto 0)<=Data_in_1(15 downto 12);
              when "0101" => 
                Result_Out(15 downto 5)<=Data_in_1(10 downto 0);
                Result_Out(4 downto 0)<=Data_in_1(15 downto 11);
              when "0110" => 
                Result_Out(15 downto 6)<=Data_in_1(9 downto 0);
                Result_Out(5 downto 0)<=Data_in_1(15 downto 10);
              when "0111" => 
                Result_Out(15 downto 7)<=Data_in_1(8 downto 0);
                Result_Out(6 downto 0)<=Data_in_1(15 downto 9);
              when "1000" => 
                Result_Out<=Data_in_1;
              when "1001" => 
                Result_Out(14 downto 0)<=Data_in_1(15 downto 1);
                Result_Out(15)<=Data_in_1(0);
              when "1010" => 
                Result_Out(13 downto 0)<=Data_in_1(15 downto 2);
                Result_Out(15 downto 14)<=Data_in_1(1 downto 0);
              when "1011" => 
                Result_Out(12 downto 0)<=Data_in_1(15 downto 3);
                Result_Out(15 downto 13)<=Data_in_1(2 downto 0);
              when "1100" => 
                Result_Out(11 downto 0)<=Data_in_1(15 downto 4);
                Result_Out(15 downto 12)<=Data_in_1(3 downto 0);
              when "1101" => 
                Result_Out(10 downto 0)<=Data_in_1(15 downto 5);
                Result_Out(15 downto 11)<=Data_in_1(4 downto 0);
              when "1110" => 
                Result_Out(9 downto 0)<=Data_in_1(15 downto 6);
                Result_Out(15 downto 10)<=Data_in_1(5 downto 0);
              when "1111" => 
                Result_Out(8 downto 0)<=Data_in_1(15 downto 7);
                Result_Out(15 downto 9)<=Data_in_1(6 downto 0);
             when others => null;
            end case;
          when others =>
            Result_out <="XXXXXXXXXXXXXXXX";
      end case;
   end process;
 
end architecture arch_alu;
