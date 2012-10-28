--
--	Control.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity Control is
	port (
		Inst		: in bit_4;
		contr_sign: out std_logic_vector(18 downto 0)
				);
end Control;

architecture rtl of Control is
begin
	process(Inst)
	  alias Inst_type : bit_2 is contr_sign(18 downto 17);
	  alias jump : std_logic is contr_sign(16);
	  alias branch: std_logic is contr_sign(15);
	  alias call : std_logic is contr_sign(14);
	  alias mux1 : std_logic is contr_sign(13);
	  alias mux2 : std_logic is contr_sign(12);
	  alias mux3 : bit_2 is contr_sign(11 downto 10);
	  alias mux4 : std_logic is contr_sign(9);
	  alias Ret : std_logic is contr_sign(8);
	  alias opcode : bit_4 is contr_sign(7 downto 4);
	  alias MemRead : std_logic is contr_sign(3);
	  alias MemWrite : std_logic is contr_sign(2);
	  alias MemtoReg : std_logic is contr_sign(1);
	  alias RegWrite : std_logic is contr_sign(0);
	  
	  
	 begin
	   contr_sign<=(others => '0');
	   case Inst is
          when inst_ld =>
            Inst_type<="01";
            mux2<='1';
            mux3<="10";
            opcode<=op_add;
            MemRead<='1';
            MemtoReg<='1';
            RegWrite<='1';
           when inst_st =>
            Inst_type<="00";
            mux2<='1';
            mux3<="10";
            opcode<=op_add;
            MemWrite<='1';
          when inst_breq =>
            Inst_type<="00";
            branch<='1';
          when inst_jump =>
            jump<='1';
          when inst_add =>
            Inst_type<="10";
            mux1<='1';
            opcode<=op_add;
            RegWrite<='1';
          when inst_addi =>
            Inst_type<="11";
            mux3<="01";
            opcode<=op_add;
            RegWrite<='1';
          when inst_movh =>
            Inst_type<="11";
            mux3<="01";
            opcode<=op_movh;
            RegWrite<='1';
          when inst_movl =>
            Inst_type<="11";
            mux3<="01";
            opcode<=op_movl;
            RegWrite<='1';
          when inst_and =>
            Inst_type<="10";
            mux1<='1';
            opcode<=op_and;
            RegWrite<='1';
          when inst_or =>
            Inst_type<="10";
            mux1<='1';
            opcode<=op_or;
            RegWrite<='1';
         when inst_xor =>
           Inst_type<="10";
            mux1<='1';
            opcode<=op_xor;
            RegWrite<='1'; 
          when inst_sub =>
            Inst_type<="10";
            mux1<='1';
            opcode<=op_sub;
            RegWrite<='1';
          when inst_sf =>
            Inst_type<="01";
            mux2<='1';
            mux3<="10";
            opcode<=op_sf;
            RegWrite<='1';
          when inst_call =>
            call<='1';
            jump<='1';
          when inst_ret =>
            Ret<='1';
            mux4<='1';
            jump<='1';  
          when others =>
            
      end case;
	end process;

end rtl;
