library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity uart_modelsim is
  generic (period : time := 50 ns);
end uart_modelsim;


architecture bench of uart_modelsim is
  
  component sc_uart                     --  Declaration of uart driver
    generic (addr_bits : integer := 32;
	clk_freq : integer := 8;
	baud_rate : integer := 1;
	txf_depth : integer := 32; txf_thres : integer := 32;
	rxf_depth : integer := 32; rxf_thres : integer := 32);
    port(
      clk   : in std_logic;
      reset : in std_logic;

      address : in  std_logic_vector(32-1 downto 0);
      wr_data : in  std_logic_vector(31 downto 0);
      rd, wr  : in  std_logic;
      rd_data : out std_logic_vector(31 downto 0);
      rdy_cnt : out unsigned(1 downto 0);
      txd		: out std_logic;
      rxd		: in std_logic;
      ncts	: in std_logic;
      nrts	: out std_logic
      );
  end component;

                                        -- Internal signals
  signal address : std_logic_vector(32-1 downto 0) := (others => '1');
  signal wr_data : std_logic_vector(31 downto 0)   := (others => '0');
  signal rd, wr  : std_logic                       := '0';
  signal rd_data : std_logic_vector(31 downto 0);
  signal rdy_cnt : unsigned(1 downto 0);

  signal clk    : std_logic := '0';
  signal reset  : std_logic := '0';
  signal toggle : std_logic := '0';

  signal txd : std_logic := '0';
  signal rxd : std_logic := '0';
  signal ncts : std_logic := '0';
  signal nrts : std_logic := '0';

  signal cnt : unsigned(31 downto 0)         := (others => '0');

begin
  
  sc_uart_inst : sc_uart port map       -- Maps internal signals to ports
    (
      address => address,
      wr_data => wr_data,
      rd      => rd,
      wr      => wr,
      rd_data => rd_data,
      rdy_cnt => rdy_cnt,
      clk     => clk,
      reset   => reset,
      txd     => txd,
      rxd     => rxd,
      ncts    => ncts,
      nrts    => nrts
      );

  process                               -- drives the clock
  begin
    rd  <= '1';
    clk <= '1', '0' after period/2;
    wait for period;
  end process;

  process                   -- write hello world to uart
  begin
      wr <= '1';

      wr_data <= std_logic_vector(to_unsigned(72, 32));
      wait for period;
      wr_data <= std_logic_vector(to_unsigned(101, 32));
      wait for period;
      wr_data <= std_logic_vector(to_unsigned(108, 32));
      wait for period;      
      wr_data <= std_logic_vector(to_unsigned(108, 32));
      wait for period;
      wr_data <= std_logic_vector(to_unsigned(111, 32));
      wait for period;

      wr <= '0';
      
      wait for 1000000 ns;
  end process;
  
  
end bench;
