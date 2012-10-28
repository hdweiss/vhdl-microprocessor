--
--	Branch.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity Branch is
	port (
    Branch: in  std_logic;
		Rd1		: in bit_16;
		Offset: in bit_16;
		PC   : in bit_16;
		BPC		: out bit_16
				);
end Branch;

architecture rtl of Branch is
begin
	process(Branch,Rd1,Offset,PC)
	 begin
	  if(Rd1="0000000000000000" AND Branch='1') then
	    BPC<=std_logic_vector(unsigned(PC) + unsigned(Offset)-2);
	  else
	    BPC<=std_logic_vector(unsigned(PC) + 1);
	  end if;
	end process;

end rtl;
