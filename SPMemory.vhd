--
--  spmemory.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity SPMemory is
port (
    clk         : in std_logic;
    data_w      : in bit_16;
    MemRead     : in std_logic;
    MemWrite    : in std_logic;
    data_r      : out bit_16
);
end SPMemory;

architecture dm of SPMemory is
  type ram_type is array(0 to (2 ** 4) - 1) of bit_16;
  signal ram : ram_type;
  signal addr : bit_4 :=(others=>'1');
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if MemWrite = '1' then
        ram(to_integer(unsigned(addr))) <= data_w;
        addr<=std_logic_vector(unsigned(addr) - 1);  
        data_r <= data_w;  
      end if;
      if MemRead = '1' then
        if (addr/="1110") then
          data_r <= ram(to_integer(unsigned(addr))+2);
        end if;
        addr<=std_logic_vector(unsigned(addr) + 1);     
      end if;
    end if;

  end process;
end dm;

