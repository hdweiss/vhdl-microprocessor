library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pro_types is
  constant unit_delay: Time := 100 ns;
  subtype bit_2 is std_logic_vector(1 downto 0);
  subtype bit_4 is std_logic_vector(3 downto 0);
  subtype bit_8 is std_logic_vector(7 downto 0);
  subtype bit_12 is std_logic_vector(11 downto 0);
  subtype bit_16 is std_logic_vector(15 downto 0);
  
  constant bit_16_zero :bit_16 := (others =>'0');
  
  constant inst_nop : bit_4 := "0000";
  constant inst_ld  : bit_4 := "0001";
  constant inst_st : bit_4 := "0010";
  constant inst_breq : bit_4 := "0011";
  constant inst_jump : bit_4 := "0100";
  constant inst_add : bit_4 := "0101";
  constant inst_addi : bit_4 := "0110";
  constant inst_movh  : bit_4 := "0111";
  constant inst_movl : bit_4 := "1000";
  constant inst_and  : bit_4 := "1001";
  constant inst_or : bit_4 := "1010";
  constant inst_xor : bit_4 := "1011";
  constant inst_sub : bit_4 := "1100";
  constant inst_sf : bit_4 := "1101";
  constant inst_ret : bit_4 := "1110";
  constant inst_call  : bit_4 := "1111";
  
  
  constant op_and : bit_4 := "0000";
  constant op_or  : bit_4 := "0001";
  constant op_xor : bit_4 := "0010";
  constant op_sub : bit_4 := "0011";
  constant op_add : bit_4 := "0100";
  constant op_movh : bit_4 := "0101";
  constant op_movl : bit_4 := "0110";
  constant op_sf  : bit_4 := "0111";
  
end pro_types;