#include<stdio.h>
#include "tree.h"

extern int yyrestart(FILE* f);
extern int yyparse();
extern Node* root;
extern void printTree(Node* root, int depth);
extern int lexError;
extern int synError;

int main(int argc, char** argv) {
    if(argc <= 1)
        return 1;
    FILE* f = fopen(argv[1], "r");
    if (!f) {
        perror(argv[1]);
        return 1;
    }
    yyrestart(f);
    yyparse();
    if(root != NULL && lexError == 0 && synError == 0)
        printTree(root, 0);
}