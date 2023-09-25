%locations

%{
    #include<stdio.h>
    #include<stdarg.h>
    #include "lex.yy.c"
    Node* root = NULL;
    Node** package(int childNum, Node* child1, ...);
    void yyerror(char* msg);
    int synError = 0;   
%}

/* declare types */

%token SEMI COMMA ID TYPE INT FLOAT ASSIGNOP RELOP
%token IF WHILE ELSE STRUCT RETURN PLUS MINUS STAR DIV DOT AND OR NOT LP RP LB RB LC RC

%left LB RB LP RP DOT
%right NOT
%left PLUS MINUS STAR DIV RELOP AND OR
%right ASSIGNOP

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%
// High-level Definitions
Program : ExtDefList                            {
                                                    $$ = createNode("Program", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                    root = $$;
                                                }
    ;
ExtDefList : ExtDef ExtDefList                  {
                                                    $$ = createNode("ExtDefList", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    |                                           {
                                                    $$ = createNode("ExtDefList", enumSynNull, @$.first_line, 0, NULL);
                                                }
    ;
ExtDef : Specifier ExtDecList SEMI              {
                                                    $$ = createNode("ExtDef", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Specifier SEMI                            {
                                                    $$ = createNode("ExtDef", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    | Specifier FunDec CompSt                   {
                                                    $$ = createNode("ExtDef", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    ;
ExtDecList : VarDec                             {
                                                    $$ = createNode("ExtDecList", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | VarDec COMMA ExtDecList                   {
                                                    $$ = createNode("ExtDecList", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    ;

// Specifiers
Specifier : TYPE                                {
                                                    $$ = createNode("Specifier", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | StructSPecifier                           {
                                                    $$ = createNode("Specifier", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    ;

StructSPecifier : STRUCT OptTag LC DefList RC   {
                                                    $$ = createNode("StructSPecifier", enumSynNotNull, @$.first_line, 5, package(5, $1, $2, $3, $4, $5));
                                                }
    | STRUCT Tag                                {
                                                    $$ = createNode("StructSPecifier", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    ;

OptTag : ID                                     {
                                                    $$ = createNode("OptTag", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    |                                           {
                                                    $$ = createNode("OptTag", enumSynNull, @$.first_line, 0, NULL);
                                                }
    ;

Tag : ID                                        {
                                                    $$ = createNode("Tag", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    ;

// Declartors 
VarDec : ID                                     {
                                                    $$ = createNode("VarDec", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | VarDec LB INT RB                          {
                                                    $$ = createNode("VarDec", enumSynNotNull, @$.first_line, 4, package(4, $1, $2, $3, $4));
                                                }
    ;

FunDec : ID LP VarList RP                       {
                                                    $$ = createNode("FunDec", enumSynNotNull, @$.first_line, 4, package(4, $1, $2, $3, $4));
                                                }
    | ID LP RP                                  {
                                                    $$ = createNode("FunDec", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    ;

VarList : ParamDec COMMA VarList                {
                                                    $$ = createNode("VarList", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | ParamDec                                  {
                                                    $$ = createNode("VarList", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    ;

ParamDec : Specifier VarDec                     {
                                                    $$ = createNode("ParamDec", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    ;

// Local Definitions
DefList : Def DefList                           {
                                                    $$ = createNode("DefList", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    |                                           {
                                                    $$ = createNode("DefList", enumSynNull, @$.first_line, 0, NULL);
                                                }
    ;

Def : Specifier DecList SEMI                    {
                                                    $$ = createNode("Def", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    ;

DecList : Dec                                   {
                                                    $$ = createNode("DecList", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | Dec COMMA DecList                         {
                                                    $$ = createNode("DecList", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    ;

Dec : VarDec                                    {
                                                    $$ = createNode("Dec", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | VarDec ASSIGNOP Exp                       {
                                                    $$ = createNode("Dec", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    ;

// Expressions
Exp : Exp ASSIGNOP Exp                          {
    						    // printf("%s %s %s\n", $1, $2, $3);
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp AND Exp                               {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp OR Exp                                {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp RELOP Exp                             {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp PLUS Exp                              {
						    // printf("%s %s %s\n", $1, $2, $3);
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp MINUS Exp                             {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp STAR Exp                              {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp DIV Exp                               {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | LP Exp RP                                 {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | MINUS Exp                                 {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    | NOT Exp                                   {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    | ID LP Args RP                             {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 4, package(4, $1, $2, $3, $4));
                                                }
    | ID LP RP                                  {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp LB Exp RB                             {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 4, package(4, $1, $2, $3, $4));
                                                }
    | Exp DOT ID                                {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | ID                                        {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | INT                                       {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | FLOAT                                     {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    ;

Args : Exp COMMA Args                           {
                                                    $$ = createNode("Args", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp                                       {
                                                    $$ = createNode("Args", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    ;

// Statements
CompSt : LC DefList StmtList RC                 {
						    $$ = createNode("CompSt", enumSynNotNull, @$.first_line, 4, package(4, $1, $2, $3, $4));
						}
    ;

StmtList : Stmt StmtList                        {
	 					    Node** children = package(2, $1, $2);
                                                    $$ = createNode("StmtList", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                    for(int i=0; i<2; i++)
						        printf("%s\n", children[i] -> name);
						}
    |                                           {
                                                    $$ = createNode("StmtList", enumSynNull, @$.first_line, 0, NULL);
                                                }
    ;

Stmt : Exp SEMI                                 {
						    Node** children = package(2, $1, $2);
						    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                    for(int i=0; i<2; i++)
                                                        printf("%s\n", children[i] -> name);

						}
    | CompSt                                    {
                                                    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | RETURN Exp SEMI                           {
                                                    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | IF LP Exp RP Stmt  %prec LOWER_THAN_ELSE  {
						    Node** children = package(5, $1, $2, $3, $4, $5);
                                                    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 5, package(5, $1, $2, $3, $4, $5));
                                                    for(int i=0; i<5; i++)
						        printf("%s\n", children[i] -> name);
						}
    | IF LP Exp RP Stmt ELSE Stmt               {
                                                    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 7, package(7, $1, $2, $3, $4, $5, $6, $7));
                                                }
    | WHILE LP Exp RP Stmt                      {
                                                    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 5, package(5, $1, $2, $3, $4, $5));
                                                }
%%

Node** package(int childNum, Node* child1, ...) {
    va_list ap;
    va_start(ap, child1);
    Node** children = (Node**)malloc(sizeof(Node*) * childNum);
    children[0] = child1;
    for(int i=1; i<childNum; i++) 
        children[i] = va_arg(ap, Node*);
    return children;
}

void yyerror(char* msg) {
    synError++;
    fprintf(stderr, "Error type B at symbol %s at line %d: %s\n", yytext, yylineno, msg);
}   