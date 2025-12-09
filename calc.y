%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Symbol table: a–z, A–Z */
int symbol_table[52];
int temp_count = 0;

FILE *tac_file = NULL;

typedef struct {
    char result[20];
    char op1[20];
    char op[10];
    char op2[20];
} TAC_Instruction;

TAC_Instruction tac[200];
int tac_index = 0;

int get_symbol_index(char id);
void yyerror(const char *s);
int yylex(void);
extern int lineno;

char *new_temp();
void emit_tac(const char *res, const char *op1, const char *op, const char *op2);
void print_tac();
%}

%union {
    int num;        /* numeric value */
    char id;        /* identifier letter */
    char temp[20];  /* name holding this expression (var or temp) */
}

%token <num> NUM
%token <id> ID
%token PRINT TRUE FALSE
%token PLUS MINUS TIMES DIVIDE MOD
%token ASSIGN EQ NEQ LT GT LTE GTE
%token LPAREN RPAREN SEMI

%type <temp> condition
%type <temp> expr term factor

%%

program:
      /* empty */
    | program line
    ;

line:
      assignment SEMI
    | PRINT expr SEMI
      {
          emit_tac("Cprint", $2, "", "");
      }
    | PRINT condition SEMI
      {
          emit_tac("Cprint", $2, "", "");
      }
    ;

assignment:
      ID ASSIGN expr
      {
          /* assign runtime value using symbol_table just like before is omitted here;
             we focus on TAC generation mapping ID := expr_temp */
          char res[2];
          res[0] = $1;
          res[1] = '\0';
          emit_tac(res, $3, ":=", "");
      }
    | ID ASSIGN condition
      {
          char res[2];
          res[0] = $1;
          res[1] = '\0';
          emit_tac(res, $3, ":=", "");
      }
    ;

expr:
      term
      {
          strcpy($$, $1);
      }
    | expr PLUS term
      {
          char *t = new_temp();
          emit_tac(t, $1, "+", $3);
          strcpy($$, t);
      }
    | expr MINUS term
      {
          char *t = new_temp();
          emit_tac(t, $1, "-", $3);
          strcpy($$, t);
      }
    ;

term:
      factor
      {
          strcpy($$, $1);
      }
    | term TIMES factor
      {
          char *t = new_temp();
          emit_tac(t, $1, "*", $3);
          strcpy($$, t);
      }
    | term DIVIDE factor
      {
          char *t = new_temp();
          emit_tac(t, $1, "/", $3);
          strcpy($$, t);
      }
    | term MOD factor
      {
          char *t = new_temp();
          emit_tac(t, $1, "%", $3);
          strcpy($$, t);
      }
    ;

factor:
      NUM
      {
          sprintf($$, "%d", $1);   /* literal number as string */
      }
    | ID
      {
          $$[0] = $1;      /* first char = variable name */
          $$[1] = '\0';    /* null-terminate string */
      }
    | LPAREN expr RPAREN
      {
          strcpy($$, $2);
      }
    ;

condition:
      expr EQ expr
      {
          char *t = new_temp();
          emit_tac(t, $1, "==", $3);
          strcpy($$, t);
      }
    | expr NEQ expr
      {
          char *t = new_temp();
          emit_tac(t, $1, "!=", $3);
          strcpy($$, t);
      }
    | expr LT expr
      {
          char *t = new_temp();
          emit_tac(t, $1, "<", $3);
          strcpy($$, t);
      }
    | expr GT expr
      {
          char *t = new_temp();
          emit_tac(t, $1, ">", $3);
          strcpy($$, t);
      }
    | expr LTE expr
      {
          char *t = new_temp();
          emit_tac(t, $1, "<=", $3);
          strcpy($$, t);
      }
    | expr GTE expr
      {
          char *t = new_temp();
          emit_tac(t, $1, ">=", $3);
          strcpy($$, t);
      }
    | TRUE
      {
          sprintf($$, "1");
      }
    | FALSE
      {
          sprintf($$, "0");
      }
    ;

%%

int get_symbol_index(char id) {
    if (id >= 'a' && id <= 'z') return id - 'a';
    if (id >= 'A' && id <= 'Z') return 26 + (id - 'A');
    return -1;
}

char *new_temp() {
    static char buf[20];
    sprintf(buf, "_t%d", temp_count++);
    return buf;
}

void emit_tac(const char *res, const char *op1, const char *op, const char *op2) {
    strcpy(tac[tac_index].result, res);
    strcpy(tac[tac_index].op1, op1);
    strcpy(tac[tac_index].op, op);
    strcpy(tac[tac_index].op2, op2);
    tac_index++;
}

void print_tac() {
    tac_file = fopen("output\\program.txt", "w");
    if (!tac_file) {
        fprintf(stderr, "Error opening output/program.txt\n");
        return;
    }

    for (int i = 0; i < tac_index; i++) {
        if (strcmp(tac[i].result, "Cprint") == 0) {
            fprintf(tac_file, "Cprint %s\n", tac[i].op1);
        } else if (strcmp(tac[i].op, ":=") == 0 && strlen(tac[i].op2) == 0) {
            fprintf(tac_file, "%s := %s\n", tac[i].result, tac[i].op1);
        } else {
            fprintf(tac_file, "%s := %s %s %s\n",
                    tac[i].result,
                    tac[i].op1,
                    tac[i].op,
                    tac[i].op2);
        }
    }

    fclose(tac_file);
}

void yyerror(const char *s) {
    fprintf(stderr, "Parse error at line %d: %s\n", lineno, s);
}

int main(void) {
    for (int i = 0; i < 52; i++) symbol_table[i] = 0;
    int r = yyparse();
    print_tac();
    return r;
}
