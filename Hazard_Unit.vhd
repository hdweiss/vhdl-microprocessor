library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pro_types.all;

entity Hazard_Unit is
   port
   (
	--WriteRegW and WriteRegM are the destination registers for the instructions being in that stages
	--RxE and RyE are the input registers for the instructionz being in ALU
	  WriteRegW, WriteRegM, RsE, RtE, RsD, RtD: in bit_4;
	  Inst_type: in bit_2;
	  RegWriteW,RegWriteM			   : in std_logic ;
		MemtoRegE 						: in  std_logic;
	  ForwardBE, ForwardAE, ForwardWD, ForwardBranch : out bit_2;
		StallF,StallD,FlushE 				: out std_logic
   );
end entity Hazard_Unit;

 architecture arc_hazardUnitPipeline of Hazard_Unit is
 
 signal lwstall : std_logic ;
 
begin
 process(RtE,RsE,WriteRegM,RegWriteM,WriteRegW,RegWriteW) 
   --Memory values are  of higher priority because they are the most up to date ones
   -- In other(losfer) words : if the value of an input register exists both in Memory and Writeback stage of 
   -- 2 other instructions the tie breaks in favor of the Memory
    begin
    ForwardAE <= "00";
    ForwardBE <= "00"; 
    ForwardWD <= "00";
    ForwardBranch <= "00"; 
	--check srcA
	--forwarding for arithmetic operations instructions and move instruction which Rt is the first oprand
	if(Inst_type(1)='1') then
	   if((RegWriteM='1') AND(RtE = WriteRegM)) then 
	     	  ForwardAE <= "10";--forward Memory
	   else if ((RegWriteW='1') AND(RtE = WriteRegW))  then
		           ForwardAE <= "01";-- Forward Writeback
	        end if;  
	    end if;
	 --some other instructions which Rs is the first oprand
	 else   if((RegWriteM='1') AND(RsE = WriteRegM)) then 
	     	           ForwardAE <= "10";--forward Memory
	            
	           else if ((RegWriteW='1') AND (RsE = WriteRegW))  then
		                    ForwardAE <= "01";-- Forward Writeback
	                end if;  
	             end if;
	  end if;
		--check srcB
		if (Inst_type="10")then
		  if	((RsE = WriteRegM) AND (RegWriteM='1')) then 
		    ForwardBE <= "10";--forward Memory
		  else if ((RsE = WriteRegW) AND (RegWriteW='1')) then
		           ForwardBE <= "01";-- Forward Writeback
	         end if; 
		  end if;
		 end if;
		 --check WD for ST
		 if (Inst_type="00")then
		  if	((RtE = WriteRegM) AND (RegWriteM='1')) then 
		    ForwardWD <= "10";--forward Memory
		  else if ((RtE = WriteRegW) AND (RegWriteW='1')) then
		           ForwardWD <= "01";-- Forward Writeback
	         end if; 
		  end if;
		 end if;
   
   --check Branch
   if(Inst_type="00") then
	   if((RegWriteM='1') AND(RtD = WriteRegM)) then 
	     	  ForwardBranch <= "10";--forward Memory
	     end if;
	  -- else if ((RegWriteW='1') AND(RtD = WriteRegW))  then
		 --        ForwardBranch <= "01";-- Forward Writeback
	    --    end if;  
	   end if;
	 end process;   
   process(MemtoRegE,RtD,RtE,RsD) is
		-- Solving Data Hazards with Stalls, LOAD instruction
		-- RtE is th Register where the value will be loaded to 
		begin
	 
					if(((RtD=RtE)OR(RsD=RtE)) AND (MemtoRegE = '1')) then 
						lwstall <= '1';
			   		else
						lwstall <='0';			
			 	end if;
	 end process;
	 
	 process(lwstall)
	  begin
				  StallF <= lwstall;
			  	  StallD <= lwstall;
			  	  FlushE <= lwstall;
			  	  
   end process;
   
end;