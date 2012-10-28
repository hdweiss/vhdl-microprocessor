library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity uart_read is
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

end uart_read;


architecture bench of uart_read is
  
  -- Internal signals
  signal address : std_logic_vector(1 downto 0)  := (others => '0');
  signal wr_data : std_logic_vector(31 downto 0) := (others => '0');
  signal rd, wr  : std_logic                     := '0';
  signal rd_data : std_logic_vector(31 downto 0);
  signal rdy_cnt : unsigned(1 downto 0);

  signal reset  : std_logic := '0';
                               
  signal cnt : unsigned(31 downto 0) := (others => '0'); 
                                     
  constant CLK_FREQ : integer := 200000000;
  constant BLINK_FREQ : integer := 1;
  constant CNT_MAX    : integer := CLK_FREQ/BLINK_FREQ/2-1;

  signal blink : std_logic := '1';

  signal state : std_logic_vector(2 downto 0) := (others => '0');

  constant st_read : std_logic_vector(2 downto 0) := "000";
  constant st_wait : std_logic_vector(2 downto 0) := "001";
  constant st_getchar : std_logic_vector(2 downto 0) := "010";
  constant st_wait2 : std_logic_vector(2 downto 0) := "011";
  constant st_check : std_logic_vector(2 downto 0) := "100";


  
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

  
  process(clk, reset)                        -- blink the led
  begin
    
    if reset = '1' then
      cnt <= (others => '0');
      wr  <= '0';
      rd <= '0';
      address <= "00"; -- status register is 0
      blink <= '0';

      state <= st_read;
      
    elsif rising_edge(clk) then
                    if cnt = CNT_MAX then
                      cnt   <= (others => '0');
                    else
                      cnt <= cnt + 1; 
                    end if;
  end if;
end process;

led <= blink;



process (clk)
begin 
  
  if rising_edge(clk) then

    case state is
     when st_read =>        --  signal the uart that we want to read
         rd      <= '1';
        address <= "00";     -- tell the uart we want to read it's status
        state   <= st_wait;             -- wait until data is done

      when st_wait =>                   -- wait until the uart is ready
        rd <= '0';
        if rdy_cnt < 2 then
          state <= st_check;
        end if;
        
      when st_check =>                  -- check rd_data if we got any input
        if rd_data(1) = '1' then
          rd      <= '1';
          address <= "01";  -- tell the uart that we want to read data
          state <= st_wait2;
        else
          state <= st_read;
        end if;

      when st_wait2 =>                  -- wait until we can read data
        rd <= '0';
        if rdy_cnt < 2 then
          state <= st_getchar;
        end if;
        

      when st_getchar =>                -- read data
        if rd_data(7 downto 0)  = "00110000" then    -- ascii 0
          blink <= '0';
        elsif rd_data(7 downto 0) = "00110001" then -- ascii 1
          blink <= '1';                 
        end if;

        state <= st_read;
        
      when others => null;
    end case;


  end if;
end process;

end bench;
