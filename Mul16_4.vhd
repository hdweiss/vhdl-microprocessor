--
--	Mul16_4.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity Mul16_4 is
	port (
		din1		: in bit_16;
		din2		: in bit_16;
		din3		: in bit_16;
		din4		: in bit_16;
		choose: in std_logic_vector(1 downto 0);
		dout		: out bit_16
				);
end Mul16_4;

architecture rtl of Mul16_4 is
begin
	process(din1,din2,din3,din4,choose)
	 begin
	  case choose is
	    when "00" =>
	      dout <= din1;
	    when "01" =>
	      dout <= din2;
	    when "10" =>
	      dout <= din3;
	    when "11" =>
	      dout <= din4;
	    when others =>
	   end case;
	end process;

end rtl;
