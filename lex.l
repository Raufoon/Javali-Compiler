%{
	#include "y.tab.h"
	#include <stdio.h>
	#include <string.h>
	#include <ctype.h>

	int parse(char* ytext);
%}

%%
if                          {return IF;}
else						{return ELSE;}
while 						{return WHILE;}
true						{yylval.str = strdup("1"); return BOOLEAN;}
false						{yylval.str = strdup("0"); return BOOLEAN;}
int 						{yylval.str = strdup("int"); return PTYPE;}
boolean 					{yylval.str = strdup("boolean"); return PTYPE;}
this 						{yylval.str = strdup("this"); return THIS;}
new 						{yylval.str = strdup("new"); return NEW;}
read 						{yylval.str = strdup("read"); return READ;}
write 						{yylval.str = strdup("write"); return WRITE;}
writeln 					{yylval.str = strdup("writeln"); return WRITELN;}
void 						{yylval.str = strdup("void"); return VOID;}
class 						{yylval.str = strdup("class"); return CLASS;}
extends 					{yylval.str = strdup("extends"); return EXTENDS;}
null 						{yylval.str = strdup("null"); return MNULL;}



0x[0-9a-fA-F][0-9a-fA-F]* 	{yylval.str = strdup(yytext);  return HEX;}
[0-9][0-9]* 				{yylval.str = strdup(yytext);  return INT;}
[A-Za-z][A-Za-z0-9]*  		{yylval.str = strdup(yytext);  return IDENT;}
[\n \t]+             		;
. 							{ return yytext[0]; }
%%
