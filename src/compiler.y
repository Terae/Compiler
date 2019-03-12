%{
    #include <stdio.h>

    void yyerror(const char*);
    int yylex(void);

    int implementation_enabled = 1;
%}

%token tMAIN tPRINTF
%token tCONST tINT tVOID tCHAR tENUM
%token tIF tELSE tSWITCH tCASE tDEFAULT tFOR tWHILE tDO tBREAK tCONTINUE
%token tAND tOR tTRUE tFALSE
%token tACCO tACCF tPARO tPARF tCROO tCROF
%token tPLUS tMINUS tDIV tSTAR tMOD tEQUAL tSEMI tCOMMA tNOT tINC tDEC
%token tID tNBR

%start S

%left tEQUAL
%left tOR
%left tAND
%left tPLUS tMINUS
%left tSTAR tDIV tMOD
%right tNOT
%left tCROO tCROF tPARO tPARF

%%

S : Fonctions;

Fonctions : Fonction Fonctions | Fonction;

Type : tINT | tCONST tINT | tVOID | tCHAR | tCONST tCHAR;

Fonction : Type tID tPARO TypedArgs tPARF FunctionBody | Type tID tPARO TypedArgs tPARF End;

FunctionBody : tACCO { if(implementation_enabled == 0) { yyerror("parameter name ommitted"); } } Instrs tACCF;

Body : tACCO Instrs tACCF;

End : tSEMI;

TypedDefNext : End | tCOMMA TypedDef;

TypedDef : tID TypedDefNext | tID tEQUAL Exp TypedDefNext

Def : Type TypedDef;

TypedArgs : { implementation_enabled = 1; } | TypedArgsNamedList { implementation_enabled = 1; } | TypedArgsUnnamedList { implementation_enabled = 0; };

// int a, char c, ...
// Left recursion is better than right recursion for memory management (not so much 'shift' before reduce-ing)
TypedArgsNamedList : TypedArgNamed | TypedArgsNamedList tCOMMA TypedArgNamed;

TypedArgNamed : Type tID;

// int, char, ...
TypedArgsUnnamedList : TypedArgUnnamed | TypedArgsUnnamedList tCOMMA TypedArgUnnamed;

TypedArgUnnamed : Type;

// toto, a, ...
Args : | ArgsList;

ArgsList : Arg | ArgsList tCOMMA Arg;

Arg : Exp;

Exp : tID
    | tNBR
    | tTRUE
    | tFALSE
    | tSTAR tID /* TODO: check si tID correspond à un pointeur dans la partie sémantique */
    /*| Exp tCROO Exp tCROF*/
    | tID tPARO Args tPARF
    | Exp tEQUAL Exp
    | Exp tPLUS Exp
    | Exp tMINUS Exp
    | Exp tSTAR Exp
    | Exp tDIV Exp
    | Exp tMOD Exp
    | tNOT Exp
    | Exp tAND Exp
    | Exp tOR Exp
    | tPARO Exp tPARF;

Aff : tID tEQUAL Exp End;

If : tIF tPARO Exp tPARF Body;

While : tWHILE tPARO Exp tPARF Body;

Instrs : Instr Instrs | /* epsilon */;

Instr : Def | Aff | If | While | tPRINTF tPARO Exp tPARF End;

%%

void yyerror(const char* msg) {
    printf("ERROR: %s\n", msg);
}

int main(int argc, char const **argv) {
    yyparse();

    return 0;
}
