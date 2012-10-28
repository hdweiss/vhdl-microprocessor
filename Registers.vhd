--
--	Registers.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.pro_types.all;

entity Registers is --three-port register file
port(             
	clk       : in std_logic; 
	disable   : in std_logic;
	RR1	     	: in bit_4; --ra1
	RR2	      : in bit_4;   --ra2
    WR        : in bit_4;	--wa3
    Wdata     : in bit_16;  --wd3
    RegWrite  : in std_logic; --we3
    Rdata1    : out bit_16; --rd1
    Rdata2    : out bit_16	--rd2	 
    );
end;

architecture behave of Registers is
	type ramtype is array(15 downto 0) of bit_16;
	
	signal mem: ramtype := (others =>bit_16_zero);
	
  begin
  --3 ported register file: 2 output and 1 input
	process(clk) begin
		if rising_edge(clk) then
			if (RegWrite='1') then
				mem(CONV_INTEGER(WR)) <= Wdata;
			end if;
		end if;
	end process;
	--READ
	process(RR1,RR2,clk) begin		 
		if (falling_edge(clk) AND disable='0')then
			--if (RR1=WR AND RegWrite='1') then
				--Rdata1 <= Wdata; --forwarding
				--else
				Rdata1 <= mem(CONV_INTEGER(RR1));
			--end if;
			
			--if (RR2=WR AND RegWrite='1') then
				--Rdata2 <= Wdata; --forwarding
				--else
				Rdata2 <= mem(CONV_INTEGER(RR2));
			--end if;
		end if;
	end process;
	end;
