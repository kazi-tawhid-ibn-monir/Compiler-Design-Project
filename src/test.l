%{
#include "y.tab.h"
%}

%%

[0-9]+      { printf("number: %s\n", yytext); return NUMBER; }
[ \t\n]+    { /* skip whitespace */ }
.           { return yytext[0]; }

%%

int yywrap(void) { return 1; }
