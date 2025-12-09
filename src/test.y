%{
#include <stdio.h>
int yylex(void);
int yyerror(const char *s);
%}

%token NUMBER

%%

input:
    input NUMBER   { /* token handled in lexer */ }
  | /* empty */
  ;

%%

int main(void) {
    yyparse();
    return 0;
}

int yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    return 0;
}
