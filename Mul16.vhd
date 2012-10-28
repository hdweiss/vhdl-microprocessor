--
--	Mul16.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity Mul16 is
	port (

		din1		: in bit_16;
		din2		: in bit_16;
		choose: in std_logic;
		dout		: out bit_16
				);
end Mul16;

architecture rtl of Mul16 is
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
