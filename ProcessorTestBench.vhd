library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;

entity ProcessorTestBench is
  generic (period : time := 150 ns);
  
end ProcessorTestBench;

architecture dptb of ProcessorTestBench is

  signal clk : std_logic;
  signal rst : std_logic := '1';

  signal nrts : std_logic;
  signal ncts : std_logic;
  signal rxd : std_logic;
  signal txd : std_logic;
  
begin

  
  dp : entity WORK.Processor
    port map (
      clk => clk,
    nrts => nrts,
    ncts => ncts,
    rxd  => rxd,
    txd  => txd
      );

    
  process                               -- drives the clock
  begin
    rst <= '0';
    clk <= '1', '0' after period/2;
    wait for period;
  end process;

end dptb;
