%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define YYSTYPE char*
extern YYSTYPE yylval;

#include "y.tab.h"
int lines=1;

YYSTYPE int2str(int x)
{
	char s[100];
	itoa (x,s,10);
	char s2[]="";
	strcat(s2,s);
	return strdup(s2);
}

YYSTYPE makePacketFromTerminal(YYSTYPE terminal)
{
	char s[10000];
	strcpy(s,"");
	
	strcat(s,"<c>");
	strcat(s,"</c>");
	
	strcat(s,"<a>");
	strcat(s,terminal);
	strcat(s,"</a>");
	
	strcat(s,"<l>");
	strcat(s,int2str(lines));
	strcat(s,"</l>");
	
	return strdup(s);
}

%}

%%

"boolean" { yylval=makePacketFromTerminal("boolean"); return BOOLEAN;}
"class" { yylval=makePacketFromTerminal("class"); return CLASS;}
"else" { yylval=makePacketFromTerminal("else"); return ELSE;}
"extends" { yylval=makePacketFromTerminal("extends"); return EXTENDS;}
"false" { yylval=makePacketFromTerminal("false"); return FALSE;}
"if" { yylval=makePacketFromTerminal("if"); return IF;}
"int" { yylval=makePacketFromTerminal("int"); return INT;}
"new" { yylval=makePacketFromTerminal("new"); return NEW;}
"null" { yylval=makePacketFromTerminal("null"); return NULL_VAL;}
"read" { yylval=makePacketFromTerminal("read"); return READ;}
"true" { yylval=makePacketFromTerminal("true"); return TRUE;}
"this" { yylval=makePacketFromTerminal("this"); return THIS;}
"void" { yylval=makePacketFromTerminal("void"); return VOID;}
"while" { yylval=makePacketFromTerminal("while"); return WHILE;}
"writeln" { yylval=makePacketFromTerminal("writeln"); return WRITELN;}
"write" { yylval=makePacketFromTerminal("write"); return WRITE;}


"+" { yylval=makePacketFromTerminal("+"); return ADD;}
"-" { yylval=makePacketFromTerminal("-"); return SUB;}
"%" { yylval=makePacketFromTerminal("%"); return MOD;}
"*" {  yylval=makePacketFromTerminal("*"); return MUL;}
"/" { yylval=makePacketFromTerminal("/");  return DIV;}

[0-9]+ { yylval=makePacketFromTerminal(strdup(yytext)); return DECIMAL;}
"0x"[0-9a-fA-F]+  {yylval=makePacketFromTerminal(strdup(yytext));return HEXA;}
[A-Za-z][0-9a-zA-Z]* {yylval=makePacketFromTerminal(strdup(yytext));return IDENT; }

\n { lines++;}
[ \t] {}

"&&" {yylval=makePacketFromTerminal("&&");return AND;}
"||" {yylval=makePacketFromTerminal("||");return OR;}
"==" {yylval=makePacketFromTerminal("==");return EQUALITY;}
"!=" {yylval=makePacketFromTerminal("!=");return INEQUALITY;}
">=" {yylval=makePacketFromTerminal(">=");return GREATEREQUALS;}
">" {yylval=makePacketFromTerminal(">");return GREATER;}
"<=" {yylval=makePacketFromTerminal("<=");return LESSEQUALS;}
"<" {yylval=makePacketFromTerminal("<");return LESS;}

"!" {yylval=makePacketFromTerminal("!");return FACTORIAL;}
"." {yylval=makePacketFromTerminal(".");return DOT;}

"," {yylval=makePacketFromTerminal(",");return COMA;}
"{" {yylval=makePacketFromTerminal("{");return LCB;}
"}" {yylval=makePacketFromTerminal("}");return RCB;}
"(" {yylval=makePacketFromTerminal("(");return LB;}
")" {yylval=makePacketFromTerminal(")");return RB;}
"[" {yylval=makePacketFromTerminal("[");return L3B;}
"]" {yylval=makePacketFromTerminal("]");return R3B;}
"=" {yylval=makePacketFromTerminal("=");return EQUAL;}
";" {yylval=makePacketFromTerminal(";");return SEMI;}

. { }
%%

int main()
{
	freopen("input.txt", "r+", stdin);
   yyparse();   
   
   return 0;
}

int yywrap(void)
{
   return 0;
}

int yyerror (const char *s)
{                                                     
    printf("%s\n ",s);
    return 0;
}

