--
--	Extend3_0.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity Extend3_0 is
	port (
		din		: in bit_4;
		dout		: out bit_16
				);
end Extend3_0;

architecture rtl of Extend3_0 is
begin
	process(din)
	 begin
	  dout(15 downto 8) <= (others => '0');
	  dout(3 downto 0)  <= din;
	end process;

end rtl;
