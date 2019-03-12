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

%left tEQUAL
%left tOR
%left tAND
%left tPLUS tMINUS tMOD
%left tSTAR tDIV
%left tCROO tCROF tPARO tPARF

%%

S : Fonctions;

Fonctions : Fonction Fonctions | Fonction;

Fonction : Type tID tPARO Args tPARF Body;

Type : tINT | tCONST tINT | tVOID | tCHAR | tCONST tCHAR;

Body : tACCO Instrs tACCF;

End : tSEMI;

TypedDefNext : End | tCOMMA TypedDef;

TypedDef : tID TypedDefNext | tID tEQUAL Exp TypedDefNext

Instrs : Instr Instrs | /* epsilon */;

Instr : Def | Aff | If | While;

Args : | ArgsList;

ArgsList : Arg | ArgsList tCOMMA Arg;

Arg : Type | Type tID;

Def : Type TypedDef;


Exp : tID
    | tNBR
    | tTRUE
    | tFALSE
    | tSTAR Exp
    /*| Exp tCROO Exp tCROF*/
    | tID tPARO Args tPARF
    | tPRINTF tPARO Exp tPARF
    | Exp tEQUAL Exp
    | Exp tPLUS Exp
    | Exp tMINUS Exp
    | Exp tSTAR Exp
    | Exp tDIV Exp
    | Exp tMOD Exp
    | tNOT Exp
    | Exp tAND Exp
    | Exp tOR Exp;

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
