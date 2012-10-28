library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity Processor is
  port(
	clk : in std_logic;

    nrts : out std_logic;
    ncts : in  std_logic;
    rxd  : in  std_logic;
    txd  : out std_logic
);	
end Processor;

architecture bench of Processor is

  signal rst : std_logic := '1';

  -- serial port signals
  signal address : std_logic_vector(1 downto 0)  := (others => '0');
  signal wr_data : std_logic_vector(31 downto 0) := (others => '0');
  signal rd, wr  : std_logic                     := '0';
  signal rd_data : std_logic_vector(31 downto 0);
  signal rdy_cnt : ieee.numeric_std.unsigned(1 downto 0);

  signal uart_rd_data : std_logic_vector(15 downto 0);
  signal uart_wr_data : std_logic_vector(15 downto 0) := (others => '0');
  signal uart_rd : std_logic := '0';
  signal uart_wr : std_logic := '0';
  signal uart_addr : std_logic_vector(1 downto 0) := "00";

  
  begin

  dp : entity WORK.DataPath
    port map (
      clk => clk,
      rst => rst,
      uart_wr => uart_wr,
      uart_rd => uart_rd,
      uart_wr_data => uart_wr_data,
      uart_rd_data => uart_rd_data,
      uart_addr => uart_addr
      );

    
  sc_uart_inst : entity WORK.sc_uart
    generic map
    (
      clk_freq  => 50000000,
      baud_rate => 115000,
      txf_depth => 16,
      addr_bits => 2,
      txf_thres => 8,
      rxf_depth => 16,
      rxf_thres => 8
      )
    port map
    (
      address => address,
      wr_data => wr_data,
      rd      => rd,
      wr      => wr,
      rd_data => rd_data,
      rdy_cnt => rdy_cnt,
      clk     => clk,
      reset   => rst,
      txd     => txd,
      rxd     => rxd,
      ncts    => '0',
      nrts    => open
      );


  process(clk)
  begin
    rst <= '0';
  end process;



  process (uart_rd, rd_data, uart_wr, uart_wr_data, uart_addr)
  begin
  
    uart_rd_data <= rd_data(15 downto 0);
    wr_data(15 downto 0) <= uart_wr_data;
    wr_data(31 downto 16) <= (others => '0');

    rd <= uart_rd;
    wr <= uart_wr;

    address <= uart_addr;
  end process;
  
  --process (clk, uart_val) -- fancy serial port write
  --begin
    
  --  if rising_edge(clk) then

  --    case state is
  --      when st_read =>  --  signal the uart that we want to read status
  --        wr      <= '0';
  --        wr_data <= (others => '0');
  --        rd      <= '1';
  --        address <= "00";     -- tell the uart we want to read it's status
  --        state   <= st_wait;           -- wait until data is done

  --      when st_wait =>                 -- wait until the uart is ready
  --        if rdy_cnt < 2 then
  --          state <= st_write;
  --        end if;
  --        rd <= '0';
          
  --      when st_write =>
  --        if rd_data(0) = '1' then
  --          wr      <= '1';
  --          address <= "01";  -- tell the uart that we want to write data
  --          wr_data(15 downto 0) <= uart_val;
  --          wr_data(31 downto 16) <= (others => '0');
  --        end if;
          
  --        state <= st_read;

  --      when others => null;
  --    end case;


  --  end if;
  --end process;

  
end bench;
