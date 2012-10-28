library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity uart_write is
  generic (period : time := 50 ns);

  -- fpga ports
  port (
    clk : in  std_logic;
    led : out std_logic;

    nrts : out std_logic;
    ncts : in  std_logic;
    rxd  : in  std_logic;
    txd  : out std_logic
    );

end uart_write;


architecture bench of uart_write is

  -- Internal signals
  signal address : std_logic_vector(1 downto 0)  := (others => '0');
  signal wr_data : std_logic_vector(31 downto 0) := (others => '0');
  signal rd, wr  : std_logic                     := '0';
  signal rd_data : std_logic_vector(31 downto 0);
  signal rdy_cnt : unsigned(1 downto 0);

  signal reset : std_logic := '0';

  signal cnt : unsigned(31 downto 0) := (others => '0');

  constant CNT_MAX : integer := 10;

  signal blink : std_logic := '1';

  signal state : std_logic_vector(2 downto 0) := (others => '0');

  constant st_read  : std_logic_vector(2 downto 0) := "000";
  constant st_wait  : std_logic_vector(2 downto 0) := "001";
  constant st_write : std_logic_vector(2 downto 0) := "010";


  
begin

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
    port map                            -- Maps internal signals to ports
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
      ncts    => '0',
      nrts    => open
      );

  
  process(clk, reset)                   -- blink the led
  begin
    
    if reset = '1' then
      cnt     <= (others => '0');
      wr      <= '0';
      rd      <= '0';
      address <= "00";                  -- status register is 0
      blink   <= '0';

      state <= st_read;
      
    end if;
  end process;

  led <= blink;



  process (clk)
  begin
    
    if rising_edge(clk) then

      if cnt = CNT_MAX then             -- wrap counter
        cnt <= (others => '0');
      end if;

      case state is
        when st_read =>  --  signal the uart that we want to read status
          wr      <= '0';
          wr_data <= (others => '0');

          rd      <= '1';
          address <= "00";     -- tell the uart we want to read it's status
          state   <= st_wait;           -- wait until data is done

        when st_wait =>                 -- wait until the uart is ready
          if rdy_cnt < 2 then
            state <= st_write;
          end if;
          rd <= '0';
          
        when st_write =>
          if rd_data(0) = '1' then

            wr      <= '1';
            address <= "01";  -- tell the uart that we want to write data
            wr_data <= std_logic_vector(to_unsigned(48, 32) + cnt);  -- write 0+cnt

            cnt <= cnt + 1;
          end if;
          
          state <= st_read;

        when others => null;
      end case;


    end if;
  end process;

end bench;
