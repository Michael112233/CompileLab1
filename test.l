%{
    #include<stdio.h>    
%}

delim [\t\n]
whitespace [delim]+
digit [0-9]
letter [a-zA-Z_]
id {letter}({letter}|{digit})*

%%
{whitespace} {;}
{id} {printf("(ID, %s)\n", yytext);}
. {printf("missing character %s\n", yytext);}

%%
int yywrap() {
    // indicate the end of the passage
    return 1;
}

int main(int argc, char** argv) {
    if(argc > 1) {
        if(!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }
    while(yylex() != 0);
    return 0;
}