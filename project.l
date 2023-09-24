%option yylineno

%{
    #include<stdio.h>  
    #include<string.h> 
    #include"tree.h"
    #define YYSTYPE Node*
    #include"syntax.tab.h"
    int cnt = 0; 
    int lexError = 0;
    int yycolumn = 1;
    #define YY_User_Action \
    	yylloc.first_line = yylloc.last_line = yylineno; \
    	yylloc.first_column = yycolumn; \
    	yylloc.last_column = yycolumn + yyleng - 1; \
    	yycolumn = yycolumn + yyleng; \
%}

 // int类型
digit [0-9]
non_zero_digit [1-9]
int ({non_zero_digit}{digit}+)|{digit}

 // 八进制
oct "0"[0-7]+

 // 十六进制
hex_num [0-9a-fA-F]
hex "0"[xX]{hex_num}+

 // float类型
float {digit}+"."{digit}+
invalid_efloat "."[Ee][+-]?{digit}*
efloat {digit}*"."{digit}*[Ee][+-]?{digit}+

 // 标识符
id [a-zA-Z][a-zA-Z0-9_]*

 // 各种符号
semi ";"
comma ","
assignop "="
relop ">"|"<"|">="|"<="|"=="|"!="
plus "+"
minus "-"
dot "."
star "*"
div "/"
and "&&"
or "||"
not "!"
type "int"|"float"
lp "("
rp ")"
lb "["
rb "]"
lc "{"
rc "}"
struct "struct"
return "return"
if "if"
else "else"
while "while"
whitespace [' '\t]
line '\n'
line_annotation "//"
block_annotation "/*"

%%
{line} { yycolumn = 1; }

{line_annotation} {
    char ch = input();
    while(ch != '\n') {
        ch = input();
    }
}

{block_annotation} {
    char start = input();
    char end = input();
    while(start != '*' && end != '/') {
        start = end;
        end = input();
    }
}

{whitespace} { ; }

{semi} { 
    yylval = createNode("SEMI", enumLexOther, yylineno, 0, NULL);
    return SEMI; 
}

{comma} { 
    yylval = createNode("COMMA", enumLexOther, yylineno, 0, NULL);
    return COMMA; 
}

{assignop} { 
    yylval = createNode("ASSIGNOP", enumLexOther, yylineno, 0, NULL);
    return ASSIGNOP; 
}

{relop} { 
    yylval = craeteNode("RELOP", enumLexOther, yylineno, 0, NULL);
    return RELOP; 
}

{plus} { 
    yylval = createNode("PLUS", enumLexOther, yylineno, 0, NULL);
    return ADD; 
}

{minus} {
    yylval = createNode("MINUS", enumLexOther, yylineno, 0, NULL); 
    return SUB; 
}

{star} { 
    yylval = createNode("STAR", enumLexOther, yylineno, 0, NULL);
    return MUL; 
}

{dot} { 
    yylval = createNode("DOT", enumLexOther, yylineno, 0, NULL);
    return DOT; 
}

{div} { 
    yylval = createNode("DIV", enumLexOther, yylineno, 0, NULL);
    return DIV; 
}

{and} { 
    yylval = createNode("AND", enumLexOther, yylineno, 0, NULL);
    return AND; 
}

{or} { 
    yylval = createNode("OR", enumLexOther, yylineno, 0, NULL);
    return OR; 
}

{not} { 
    yylval = createNode("NOT", enumLexOther, yylineno, 0, NULL);
    return NOT; 
}

{type} { 
    yylval = createNode("TYPE", enumLexType, yylineno, 0, NULL);
    return TYPE; 
}

{lp} { 
    yylval = createNode("LP", enumLexOther, yylineno, 0, NULL);
    return LP; 
}

{rp} { 
    yylval = createNode("RP", enumLexOther, yylineno, 0, NULL);
    return RP; 
}

{lb} { 
    yylval = createNode("LB", enumLexOther, yylineno, 0, NULL);
    return LB; 
}

{rb} { 
    yylval = createNode("RB", enumLexOther, yylineno, 0, NULL);
    return RB; 
}

{lc} { 
    yylval = createNode("LC", enumLexOther, yylineno, 0, NULL);
    return LC; 
}

{rc} { 
    yylval = createNode("RC", enumLexOther, yylineno, 0, NULL);
    return RC; 
}

{struct} { 
    yylval = createNode("STRUCT", enumLexOther, yylineno, 0, NULL);
    return STRUCT; 
}

{return} { 
    yylval = createNode("RETURN", enumLexOther, yylineno, 0, NULL);
    return RETURN; 
}
 
{if} { 
    yylval = createNode("IF", enumLexOther, yylineno, 0, NULL);
    return IF; 
}

{else} { 
    yylval = createNode("ELSE", enumLexOther, yylineno, 0, NULL);
    return ELSE; 
}

{while} { 
    yylval = createNode("WHILE", enumLexOther, yylineno, 0, NULL);
    return WHILE; 
}

{id} { 
    yylval = createNode("ID", enumLexId, yylineno, 0, NULL);
    yylval->strVal = yytext;
    return ID;
}

{hex} { 
    yylval = createNode("INT", enumLexInt, yylineno, 0, NULL);
    yylval->intVal = hex2int(yytext);
    return INT;
}

{oct} { 
    yylval = createNode("INT", enumLexInt, yylineno, 0, NULL);
    yylval->intVal = oct2int(yytext);
    return INT;
}

{int} { 
    yylval = createNode("INT", enumLexInt, yylineno, 0, NULL);
    int a = string2int(yytext);
    // printf("int %d\n", a); 
    yylval->intVal = a;
    return INT;
}

. { 
    printf("Error type A at Line %d: Mysterious characters \"%s\"\n", yylineno, yytext); 
    lexError++; 
}

%%
int string2int(char* num) {
    int sum=0;
    for(int i=0; i<strlen(num); i++) {
        sum = sum*10 + num[i] - '0';
    }
    return sum;
}

int oct2int(char *num) {
    int sum = 0;
    for(int i=1; i<strlen(num); i++) {
        int tmp=0;
        if('0' <= num[i] && num[i] <= '7')
            tmp = num[i] - '0';
        sum = sum * 8 + tmp;
    }
    return sum;
}

int hex2int(char *num) {
    int sum = 0;
    for(int i=2; i<strlen(num); i++) {
        int tmp=0;
        if('0' <= num[i] && num[i] <= '9')
            tmp = num[i] - '0';
        else
        if('a' <= num[i] && num[i] <= 'f')
            tmp = num[i] - 'a' + 10;
        else
        if('A' <= num[i] && num[i] <= 'F')
            tmp = num[i] - 'F' + 10;
        sum = sum * 16 + tmp;
    }
    return sum;
}

int yywrap() {
    // indicate the end of the passage
    return 1;
}