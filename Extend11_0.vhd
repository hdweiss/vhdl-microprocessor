--
--	Extend11_0.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity Extend11_0 is
	port (
		din		: in bit_12;
		dout		: out bit_16
				);
end Extend11_0;

architecture rtl of Extend11_0 is
begin
	process(din)
	 begin
	     dout(15 downto 12) <= (others => '0');
	     dout(11 downto 0)  <= din;
	end process;

end rtl;
