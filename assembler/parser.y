%{
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "uthash.h"

//FILE *out;
FILE *yyin;
int cmd_counter=0;
unsigned char instructions[1000];
unsigned char instructions2[1000];
static struct pass_1 {
	char label[20];
	int addr;
	UT_hash_handle hh; /*makes this struct hashable*/
};
struct pass_1 *hashLABEL, *hashADDR = NULL;

//char strBefore[1000], strAfter[200];
char strBefore[1000] = "library ieee; \n \
use ieee.std_logic_1164.all; \n \
use work.pro_types.all; \n \
 \n \
entity InstructionMemory is \n \
port ( \n \
    clk         : in std_logic; \n \
    disable     : in std_logic; \n \
    address     : in bit_16; \n \
    q           : out bit_16 \n \
); \n \
end InstructionMemory; \n \
 \n \
architecture im of InstructionMemory is \n \
 \n \
    signal areg     : bit_16; \n \
    signal data     : bit_16; \n \
 \n \
begin \n \
 \n \
process(clk) begin \n \
 \n \
    --if (rising_edge(clk) AND disable='0')then \n \
      --  areg <= address; \n \
    --end if; \n \
 \n \
    if (rising_edge(clk))then \n \
        if (disable='0') then \n \
			areg <= address; \n \
        end if; \n \
    end if; \n \
end process; \n \
 \n \
    q <= data; \n \
 \n \
process(areg) begin \n \
 \n \
  case areg is \n";  

char strAfter[200] = "\nwhen others => data <= \"0000000000000000\";\n    end case;\nend process;\n\nend im;\0";


#define opNOP 0
#define opLD 1
#define opST 2
#define opBREQ 3
#define opJMP 4
#define opADDR 5
#define opADDI 6
#define opMOVH 7
#define opMOVL 8
#define opAND 9
#define opOR 10
#define opXOR 11
#define opSUB 12
#define opSF 13
#define opRET 14
#define opCALL 15
%}

%union {
	char * strval;
	int intval;
}
%type <strval> LABEL ADDRESS REG
%type <intval> CONST 

%token NOP LD ST ADDR AND OR XOR SUB BREQ ADDI MOVH MOVL JMP CALL RET SF LABEL ADDRESS REG CONST

%%

commands: 
	| commands command;

command: nop | ret | jmp | call | breq | addi | ld | st | addr | movh | movl | and | or | xor | sub | sf | lbl ;


lbl: LABEL 
	{
	fill($1);
	printf("parser: label \"%s\"\n", $1);
			
	};

nop: NOP
	{
	instructions[cmd_counter*2] = 0;
	instructions[cmd_counter*2+1]=0;
	cmd_counter++;
	printf("parser: NOP\n");
	};

ret: RET 
	{
	instr0(opRET);
	printf("parser: RET\n");
	};


jmp: JMP ADDRESS
	{
	instr1(opJMP, $2);	
	printf("parser: JMP %s\n",$2);
	};

call: CALL ADDRESS
	{
	instr1(opCALL, $2);
	printf("parser: CALL %s\n", $2);
	};

breq: BREQ REG CONST
	{
	instrBranch($2, $3);
	printf("parser: BREQ %s %d\n", $2, $3);
	};

addi: ADDI REG CONST
	{
	instr2ry(opADDI, $2, $3);
	printf("parser: ADDI %s %d\n", $2, $3);	
	};

ld: LD REG REG CONST
	{
	instr3rry(opLD, $2, $3, $4);
	printf("parser: LD %s %s %d\n",$2, $3, $4);
	};

st: ST REG REG CONST
	{
	instr3rry(opST, $2, $3, $4);
	printf("parser: ST %s %s %d\n",$2, $3, $4);
	};

addr: ADDR REG REG REG
	{
	instr3rrr(opADDR, $2, $3, $4);
	printf("parser: ADDR %s %s %s\n",$2, $3, $4);
	};

and: AND REG REG REG
	{
	instr3rrr(opAND, $2, $3, $4);
	printf("parser: AND %s %s %s\n",$2, $3, $4);
	};

or: OR REG REG REG
	{
	instr3rrr(opOR, $2, $3, $4);
	printf("parser: OR %s %s %s\n",$2, $3, $4);
	};

xor: XOR REG REG REG
	{
	instr3rrr(opXOR, $2, $3, $4);
	printf("parser: XOR %s %s %s\n",$2, $3, $4);
	};

sub: SUB REG REG REG
	{
	instr3rrr(opSUB, $2, $3, $4);
	printf("parser: OR %s %s %s\n",$2, $3, $4);
	};

sf: SF REG REG CONST CONST
	{
	instr4rrdy(opSF, $2, $3, $4, $5);
	printf("parser: SF %s %s %d %d\n",$2, $3, $4, $5);
	};

movh: MOVH REG CONST
	{
	instr2ry(opMOVH, $2, $3);
	printf("parser: MOVH %s %d\n",$2, $3);
	};

movl: MOVL REG CONST
	{
	instr2ry(opMOVL, $2, $3);
	printf("parser: MOVL %s %d\n",$2, $3);
	};


%%

int main (int argc, char *argv[]){
	int i=0;
	char temp[17], temp22[17];
	int temp1;
	int argv1_len = strlen(argv[1]);
	FILE *fp=fopen(argv[1],"r");	
	if (!fp){
		printf("Error opening the input file, code.txt");
		exit(0);		
	}
	else{
		yyin=fp;
		yyparse();
		fclose(fp);
	}

	unsigned short int temp2, temp3;
	for (i=0; i<2*cmd_counter-1; i+=2){
		struct pass_1 *s1, *s2 = NULL;
		HASH_FIND_INT(hashADDR, &i, s1);
		if(s1){
			//printf("vrethike ston hashADDR: %d %s\n", s1->addr, s1->label);
			HASH_FIND_STR( hashLABEL, s1->label, s2);
			if(s2){
				//printf("vrethike ston hashLABEL: %d %s\n", s1->addr, s1->label);
				temp2 = (unsigned short int)((s2->addr)/2);
				temp3 = temp2 >> 8;
				temp3 &= 0x000F;
				temp2 &= 0x00FF;
				instructions[i] += temp3;
				instructions[i+1] = temp2;			
			}else{
				printf("hash stage 2 error\n");
			}
		}else{
			printf("hash stage 1 error\n");		
		}		
	}
	struct pass_1 *s1=NULL;
	for (s1=hashADDR; s1!=NULL; s1=s1->hh.next){
		//HASH_FIND_INT(hashADDR, cmd_counter,s1);
		//if(s1) printf ("vrethike sto hashADDR h: %s\n", );
		printf("hashADDR: int: %d, label: %s\n", s1->addr, s1->label);
	}
	for (s1=hashLABEL; s1!=NULL; s1=s1->hh.next){
		//HASH_FIND_INT(hashADDR, cmd_counter,s1);
		//if(s1) printf ("vrethike sto hashADDR h: %s\n", );
		printf("hashLABEL: label: %s, addr: %d\n", s1->label, s1->addr);
	}


	/*int cmd_counter2=0;
	for (i=0; i<cmd_counter; i++){
		if (((instructions[2*i]>>4)&0x0F)==opBREQ){
			//xwse sta 3 delay slots prin kai sta 2 meta
		}
		else if ((instructions[2*i]>>4==opJMP)||
			 (instructions[2*i]>>4==opCALL)||
			 (instructions[2*i]>>4==opRET)){
			//xwse (???) sta 2 delay slots meta
		}
		else {
			instructions2[2*cmd_counter2]=instructions[2*i];
			instructions2[2*cmd_counter2+1]=instructions[2*i+1];
		}
			
	}*/




	argv[1][argv1_len]='\0';
	FILE *rom = fopen("InstructionMemory.vhd","w");
	fprintf(rom,"%s",strBefore);
	for (i=0; i<cmd_counter; i++){
		int j;
		temp[16]='\0';
		temp1=i;
		for(j=15;j>-1;j--){
			if(temp1%2==0){			
				temp[j]='0';
				temp1=temp1/2;
			}else{
				temp[j]='1';
				temp1=temp1/2;
			}
		}

		fprintf(rom, "when \"%s\" => data <= \"", temp);
		temp[16]='\0';
		temp1=(int)instructions[2*i];
		for(j=7;j>-1;j--){
			if(temp1%2==0){			
				temp[j]='0';
				temp1=temp1/2;
			}else{
				temp[j]='1';
				temp1=temp1/2;
			}

		}
		temp1=(int)instructions[2*i+1];
		for(j=15;j>7;j--){
			if(temp1%2==0){			
				temp[j]='0';
				temp1=temp1/2;
			}else{
				temp[j]='1';
				temp1=temp1/2;
			}

		}

		//temp22[16]='\0';
		//temp1=2*i+1;
		/*for(j=15;j>-1;j--){
			if(temp1%2==0){			
				temp22[j]='0';
				temp1=temp1/2;
			}else{
				temp22[j]='1';
				temp1=temp1/2;
			}
		}*/

		fprintf(rom, "%s\";\n", temp);
		/*temp1=(int)instructions[2*i+1];
		for(j=7;j>-1;j--){
			if(temp1%2==0){			
				temp[j]='0';
				temp1=temp1/2;
			}else{
				temp[j]='1';
				temp1=temp1/2;
			}

		}
		fprintf(rom, "%s\";\n", temp);
		*/		
		
	}
	fprintf(rom,"%s",strAfter);
	fclose(rom);

	
	for (i=0; i<cmd_counter; i++){
		//printf("cmd_counter=%d, i=%d",cmd_counter,i);	
		printf("%d:\tinstr[%d]=%x,\tinstr[%d]=%x\n", i, 2*i, instructions[2*i], 2*i+1, instructions[2*i+1]);
	}
	return 0;
}

int yyerror (char *str){
	printf("error: %s\n",str);
	return 0;
}

int yywrap (){
	return 1;
}

/*void wr_output(int pass, char out[]){
	
	file = fopen("/home/castonjofff/Desktop/rom.vhd","a+");
			
	fprintf(file,"%s",out);
	fclose(file);
}*/

void fill(char* label){
	struct pass_1 *s = NULL;
	s = malloc(sizeof(struct pass_1));
	int label_len = strlen(label);
	label[label_len-1]='\0';
	strcpy(s->label, label);
	s->addr = cmd_counter*2;
	HASH_ADD_STR(hashLABEL, label, s);
	//HASH_FIND_STR( hashLABEL, "auto:", s);
	//if (s) printf("\nHASHWORKS!:to auto exei value-address :P  %d :DDDD\n", s->addr);
} 

void addNop(int nops){
	int i;
	for(i=0;i<nops;i++){		
		instructions[cmd_counter*2] = 0;
		instructions[cmd_counter*2+1] = 0;
		cmd_counter++;
	}
}

void instr0(int op){
	instructions[cmd_counter*2] = op<<4;
	instructions[cmd_counter*2] &= 0xF0;
	instructions[cmd_counter*2+1]=0;
	cmd_counter++;
	addNop(2);
}

void instr1(int op, char* strAddr){
	struct pass_1 *s = NULL;
	s = malloc(sizeof(struct pass_1));
	strcpy(s->label, strAddr+1);
	s->addr = cmd_counter*2;
	HASH_ADD_INT(hashADDR, addr, s);

	instructions[cmd_counter*2] = op<<4;
	instructions[cmd_counter*2] &= 0xF0;
	instructions[cmd_counter*2+1] = 0;
	cmd_counter++;
	addNop(2);
}

void instr3rry(int op, char* r1, char* r2, int y){
	instructions[cmd_counter*2] = op<<4;
	instructions[cmd_counter*2] &= 0xF0;
	int temp1 = atoi(r1+1);
	int temp2;
	if (y<0)
		temp2 = atoi(r2+1)+1;
	else temp2 = atoi(r2+1);
	if (temp1<16 && temp2<16 && y<16){
		instructions[cmd_counter*2] += (unsigned char)temp1;
		instructions[cmd_counter*2+1] = (unsigned char)temp2<<4;
		instructions[cmd_counter*2+1] &= 0xF0;
		//instructions[cmd_counter*2+1] += ((unsigned char)int2twosCompl(16, y))&0x0F;
		instructions[cmd_counter*2+1] += (unsigned char)y; 
	}
	else {printf("Error: R0-R15 and Y<=255 must be used!"); exit(0);}
	cmd_counter++;
}

void instrBranch(char* r, int y){
	addNop(1);
	instructions[cmd_counter*2] = opBREQ<<4;
	instructions[cmd_counter*2] &= 0xF0;
	int temp = atoi(r+1);
	if (temp<16 && y<256){
		instructions[cmd_counter*2] += (unsigned char)temp;
		instructions[cmd_counter*2+1] = (unsigned char)y;
	}
	else {printf("Error: R0-R15 and Y<=255 must be used!"); exit(0);}
	cmd_counter++;
	addNop(2);
}

void instr2ry(int op, char* r, int y){
	instructions[cmd_counter*2] = op<<4;
	instructions[cmd_counter*2] &= 0xF0;
	int temp = atoi(r+1);
	if (temp<16 && y<256){
		instructions[cmd_counter*2] += (unsigned char)temp;
		//instructions[cmd_counter*2+1] = (unsigned char)int2twosCompl(256, y);
		instructions[cmd_counter*2+1] = (unsigned char)y;
		
	}
	else {printf("Error: R0-R15 and Y<=255 must be used!"); exit(0);}
	cmd_counter++;
}

void instr3rrr(int op, char* r1, char* r2, char* r3){
	instructions[cmd_counter*2] = op<<4;
	instructions[cmd_counter*2] &= 0xF0;
	int temp1 = atoi(r1+1);
	int temp2 = atoi(r2+1);
	int temp3 = atoi(r3+1);
	if (temp1<16 && temp2<16 && temp3<16){
		instructions[cmd_counter*2] += (unsigned char)temp1;
		instructions[cmd_counter*2+1] = (unsigned char)temp2<<4;
		instructions[cmd_counter*2+1] &= 0xF0;
		instructions[cmd_counter*2+1] += (unsigned char)temp3;
	}
	else {printf("Error: R0-R15 must be used!"); exit(0);}
	cmd_counter++;
}

void instr4rrdy(int op, char* r1, char* r2, int d, int y){
	instructions[cmd_counter*2] = op<<4;
	instructions[cmd_counter*2] &= 0xF0;
	int temp1 = atoi(r1+1);
	int temp2 = atoi(r2+1);
	if (temp1<16 && temp2<16 && y<8 && y>-1 && (d==0 || d==1)){
		instructions[cmd_counter*2] += (unsigned char)temp1;
		instructions[cmd_counter*2+1] = (unsigned char)temp2<<4;
		instructions[cmd_counter*2+1] &= 0xF0;
		if(d==1)
			instructions[cmd_counter*2+1] += (unsigned char)(8+y);
		else
			instructions[cmd_counter*2+1] += (unsigned char)y;
	}
	else {printf("Error: R0-R15, d=0 or d=1, y>=-3 and y<=3 must be used!"); exit(0);}
	cmd_counter++;
}

int int2twosCompl(int bits, int value){
	if (value>=0)
		return value;
	else return (bits+value);
}
