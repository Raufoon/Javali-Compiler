%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define YYSTYPE char*
extern int lines;
int error=0;

YYSTYPE append(YYSTYPE s1, YYSTYPE s2)
{
	char s[10000];
	strcpy(s,"");
	
	strcat(s,s1);
	strcat(s,s2);
	return strdup(s);
}
extern YYSTYPE int2str(int x);
extern YYSTYPE makePacketFromTerminal(YYSTYPE terminal);

YYSTYPE makePacket(char code[],char attr[],char line_no[])
{
	char s[10000];
	strcpy(s,"");
	
	strcat(s,"<c>");
	strcat(s,code);
	strcat(s,"</c>");
	
	strcat(s,"<a>");
	strcat(s,attr);
	strcat(s,"</a>");
	
	strcat(s,"<l>");
	strcat(s,line_no);
	strcat(s,"</l>");
	
	return strdup(s);
}
YYSTYPE extractCodeFromPacket(YYSTYPE expr)
{
	char packet[10000];
	strcpy(packet,expr);
	
	char code[10000];
	strcpy(code,"");
	
	int i=3,j=0;
	while(i<strlen(packet))
	{
		if(packet[i]=='<'
			&& packet[i+1]=='/'
			&& packet[i+2]=='c'
			&& packet[i+3]=='>')
			{
				i+=4;
				break;
			}
		code[j]=packet[i];
		j++;
		i++;
	}code[j]='\0';
	return strdup(code);
}
YYSTYPE extractAttrFromPacket(YYSTYPE expr)
{
	char packet[10000];
	strcpy(packet,expr);
	
	char attr[100];
	strcpy(attr,"");
	
	int i=0,j=0;
	while(i<strlen(packet))
	{
		if(packet[i]=='<'
			&& packet[i+1]=='a'
			&& packet[i+2]=='>')
			{
				i+=3;
				break;
			}
			i++;
	}
	while(i<strlen(packet))
	{
		if(packet[i]=='<'
			&& packet[i+1]=='/'
			&& packet[i+2]=='a'
			&& packet[i+3]=='>')
			{
				i+=4;
				break;
			}
		attr[j]=packet[i];
		j++;
		i++;
	}attr[j]='\0';
	return strdup(attr);
}
YYSTYPE extractLineIdxFromPacket(YYSTYPE expr)
{
	char packet[10000];
	strcpy(packet,expr);
	
	char attr[100];
	strcpy(attr,"");
	
	int i=0,j=0;
	while(i<strlen(packet))
	{
		if(packet[i]=='<'
			&& packet[i+1]=='l'
			&& packet[i+2]=='>')
			{
				i+=3;
				break;
			}
			i++;
	}
	while(i<strlen(packet))
	{
		if(packet[i]=='<'
			&& packet[i+1]=='/'
			&& packet[i+2]=='l'
			&& packet[i+3]=='>')
			{
				i+=4;
				break;
			}
		attr[j]=packet[i];
		j++;
		i++;
	}attr[j]='\0';
	return strdup(attr);
}
int temp_count=0;
YYSTYPE newTemp()
{
	temp_count++;
	char s[100];
	itoa (temp_count,s,10);
	char s2[]="t";
	strcat(s2,s);
	return strdup(s2);
}
YYSTYPE onUnaryOp(char op[],YYSTYPE expr)
{
	char code[10000],attr[100];
	strcpy(code, extractCodeFromPacket(expr));
	strcpy(attr, extractAttrFromPacket(expr));
	
	char temp[100];
	strcpy(temp,newTemp());
	
	strcat(code,temp);
	strcat(code," = ");
	strcat(code,op);
	strcat(code,attr);
	strcat(code,"\n");
	
	return makePacket(code,temp,extractLineIdxFromPacket(expr));
}

YYSTYPE onBinaryOp(YYSTYPE expr1,YYSTYPE expr2,char op[])
{
	char code1[10000],attr1[100];
	strcpy(code1, extractCodeFromPacket(expr1));
	strcpy(attr1, extractAttrFromPacket(expr1));
	
	char code2[10000],attr2[100];
	strcpy(code2, extractCodeFromPacket(expr2));
	strcpy(attr2, extractAttrFromPacket(expr2));
	
	strcat(code1,code2);
	
	char temp[100];
	strcpy(temp,newTemp());
	
	strcat(code1,temp);
	strcat(code1," = ");
	strcat(code1,attr1);
	strcat(code1,op);
	strcat(code1,attr2);
	strcat(code1,"\n");
	
	
	return makePacket(code1,temp,extractLineIdxFromPacket(expr2));
}

YYSTYPE concatPackets(YYSTYPE packet1, YYSTYPE packet2)
{
	YYSTYPE attr1 = extractAttrFromPacket(packet1);
	YYSTYPE attr2 = extractAttrFromPacket(packet2);
	YYSTYPE attr = append(attr1,attr2);
	
	YYSTYPE code1 = extractCodeFromPacket(packet1);
	YYSTYPE code2 = extractCodeFromPacket(packet2);
	YYSTYPE code = append(code1,code2);
	
	
	return makePacket(code,attr,extractLineIdxFromPacket(packet2));
}
int label_count=0;
YYSTYPE newLabel()
{
	label_count++;
	char s[100];
	itoa (label_count,s,10);
	char s2[]="label_";
	strcat(s2,s);
	return strdup(s2);
}

void printerr(char msg[],YYSTYPE tok)
{
	YYSTYPE err_line = extractLineIdxFromPacket(tok);
	
	error++;
	
	printf("Error: %s line %s\n\n",msg, err_line);
	exit(0);
}
FILE *outfile;
int fileopened=0;
%}

%token ADD SUB MUL DIV AND OR MOD FACTORIAL
%token LCB RCB EQUAL SEMI LB RB EOL COMA L3B R3B DOT
%token EQUALITY INEQUALITY LESS LESSEQUALS GREATER GREATEREQUALS
%token IDENT DECIMAL HEXA
%token IF ELSE WHILE
%token BOOLEAN INT VOID
%token TRUE FALSE NULL_VAL
%token CLASS NEW EXTENDS THIS
%token READ WRITE WRITELN
%token NL

%left COMA

%%

Unit:
{
}
| 
ClassDecl Unit 
;

ClassDecl:
CLASS IDENT LCB DeclSeq RCB 
{
	if(!fileopened) 
	{
		outfile = fopen("output.txt","w");
		fileopened = 1;
	}

	YYSTYPE t1 = append(strdup("class "),extractAttrFromPacket($2));
	YYSTYPE t2 = append(t1,strdup(" {\n"));
	YYSTYPE t3 = append(t2,extractCodeFromPacket($4));
	YYSTYPE code = append(t3,strdup("}\n"));
	
	char classname[1000];
	strcpy(classname,"");
	strcat(classname,extractAttrFromPacket($2));
	
	fprintf(outfile,"%s\n",code);
	
	if(!strcmp(classname,"Main"))
	{
		exit(0);
	}
}
|
CLASS IDENT DeclSeq RCB 
{
	// error handling
	printerr("missing '{' at",$2);
}
|
CLASS IDENT LCB DeclSeq CLASS
{
	// error handling
	printerr("missing '}' before",$5);
}
;

DeclSeq:
{ $$=makePacket("","",int2str(lines)); }
|
DeclSeq VarDecl { $$=$1; }
|
DeclSeq MethodDecl 
{
$$ = concatPackets($1,$2);
}
;

VarDecl:
Type IdentList SEMI 
;

MethodBody:
LCB DeclSeq StmtList RCB
{
	$$ = $3;
}
;

MethodHeading:
VOID IDENT LB RB 
{
	char str[10000];
	strcpy(str,"void ");
	strcat(str,extractAttrFromPacket($2));
	strcat(str,"()\n");
	
	$$ = makePacket(str,"",extractLineIdxFromPacket($4));
}
|
VOID IDENT LB FormalParam RB
{
	char str[10000];
	strcpy(str,"void ");
	strcat(str,extractAttrFromPacket($2));
	strcat(str,"(");
	strcat(str,$4);
	strcat(str,")\n");
	
	$$ = makePacket(str,"",extractLineIdxFromPacket($4));
}
|
VOID LB RB 
{
	// error
	printerr("missing method name at",$1);
}
;

MethodDecl: 
MethodHeading MethodBody { $$ = concatPackets($1,$2);}
;

FormalParam:
Type IDENT 
{
	/*
	in this rule,i did not send any packet,
	*/
	YYSTYPE t1 = extractAttrFromPacket($1);
	YYSTYPE t2 = append(t1,strdup(" "));
	$$ = append(t2,extractAttrFromPacket($2));
}
|
Type IDENT COMA FormalParam
{
	YYSTYPE t1 = extractAttrFromPacket($1);
	YYSTYPE t2 = append(t1,strdup(" "));
	YYSTYPE t3 = append(t2,extractAttrFromPacket($2));
	YYSTYPE t4 = append(t3,strdup(","));
	$$ = append(t4,$4);
}
;



IdentList:
IDENT
| IDENT COMA IdentList
;

StmtBlock:  LCB StmtList RCB {$$=$2;}
;

StmtList:
{$$=strdup("");}
| 
Stmt StmtList 
{
YYSTYPE code=append(extractCodeFromPacket($1),extractCodeFromPacket($2));
char str[10000];
strcpy(str,"");strcat(str,code);
$$ = makePacket(str,"",extractLineIdxFromPacket($2));
}
;

Stmt: Assignment {$$=$1;}
| IfStmt  {$$=$1;}
| WhileStmt  {$$=$1;}
| MethodCall {$$=$1;}
;

IfStmt: IF LB Expr RB StmtBlock
{
char code[10000]; 
strcpy(code,""); 
strcat(code,extractCodeFromPacket($3));

YYSTYPE label_true = newLabel();
YYSTYPE label_out = newLabel();

strcat(code,"if ");
strcat(code,extractAttrFromPacket($3));
strcat(code," == true ");
strcat(code,"goto ");
strcat(code,label_true);
strcat(code,"\n");

strcat(code,"goto ");
strcat(code,label_out);
strcat(code,"\n");

strcat(code,label_true);
strcat(code,":\n");
strcat(code,extractCodeFromPacket($5));

strcat(code,label_out);
strcat(code,":\n");

$$ = makePacket(code,"",extractLineIdxFromPacket($5));
}
| 
IF LB Expr RB StmtBlock ELSE StmtBlock 
{
char code[10000]; 
strcpy(code,""); 
strcat(code,extractCodeFromPacket($3));

YYSTYPE label_true = newLabel();
YYSTYPE label_out = newLabel();

strcat(code,"if ");
strcat(code,extractAttrFromPacket($3));
strcat(code," == true ");
strcat(code,"goto ");
strcat(code,label_true);
strcat(code,"\n");

strcat(code,extractCodeFromPacket($7));

strcat(code,"goto ");
strcat(code,label_out);
strcat(code,"\n");

strcat(code,label_true);
strcat(code,":\n");
strcat(code,extractCodeFromPacket($5));

strcat(code,label_out);
strcat(code,":\n");

$$ = makePacket(code,"",extractLineIdxFromPacket($7));
}
;

WhileStmt: WHILE LB Expr RB StmtBlock 
{
YYSTYPE label_loop = newLabel();
YYSTYPE label_out = newLabel();

char code[10000];
strcpy(code,"");
strcat(code,label_loop);
strcat(code,":\n");
strcat(code,extractCodeFromPacket($3));

strcat(code,"if ");
strcat(code,extractAttrFromPacket($3));
strcat(code," == false");
strcat(code," goto ");
strcat(code,label_out);
strcat(code,"\n");

strcat(code,extractCodeFromPacket($5));

strcat(code,"goto ");
strcat(code,label_loop);
strcat(code,"\n");
strcat(code,label_out);
strcat(code,":\n");

$$ = makePacket(code,"",extractLineIdxFromPacket($5));
}
;

ActualParam:
Expr 
{
	char code[10000]; strcpy(code,""); strcat(code,extractCodeFromPacket($1));
	char attr[1000]; strcpy(attr,"param "); strcat(attr,extractAttrFromPacket($1)); strcat(attr,"\n");
	$$ = makePacket(code,attr,extractLineIdxFromPacket($1));
}
| 
Expr COMA ActualParam
{
	YYSTYPE code = append(extractCodeFromPacket($1),extractCodeFromPacket($3));
	
	YYSTYPE t1 = append(strdup("param "),extractAttrFromPacket($1));
	YYSTYPE t2 = append(t1, strdup("\n"));
	YYSTYPE t3 = append(t2, extractAttrFromPacket($3));
	
	char str[1000];
	strcpy(str,"");
	strcat(str,t3);
	$$ = makePacket(code,str,extractLineIdxFromPacket($3));
}
;

MethodCall:
IdentAccess LB ActualParam RB SEMI
{
	char code[10000];
	strcpy(code,"");
	strcat(code,extractCodeFromPacket($1));
	strcat(code,extractCodeFromPacket($3));
	strcat(code,extractAttrFromPacket($3));
	strcat(code,"call ");
	strcat(code,extractAttrFromPacket($1));
	strcat(code,"\n");
	$$ = makePacket(code,"",extractLineIdxFromPacket($5));
}
| IdentAccess LB RB SEMI
{
	char code[10000];
	strcpy(code,"");
	strcat(code,extractCodeFromPacket($1));
	strcat(code,"call ");
	strcat(code,extractAttrFromPacket($1));
	strcat(code,"\n");
	
	$$ = makePacket(code,"",extractLineIdxFromPacket($4));
}
| WRITE LB ActualParam RB SEMI
{
	YYSTYPE code = append(extractCodeFromPacket($3),extractAttrFromPacket($3));
	char str[10000]; strcpy(str,""); strcat(str,code);strcat(str,"call write\n");
	$$ = makePacket(str,"",extractLineIdxFromPacket($5));
}
| WRITE LB RB SEMI {$$=makePacket("call write\n","",extractLineIdxFromPacket($4));}
| WRITELN LB ActualParam RB SEMI  
{
	YYSTYPE code = append(extractCodeFromPacket($3),extractAttrFromPacket($3));
	char str[10000]; strcpy(str,""); strcat(str,code);strcat(str,"call writeln\n");
	$$ = makePacket(str,"",extractLineIdxFromPacket($5));
}
| WRITELN LB RB SEMI {$$=makePacket("call writeln\n","",extractLineIdxFromPacket($4));}
;

Assignment: 
IdentAccess EQUAL Expr SEMI 
{
char code[10000],attr[100];
strcpy(code,"");
strcat(code , extractCodeFromPacket($1));
strcat(code , extractCodeFromPacket($3));
strcpy(attr, extractAttrFromPacket($3));

char var[100];
strcpy(var,extractAttrFromPacket($1));

strcat(code,var);
strcat(code," = ");
strcat(code,attr);
strcat(code,"\n");

$$ = makePacket(code,var,extractLineIdxFromPacket($4));

}
| IdentAccess EQUAL NEW QualifiedType SEMI
{
char code[10000], var[1000];
strcpy(code,"");
strcat(code,extractCodeFromPacket($1));
strcat(code,extractCodeFromPacket($4));
strcpy(var,"");
strcat(var,extractAttrFromPacket($1));
strcat(code,var);
strcat(code," = new ");
strcat(code,extractAttrFromPacket($4));
strcat(code,"\n");

$$ = makePacket(code,var,extractLineIdxFromPacket($5));
}
| IdentAccess EQUAL READ LB RB SEMI
{
char code[10000], var[1000];
strcpy(code,"");
strcat(code,extractCodeFromPacket($1));
strcpy(var,"");
strcat(var,extractAttrFromPacket($1));
strcat(code,var);
strcat(code," = read()");
strcat(code,"\n");

$$ = makePacket(code,var,extractLineIdxFromPacket($6));
}
;



IdentAccess:
IDENT SelectorSeq 
{
	$$= concatPackets($1,$2);
}
| THIS SelectorSeq
{
	$$= concatPackets($1,$2);
}
;


Expr: SimpleExpr  {$$=$1;}
| SimpleExpr EQUALITY SimpleExpr   {$$=onBinaryOp($1,$3,"==");}
| SimpleExpr INEQUALITY SimpleExpr  {$$=onBinaryOp($1,$3,"!=");}
| SimpleExpr GREATER SimpleExpr   {$$=onBinaryOp($1,$3,">");}
| SimpleExpr GREATEREQUALS SimpleExpr  {$$=onBinaryOp($1,$3,">=");}
| SimpleExpr LESS SimpleExpr  {$$=onBinaryOp($1,$3,"<");}
| SimpleExpr LESSEQUALS SimpleExpr  {$$=onBinaryOp($1,$3,"<=");}

;

SimpleExpr: Term {$$=$1;}
| SimpleExpr ADD Term  {$$=onBinaryOp($1,$3,"+");}
| SimpleExpr SUB Term  {$$=onBinaryOp($1,$3,"-");}
| SimpleExpr OR Term {$$=onBinaryOp($1,$3,"||");}  
;

Term: Factor {$$=$1;}
| Term MUL Factor {$$=onBinaryOp($1,$3,"*");}
| Term DIV Factor {$$=onBinaryOp($1,$3,"/");}
| Term AND Factor {$$=onBinaryOp($1,$3,"&&");}
| Term MOD Factor {$$=onBinaryOp($1,$3,"%");}
;

RefType:
IDENT
{
	$$ = $1;
}
| IDENT L3B R3B
{
	char s[]="";
	strcat(s,extractAttrFromPacket($1));
	strcat(s,"[");
	strcat(s,"]");
	$$ = makePacketFromTerminal(strdup(s));
}
| INT L3B R3B
{
	$$ = makePacketFromTerminal("int[]");
}
| BOOLEAN L3B R3B
{
	$$ = makePacketFromTerminal("boolean[]");
}
; 

Factor: NoSignFactor {$$=$1;}
| SUB NoSignFactor {$$ = onUnaryOp("-",$2);}
;

NoSignFactor: IdentAccess { $$=$1; }
| Integer { $$=$1; }
| Boolean { $$=$1; }
| LB Expr RB { $$=$2; }
| FACTORIAL Factor  {$$ = onUnaryOp("!",$2);}
| LB RefType RB NoSignFactor 
{
	char s[]="(";
	strcat(s,extractAttrFromPacket($2));
	strcat(s,")");
	strcat(s,extractAttrFromPacket($4));
	printf("%s",s);
	YYSTYPE var = newTemp();
	
	char c[]="";
	strcat(c,extractCodeFromPacket($4));
	strcat(c,var);
	strcat(c," = ");
	strcat(c,s);
	strcat(c,"\n");
	/*
	$$ = makePacket(c,var,extractLineIdxFromPacket($1));
	*/
}
| NULL_VAL { $$=$1; }
;

ElemSelector:
L3B SimpleExpr R3B
{
	YYSTYPE code = extractCodeFromPacket($2);
	YYSTYPE tmp1 = extractAttrFromPacket($2);
	YYSTYPE tmp2 = append(strdup("["),tmp1);
	YYSTYPE attr = append(tmp2,strdup("]"));
	$$= makePacket(code,attr,extractLineIdxFromPacket($3));
	
}
;

FieldSelector:
DOT IDENT 
{
	YYSTYPE attr = append( strdup("."), strdup(extractAttrFromPacket($2))) ;
	$$ = makePacketFromTerminal(attr);
	
}
|
DOT SEMI
{
	// error
	printerr("missing field at",$1);
}
|
DOT DOT
{
	// error
	printerr("missing field at",$1);
}
;

SelectorSeq:
{
	$$=makePacket(strdup(""),strdup(""),int2str(lines));
}
| FieldSelector SelectorSeq
{
	$$= concatPackets($1,$2);
}
| ElemSelector SelectorSeq
{
	$$= concatPackets($1,$2);
}
;

QualifiedType:
IDENT LB RB 
{
	YYSTYPE attr = append ( extractAttrFromPacket($1), strdup("()") );
	$$ = makePacketFromTerminal(attr);
}
| IDENT ElemSelector
{
	$$ = concatPackets($1,$2);
}
| PrimitiveType ElemSelector
{
	$$ = concatPackets($1,$2);
}
|
IDENT RB 
{
	// error
	printerr("missing '(' at",$2);
}
;

ArrayType:
IDENT L3B R3B
{
	YYSTYPE brack=strdup("[]");
	YYSTYPE attr = append(extractAttrFromPacket($1) , brack );
	char sa[]="";
	strcat(sa,attr);
	char sb[]="";
	strcat(sb,extractLineIdxFromPacket($3));
	$$ = makePacket("",sa,sb);
}
| 
PrimitiveType L3B R3B
{
	YYSTYPE brack=strdup("[]");
	YYSTYPE attr = append(extractAttrFromPacket($1) , brack );
	char sa[]="";
	strcat(sa,attr);
	char sb[]="";
	strcat(sb,extractLineIdxFromPacket($3));
	$$ = makePacket("",sa,sb);
}
| 
PrimitiveType R3B
{
	// error
	printerr("missing [ at",$2);
}
|
IDENT R3B
{
	// error
	printerr("missing [ at",$2);
}

;

Type:
PrimitiveType {$$=$1;}
| IDENT {$$=$1;}
| ArrayType {$$=$1;}
;

PrimitiveType:
INT {$$=$1;}
| BOOLEAN {$$=$1;}
;

Boolean:
TRUE {$$=$1;}
| FALSE {$$=$1;}
;

Integer: DECIMAL  {$$=$1; }
| HEXA { $$=$1; }
;
