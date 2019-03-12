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
%left tCROO tCROF tPARO tPARF

%%

S : Fonctions;

Fonctions : Fonction Fonctions | Fonction;

Type : tINT | tCONST tINT | tVOID | tCHAR | tCONST tCHAR;

Fonction : Type tID tPARO Args tPARF FunctionBody | Type tID tPARO Args tPARF End;

FunctionBody : tACCO { if(implementation_enabled == 0) { yyerror("parameter name ommitted"); } } Instrs tACCF;

Body : tACCO Instrs tACCF;

End : tSEMI;

TypedDefNext : End | tCOMMA TypedDef;

TypedDef : tID TypedDefNext | tID tEQUAL Exp TypedDefNext

Instrs : Instr Instrs | /* epsilon */;

Instr : Def | Aff | If | While;

Def : Type TypedDef;

Args : { implementation_enabled = 1; } | ArgsNamedList { implementation_enabled = 1; } | ArgsUnnamedList { implementation_enabled = 0; };

// int a, char c, ...
// Left recursion is better than right recursion for memory management (not so much 'shift' before reduce-ing)
ArgsNamedList : ArgNamed | ArgsNamedList tCOMMA ArgNamed;

ArgNamed : Type tID;

// int, char, ...
ArgsUnnamedList : ArgUnnamed | ArgsUnnamedList tCOMMA ArgUnnamed;

ArgUnnamed : Type;

Exp : tID
    | tNBR
    | tTRUE
    | tFALSE
    | tSTAR tID /* TODO: check si tID correspond à un pointeur dans la partie sémantique */
    /*| Exp tCROO Exp tCROF*/
    | tID tPARO  tPARF
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
