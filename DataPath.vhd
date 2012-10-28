library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.pro_types.all;

entity datapath is
  port (
    clk : in  std_logic;
    rst : in std_logic;
    uart_wr : out std_logic;
    uart_rd : out std_logic;
    uart_wr_data : out std_logic_vector(15 downto 0);
    uart_rd_data : in std_logic_vector(15 downto 0);
    uart_addr : out std_logic_vector(1 downto 0)
    );

end datapath;

architecture dp of datapath is

--enable and flush
signal disableF : std_logic := '0';
signal disableD : std_logic := '0';
signal flush : std_logic := '0';


-- Instruction memory signals
signal IM_addr : bit_16 := (others => '0');
signal IM_instruction : bit_16 := (others => '0');

signal if_reg : bit_16 := (others => '0');    -- instruction fetch register

--control unit
alias opcode : bit_4 is if_reg(15 downto 12);
--control register
signal id_ctr : std_logic_vector(18 downto 0):= (others => '0');
signal ex_ctr : std_logic_vector(7 downto 0):= (others => '0');
signal mem_ctr :std_logic_vector(3 downto 0):= (others => '0');
signal wb_ctr :std_logic_vector(1 downto 0):= (others => '0');

--Jump signals
alias  Branch: std_logic is id_ctr(15); 
signal BPC : bit_16 := (others => '0');
signal JPC : bit_16 := (others => '0');
signal PC  : bit_16 := (others => '0');

alias ex_ctr_mov : std_logic is id_ctr(17);
alias ex_ctr_reg : std_logic_vector(7 downto 0)is id_ctr(7 downto 0);
alias mem_ctr_reg : std_logic_vector(3 downto 0)is ex_ctr(3 downto 0);
alias wb_ctr_reg : std_logic_vector(1 downto 0)is mem_ctr(1 downto 0);

-- Register file signals
alias  REG_reg1 : bit_4 is if_reg(11 downto 8);
signal REG_reg1_data : bit_16 := (others => '0');
alias  REG_reg2 : bit_4 is if_reg (7 downto 4);
signal REG_reg2_data : bit_16 := (others => '0');
signal REG_write : bit_4 := (others => '0');
signal REG_write_data : bit_16 := (others => '0');
alias  REG_dowrite : std_logic is wb_ctr(0);

--Extend Units
alias const : bit_8 is if_reg(7 downto 0);
signal exconst : bit_16 := (others => '0');
alias offset : bit_4 is if_reg(3 downto 0);
signal exoffset : bit_16 := (others => '0');
alias  pcoffset : bit_12 is if_reg(11 downto 0);
signal expcoffset : bit_16 := (others => '0');

--Mux Units(1-3)
alias wr1 : bit_4 is if_reg(11 downto 8);
alias wr2 : bit_4 is if_reg(3 downto 0);
alias Mux1 : std_logic is id_ctr(13);
signal wr  : bit_4 := (others => '0');

alias Mux2 : std_logic is id_ctr(12);
signal op1  : bit_16 := (others => '0');

alias Mux3 : std_logic_vector(1 downto 0) is id_ctr(11 downto 10);
signal op2  : bit_16 := (others => '0');

alias Mux4 : std_logic is id_ctr(9);


--branch, jump, call, return
alias Ret : std_logic is id_ctr(8);
alias call : std_logic is id_ctr(14);
signal AddrReturn  : bit_16 := (others =>'0');
alias Jump : std_logic is id_ctr(16);
signal Exbranch : bit_16 := (others => '0');


signal Mux5 : std_logic := '0';
signal Mux6 : std_logic := '0';
signal mux5_output  : bit_16 := (others => '0');
signal mux6_output  : bit_16 := (others => '0');

alias MemtoReg : std_logic is wb_ctr(1);
-- ALU signals
alias  ALU_Opcode       : bit_4 is ex_ctr(7 downto 4);
signal ALU_Result       : bit_16 := (others => '0');

-- Data memory signals
--signal DM_data_w : bit_16 := (others => '0');
signal DM_data_r : bit_16 := (others => '0');
signal DM_data_r_redirect : bit_16 := (others => '0');
alias  DM_MemRead: std_logic is ex_ctr(3);
alias  DM_MemWrite: std_logic is ex_ctr(2);

-- instruction decode register
signal id_reg_WR  : bit_4 := (others => '0'); 
signal id_reg_WD  : bit_16 := (others => '0'); 
signal id_reg_op1 : bit_16 := (others => '0');  
signal id_reg_op2 : bit_16 := (others => '0'); 
signal hu_RsE : bit_4 := (others => '0');            
signal hu_RtE : bit_4 := (others => '0');

-- Execution register
signal ex_reg_WR  : bit_4 := (others => '0'); 
signal ex_reg_WD  : bit_16 := (others => '0'); 
signal ex_reg_aluresult : bit_16 := (others => '0');  

-- Memory register
signal mem_reg_RD  : bit_16 := (others => '0'); 
signal mem_reg_aluresult : bit_16 := (others => '0'); 

-- Hazard unit
alias Inst_type: bit_2 is id_ctr(18 downto 17);
alias hu_RtD : bit_4 is if_reg(11 downto 8); 
alias hu_RsD : bit_4 is if_reg(7 downto 4); 
alias hu_RegWriteM : std_logic is mem_ctr(0);
signal hu_ForwardAE : bit_2 := (others => '0');
signal hu_ForwardBE : bit_2 := (others => '0');
signal hu_ForwardWD : bit_2 := (others => '0');
signal  hu_ForwardBranch : bit_2 := (others => '0');
signal hu_MuxA : bit_16 := (others => '0');
signal hu_MuxB : bit_16 := (others => '0');
signal hu_WD : bit_16 := (others => '0');

signal dm_uart_val : bit_16 := (others => '0');

signal uart_reg_l, uart_reg_c : std_logic := '0';
signal uart_reg_val : bit_16 := (others => '0');
signal uart_reg_tmp : bit_16 := (others => '0');

begin
  
  Hazard_Unit_instance : entity WORK.Hazard_Unit
    port map (
      Inst_type => Inst_type,
      WriteRegW  => REG_write,
      WriteRegM  =>  ex_reg_WR,
       
      RsE    =>  hu_RsE,
      RtE    =>  hu_RtE,
      RsD    =>  hu_RsD,
      RtD    =>  hu_RtD,
      
      RegWriteW =>  REG_dowrite,
      RegWriteM  =>  hu_RegWriteM,


      ForwardBE =>  hu_ForwardBE,
      ForwardAE    =>  hu_ForwardAE,
      ForwardWD    =>  hu_ForwardWD,
      ForwardBranch=>  hu_ForwardBranch,
        
      StallF     =>  disableF,
      StallD    =>  disableD,
      FlushE    =>  flush,
      MemtoRegE  =>  ex_ctr(3)
    );
  
  Branch_instance : entity WORK.Branch
    port map (
      Branch => Branch,
		  Rd1		=> Exbranch,
		  Offset=>exconst,
		  PC   =>IM_addr,
		  BPC		=>BPC
		  );
		  
  extend11_0_instance : entity WORK.Extend11_0
    port map(
		  din		=> pcoffset,
		  dout	=> expcoffset
      ); 		  
		  
  Mux_instance4 : entity WORK.Mul16
    port map(
		  din1		=> expcoffset,
		  din2		=> AddrReturn,
		  choose=> Mux4,
		  dout		=> JPC
      );  
 
  Mux_instance_jump : entity WORK.Mul16
    port map(
		  din1		=> BPC,
		  din2		=> JPC,
		  choose=> Jump,
		  dout		=> PC
      ); 
      
   hu_Mux_instanceWD : entity WORK.Mul16_4   
    port map(
		  din1		=> id_reg_WD,
		  din2		=> REG_write_data,
		  din3		=> ex_reg_aluresult,
		  din4		=> (others => '0'), --huTODO
		  choose=> hu_ForwardWD,
		  dout		=> hu_WD
      );
                  
  hu_Mux_instance1 : entity WORK.Mul16_4   
    port map(
		  din1		=> id_reg_op1,
		  din2		=> REG_write_data,
		  din3		=> ex_reg_aluresult,
		  din4		=> (others => '0'), --huTODO
		  choose=> hu_ForwardAE,
		  dout		=> hu_MuxA
      );        

  hu_Mux_instance2 : entity WORK.Mul16_4   
    port map(
		  din1		=> id_reg_op2,
		  din2		=> REG_write_data,
		  din3		=> ex_reg_aluresult,
		  din4		=> (others => '0'), --huTODO
		  choose=> hu_ForwardBE,
		  dout		=> hu_MuxB
      );    
      
   hu_Mux_instanceBranch : entity WORK.Mul16_4   
    port map(
		  din1		=> mux5_output,
		  din2		=> REG_write_data,
		  din3		=> ex_reg_aluresult,
		  din4		=> (others => '0'), --huTODO
		  choose=> hu_ForwardBranch,
		  dout		=> Exbranch
      );   
             
  IM_instance : entity WORK.InstructionMemory
    port map (
      clk => clk,
      disable => disableF,
      address => IM_addr,
      q => IM_instruction
      );  
      
  control_instance : entity WORK.Control
    port map(
		  Inst		     => opcode,
		  contr_sign => id_ctr 
      );
      
  registerfile_instance : entity WORK.Registers
    port map(
      clk => clk,
      disable => disableD,
      RR1 => REG_reg1,
      RR2 => REG_reg2,
      WR => REG_write,
      Wdata => REG_write_data,
      RegWrite => REG_dowrite,
      Rdata1 => REG_reg1_data,
      Rdata2 => REG_reg2_data
      );
      
  extend7_0_instance : entity WORK.Extend7_0
    port map(
		  din		=> const,
		  dout	=> exconst
      ); 
      
  extend3_0_instance : entity WORK.Extend3_0
    port map(
		  din		=> offset,
		  dout	=> exoffset
      );  
         
  Mux_instance1 : entity WORK.Mul4
    port map(
		  din1		=> wr1,
		  din2		=> wr2,
		  choose=> Mux1,
		  dout		=> wr
      );   
               
  Mux_instance2 : entity WORK.Mul16
    port map(
		  din1		=> mux5_output,
		  din2		=> mux6_output,
		  choose=> Mux2,
		  dout		=> op1
      );  
                     
  Mux_instance3 : entity WORK.Mul16_4
    port map(
		  din1		=> mux6_output,
		  din2		=> exconst,
		  din3		=> exoffset,
		  din4		=> (others => '0'),
		  choose=> Mux3,
		  dout		=> op2
      );
      
  Mux_instance5 : entity WORK.Mul16
    port map(
		  din1		=> REG_reg1_data,
		  din2		=> REG_write_data,
		  choose=> Mux5,
		  dout		=> mux5_output
      );  
      
  Mux_instance6 : entity WORK.Mul16
    port map(
		  din1		=> REG_reg2_data,
		  din2		=> REG_write_data,
		  choose=> Mux6,
		  dout		=> mux6_output
      );  
      
  alu_instance : entity WORK.Alu
      port map  (
       Data_in_1 => hu_MuxA,
       Data_in_2 => hu_MuxB,
       Opcode => ALU_Opcode,
       Result_Out=> ALU_Result
    );

  datamemory_instance : entity WORK.DataMemory
    port map(
      clk   =>  clk,
      data_w     =>hu_WD,
      addr      =>ALU_Result,
      MemRead    =>DM_MemRead,
      MemWrite   =>DM_MemWrite,
      data_r     =>DM_data_r_redirect
      );
  spmemory_instance : entity WORK.SPMemory
    port map(
      clk   =>  clk,
      data_w     =>IM_addr,
      MemRead    =>Ret,
      MemWrite   =>Call,
      data_r     =>AddrReturn 
      );   
  Mux_instanceMemtoReg : entity WORK.Mul16
    port map(
		  din1		=> mem_reg_aluresult,
		  din2		=> mem_reg_RD,
		  choose=> MemtoReg,
		  dout		=> REG_write_data
      );

  -- serial port
  uart : process(clk, ALU_Result, DM_MemWrite, hu_WD,  DM_MemRead, uart_rd_data, DM_data_r_redirect)
  begin

    if rising_edge(clk) then
          uart_wr_data <= (others => '0');
          uart_wr <= '0';
          
          if DM_MemWrite = '1' then
            if ALU_Result = "0000000000001111" then
              uart_wr_data <= hu_WD;
              uart_addr <= "01";
              uart_wr <= '1';
            end if;
          end if;
    end if;

    if rising_edge(clk) then
      uart_rd <= '0';
      uart_reg_l <= '0';
      uart_reg_c <= '0';
      uart_addr <= "01";

      if DM_MemRead = '1' then
        if ALU_Result = "0000000000001111" then
          DM_data_r <= uart_rd_data;
          uart_rd   <= '1';
          uart_addr <= "01";
        elsif ALU_Result = "0000000000001110" then
          DM_data_r <= uart_rd_data;
          uart_rd   <= '1';
          uart_addr <= "00";
        else
          DM_data_r <= DM_data_r_redirect;
        end if;
      end if;

    end if;

  end process;

  --process (clk, uart_reg_l, uart_reg_c, uart_reg_val)
  --begin
  --  if uart_reg_c = '0' then
  --          uart_reg_tmp <= (uart_reg_tmp'range => '0');
  --  elsif rising_edge(clk) then
  --      if uart_reg_l = '1' then
  --  	uart_reg_tmp <= uart_reg_val;
  --      end if;
  --  end if;
  --end process;
  
  -- Increments the pc (IM_addr)
  instruction_pointer : process(clk)
  begin
    if (rising_edge(clk) AND (disableF='0')) then
      IM_addr <= PC;
    end if;
  end process;

  
  -- Fetches the instruction that IM_addr points at and loads it into if_reg
  instruction_fetch : process(clk)
  begin
    if (rising_edge(clk)AND (disableD='0') )then
      if_reg <= IM_instruction;         -- load new instruction into if_reg
    end if;
    if (falling_edge(clk) AND (disableD='0'))then
      if (REG_reg1 = REG_write AND REG_dowrite = '1') then
        Mux5 <= '1';
      else Mux5 <= '0';
      end if;
      if (REG_reg2 = REG_write AND REG_dowrite = '1') then
        Mux6 <= '1';
      else Mux6 <= '0';
      end if;
    end if;
  end process;
  

  -- ID/EX
  instruction_execute : process(clk)
  begin
    if rising_edge(clk) then
      if (flush='1') then
      ex_ctr<= (others => '0'); 
      id_reg_WR  <=(others => '0'); 
      id_reg_WD  <= (others => '0'); 
      id_reg_op1 <=(others => '0');  
      id_reg_op2 <=(others => '0'); 
      hu_RtE <= (others => '0');
      hu_RsE <= (others => '0');
      else
      ex_ctr<= ex_ctr_reg; 
      id_reg_WR  <=wr; 
      id_reg_WD  <= mux5_output; 
      id_reg_op1 <=op1;  
      id_reg_op2 <=op2; 
      hu_RtE <= hu_RtD;
      hu_RsE <= hu_RsD;
    end if;
       
    end if; 
  end process;

  --EX/MEM
  memory_loadstore: process(clk)
  begin
    if rising_edge(clk) then
      mem_ctr<= mem_ctr_reg;
      ex_reg_WR  <=id_reg_WR ; 
 --     ex_reg_WD  <=hu_WD; 
      ex_reg_aluresult <=ALU_Result; 
    end if; 
  end process;
  
--MEM/WB
  WriteBack: process(clk)
  begin
    if rising_edge(clk) then
      wb_ctr<= wb_ctr_reg;
      REG_write<= ex_reg_WR;
      mem_reg_RD  <= DM_data_r;
      mem_reg_aluresult <=ex_reg_aluresult; 
    end if; 
  end process;

 end dp;
