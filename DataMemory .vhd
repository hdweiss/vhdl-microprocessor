--
--  datamemory.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity DataMemory is
port (
    clk         : in std_logic;
    data_w      : in bit_16;
    addr        : in bit_16;
    MemRead     : in std_logic;
    MemWrite    : in std_logic;
    data_r      : out bit_16
);
end DataMemory;

architecture dm of DataMemory is
  type ram_type is array(0 to (2 ** 10) - 1) of bit_16;
  signal ram : ram_type;
begin
  process(clk, data_w, MemWrite, MemRead, addr)
  begin
    if rising_edge(clk) then
      if MemWrite = '1' then
          ram(to_integer(unsigned(addr))) <= data_w;
      end if;

      if MemRead = '1' then
          data_r <= ram(to_integer(unsigned(addr)));
      end if;
    end if;
  end process;
end dm;

