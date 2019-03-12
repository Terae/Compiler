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
%token tSEMI tCOMMA tNOT tQUESTION tCOLON
%token tPLUS tMINUS tDIV tSTAR tMOD tEQUAL tINCR tDECR
%token tID tNBR tCHAR_LITERAL tSTRING_LITERAL

%start S

%right tEQUAL /* +=, -=, >>=, ... */

%right tQUESTION tCOLON

%left tOR
%left tAND
/* left
   |
   ^
   ==, <=, >=, <, >, !=
   >>, <<
*/
%left tPLUS tMINUS
%left tSTAR tDIV tMOD
%right tAMP
%right tNOT
%left tCROO tCROF tPARO tPARF
%right tINCR tDECR

%nonassoc EndIf
%nonassoc tELSE

%%

S : Fonctions;

Fonctions : Fonction Fonctions | Fonction;

Type : tINT | tCONST tINT | tVOID | tCHAR | tCONST tCHAR;

Fonction : Type tID tPARO Params tPARF FunctionBody | Type tID tPARO Params tPARF End;

FunctionBody : tACCO { if(implementation_enabled == 0) { yyerror("parameter name ommitted"); } } Instrs tACCF;

Body : tACCO Instrs tACCF;

End : tSEMI;

TypedDefNext : End | tCOMMA TypedDef;

TypedDef : tID TypedDefNext | tID tEQUAL Exp TypedDefNext

Def : Type TypedDef;

Params : { implementation_enabled = 1; } | ParamsNamedList { implementation_enabled = 1; } | ParamsUnnamedList { implementation_enabled = 0; };

// int a, char c, ...
// Left recursion is better than right recursion for memory management (not so much 'shift' before reduce-ing)
ParamsNamedList : ParamNamed | ParamsNamedList tCOMMA ParamNamed;

ParamNamed : Type tID;

// int, char, ...
ParamsUnnamedList : ParamUnnamed | ParamsUnnamedList tCOMMA ParamUnnamed;

ParamUnnamed : Type;

// toto, a, ...
Args : | ArgsList;

ArgsList : Arg | ArgsList tCOMMA Arg;

Arg : Exp;

Exp : tID
    | tNBR
    | tCHAR_LITERAL
    | tSTRING_LITERAL
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

If : tIF CondIf Body %prec EndIf
   | tIF CondIf Body tELSE Body;

CondIf : tPARO Exp tPARF;

While : tWHILE tPARO Exp tPARF Body;

DoWhile : tDO Body tWHILE tPARO Exp tPARF

Instrs : Instr Instrs | /* epsilon */;

Instr : Def | Aff | If | While | DoWhile | tPRINTF tPARO Exp tPARF End;

%%

void yyerror(const char* msg) {
    printf("ERROR: %s\n", msg);
}

int main(int argc, char const **argv) {
    yyparse();

    return 0;
}
