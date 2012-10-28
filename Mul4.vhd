--
--	Mul4.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity Mul4 is
	port (
		din1		: in bit_4;
		din2		: in bit_4;
		choose: in std_logic;
		dout		: out bit_4
				);
end Mul4;

architecture rtl of Mul4 is
begin
	process(din1,din2,choose)
	 begin
	  if(choose='0') then
	    dout<=din1;
	  else
	    dout<=din2;
	  end if;
	end process;

end rtl;
