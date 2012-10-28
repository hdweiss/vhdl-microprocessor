lex lexer.l
bison -d parser.y
cc lex.yy.c parser.tab.c -o asm 

