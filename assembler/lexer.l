%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"
%}

%%
NOP {
	yylval.strval=strdup(yytext);
	printf("lexer: NOP\n");	
	return NOP;
}
LD {
	yylval.strval=strdup(yytext);
	printf("lexer: LD\n");	
	return LD;
}
ST {
	yylval.strval=strdup(yytext);
	printf("lexer: ST\n");	
	return ST;
}
SF {
	yylval.strval=strdup(yytext);
	printf("lexer: SF\n");	
	return LD;
}
ADDR {
	yylval.strval=strdup(yytext);
	printf("lexer: ADDR\n"); 
	return ADDR;
}
AND {
	yylval.strval=strdup(yytext);
	printf("lexer: AND\n"); 
	return AND;
}
OR {
	yylval.strval=strdup(yytext);
	printf("lexer: OR\n"); 
	return OR;
}
XOR {
	yylval.strval=strdup(yytext);
	printf("lexer: XOR\n"); 
	return XOR;
}
SUB {
	yylval.strval=strdup(yytext);
	printf("lexer: SUB\n"); 
	return SUB;
}
BREQ {
	printf("lexer: BREQ\n"); 
	return BREQ;
}
ADDI {
	printf("lexer: ADDI\n"); 
	return ADDI;
}
MOVH {
	yylval.strval=strdup(yytext);
	printf("lexer: MOVH\n"); 
	return MOVH;
}
MOVL {
	yylval.strval=strdup(yytext);
	printf("lexer: MOVL\n"); 
	return MOVL;
}
JMP {
	printf("lexer: JMP\n"); 
	return JMP;
}
CALL {
	printf("lexer: CALL\n"); 
	yylval.strval=strdup(yytext);
	return CALL;
}
RET {
	printf("lexer: RET\n"); 
	yylval.strval=strdup(yytext);
	return RET;
}
[A-Za-z0-9]+":" {
	yylval.strval=strdup(yytext);
	printf("lexer: Label\n");
	return LABEL;
}
"$"[A-Za-z1-9]+ {

	yylval.strval=strdup(yytext);
	printf("lexer: Address\n"); 
	return ADDRESS;
}
R[0-9]+ {
	yylval.strval=strdup(yytext);
	printf("lexer: Register\n"); 
	return REG;
}
[+-]*[0-9]+ {
	yylval.intval=atoi(yytext); 
	printf("lexer: Constant\n"); 
	return CONST;
}
\n ;
[ \t]]+ ; 
%%


