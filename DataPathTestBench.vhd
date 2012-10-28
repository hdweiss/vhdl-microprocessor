library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;

entity DataPathTestBench is
  generic (period : time := 150 ns);
  
end DataPathTestBench;

architecture dptb of DataPathTestBench is

  signal clk : std_logic;
  signal rst : std_logic := '1';
  
begin

  
  dp : entity WORK.DataPath
    port map (
      clk => clk,
      rst => rst
      );

    
  process                               -- drives the clock
  begin
    rst <= '0';
    clk <= '1', '0' after period/2;
    wait for period;
  end process;

end dptb;
