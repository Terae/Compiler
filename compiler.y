%{
    #include <stdio.h>

    void yyerror(const char*);
    int yylex(void);
%}

%token tMAIN tPRINTF
%token tCONST tINT tVOID tCHAR tENUM
%token tIF tELSE tSWITCH tCASE tDEFAULT tFOR tWHILE tDO tBREAK tCONTINUE
%token tAND tOR tTRUE tFALSE
%token tACCO tACCF tPARO tPARF
%token tPLUS tMINUS tDIV tSTAR tMOD tEQUAL tSEMI tCOMMA tNOT
%token tID tNBR

%start S

%%

S : Fonctions;

Fonctions : Fonction Fonctions | Fonction;

Fonction : Type tID tPARO Args tPARF Body;

Type : tINT | tCONST tINT | tVOID;

Body : tACCO Instrs tACCF;

Instrs : Instr Instrs | /* epsilon */;

Instr : Dec | Aff | If | While;

Args : | ArgsList;

ArgsList : Arg | ArgsList tCOMMA Arg;

Arg : Type tID;

Dec : Type tID tSEMI;

Exp : /* TODO */;
Aff : tID tEQUAL Exp tSEMI;

If : tIF tPARO Exp tPARF Body;

While : tWHILE tPARO Exp tPARF Body;

%%

void yyerror(const char* msg) {
    printf("ERROR: %s\n", msg);
}

int main(int argc, char const **argv) {
    yyparse();

    return 0;
}
