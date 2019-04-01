%code requires {
    #include "Symbols.h"
}

%{
    #include <stdio.h>
    #include <string.h>

    #include "Assembly.h"
    #include "Error.h"
    #include "Symbols.h"

    #define YYERROR_VERBOSE

    extern int const count_line;

    int yylex(void);

    int implementation_enabled = 1;

    // Global vars
    T_Type type_var;

    /** Symbols **/
    // functions
    S_SYMBOL *addVarWithType(const char *name, T_Type type) {
        S_SYMBOL *symbol = NULL;
        if(strcmp(name, "") == 0) {
            symbol = createTmpSymbol(type);
        } else {
            symbol = createSymbol(name, type);
        }

        if (symbol != NULL) {
            printSymbolTable();
        }
        return symbol;
    }

    S_SYMBOL *addVar(const char *name) {
        return addVarWithType(name, type_var);
    }

%}

%union{
    int nbr;
    char *string;
    struct Symbol *symbol;
    enum Type type;
}

%token <nbr>    tNBR
%token <string> tID
%token <string> tCHAR_LITERAL
%token <string> tSTRING_LITERAL

%type <symbol> Constant
%type <symbol> ExpressionPrimary
%type <symbol> ExpressionPostfix
%type <symbol> ExpressionUnary
%type <symbol> ExpressionCast
%type <symbol> ExpressionMultiplicative
%type <symbol> ExpressionAdditive
%type <symbol> ExpressionShift
%type <symbol> ExpressionRelational
%type <symbol> ExpressionEquality
%type <symbol> ExpressionAnd
%type <symbol> ExpressionExclusiveOr
%type <symbol> ExpressionInclusiveOr
%type <symbol> ExpressionLogicalAnd
%type <symbol> ExpressionLogicalOr
%type <symbol> ExpressionConditional
%type <symbol> ExpressionAssignment
%type <symbol> Expression
%type <symbol> ExpressionConstant

%type <type> TypeSpecifier
%type <type> FinalType

%token tMAIN tPRINTF
%token tCONST tINT tVOID tCHAR tENUM tBOOL
%token tIF tELSE tSWITCH tCASE tDEFAULT tFOR tWHILE tDO tBREAK tCONTINUE tRETURN tSIZEOF
%token tAND tOR tTRUE tFALSE tNULL
%token tEQ tLE tGE tNE tINCR tDECR
%token tRIGHT_ASSIGN tLEFT_ASSIGN tADD_ASSIGN tSUB_ASSIGN tMUL_ASSIGN tDIV_ASSIGN tMOD_ASSIGN tAND_ASSIGN tXOR_ASSIGN tOR_ASSIGN
%token tRIGHT_OP tLEFT_OP tPTR_OP

%start Program

/// C Operator Precedence: https://en.cppreference.com/w/c/language/operator_precedence
// Precedence: 15
%left ','
// Precedence: 14
%right '=' tADD_ASSIGN tSUB_ASSIGN tMUL_ASSIGN tDIV_ASSIGN tMOD_ASSIGN tRIGHT_ASSIGN tLEFT_ASSIGN tAND_ASSIGN tXOR_ASSIGN tOR_ASSIGN
// Precedence: 13
%right '?' ':'
// Precedence: 12
%left tOR
// Precedence: 11
%left tAND
// Precedence: 10
%left '|'
// Precedence: 9
%left '^'
// Precedence: 8
%left '&'
// Precedence: 7
%left tEQ tNE
// Precedence: 6
%left '<' tLE '>' tGE
// Precedence: 5
%left tRIGHT_OP tLEFT_OP
// Precedence: 4
%left '+' '-'
// Precedence: 3
%left '*' '/' '%'
// Precedence: 2
%right tINCR tDECR '!' '~' /*'*'*/ /*'&'*/ tSIZEOF /*'+'*/ /*'-'*/
// Precedence: 1
%left '[' ']' '(' ')' '.' tPTR_OP /*tINCR*/ /*tDECR*/

%nonassoc EndIf
%nonassoc tELSE

%%

End : error ';'
        {
                // yyerrok();
                // enableErrorReporting();
        }
    | ';' { popAllTmp(); };

Program :         ExternalDeclaration
        | Program ExternalDeclaration;

ExternalDeclaration : FunctionDefinition
                    | Declaration;

FunctionDefinition : FinalType tID '(' Params ')' FunctionStatementCompound
                   | FinalType tID '(' Params ')' End;

TypeSpecifier : tINT  { $$ = type_var = Integer; }
              | tVOID { $$ = type_var = Void; }
              | tCHAR { $$ = type_var = Character; }
              | tBOOL { $$ = type_var = Boolean; };

TypeQualifier : tCONST;

TypeQualifierList :                   TypeQualifier
                  | TypeQualifierList TypeQualifier;

Pointer : TypeQualifierList '*' Pointer
        | TypeQualifierList '*'
        | '*' Pointer
        | '*';

FinalType :                   TypeSpecifier
          |                   TypeSpecifier Pointer
          | TypeQualifierList TypeSpecifier { $$ = $2; }
          | TypeQualifierList TypeSpecifier Pointer { $$ = $2; };

TypedDeclarationAssignmentNext : End
                               | ',' TypedDeclarationAssignment;

TypedDeclarationAssignment : tID  { addVar($1); } '=' ExpressionAssignment TypedDeclarationAssignmentNext;

TypedDeclarationNext : End
                     | ',' TypedDeclaration;
// Non-affected declaration : int a,b;
TypedDeclaration : tID { addVar($1); } TypedDeclarationNext
                 | TypedDeclarationAssignment;

Declaration : FinalType TypedDeclaration;

// int a, char c, ...
// Left recursion is better than right recursion for memory management (not so much 'shift' before reduce-ing)
ParamsNamedList :                     ParamNamed
                | ParamsNamedList ',' ParamNamed;

ParamNamed : FinalType tID { addVarWithType($2, $1); };

// int, char, ...
ParamsUnnamedList :                       ParamUnnamed
                  | ParamsUnnamedList ',' ParamUnnamed;

ParamUnnamed : FinalType;

Params :                   { implementation_enabled = 1; }
       | ParamsNamedList   { implementation_enabled = 1; }
       | ParamsUnnamedList { implementation_enabled = 0; };

Constant : tNBR {
                        S_SYMBOL *symbol = addVarWithType("", Integer);
                        writeAssembly(AFC" %d %d", symbol->addr, $1);
                        $$ = symbol;
                }
         | tCHAR_LITERAL
                 {
                         S_SYMBOL *symbol = addVarWithType("", Character);
                         writeAssembly(AFC" %d %d", symbol->addr, (int)($1[0]));
                 }
         | tSTRING_LITERAL
                 {
                         warning("The present compiler is not able to manage strings: %s. Transforming it into '%d'.", $1, $1[0]);
                         S_SYMBOL *symbol = addVarWithType("", Character);
                         writeAssembly(AFC" %d %d", symbol->addr, (int)($1[0]));
                 }
         | tTRUE
                 {
                         S_SYMBOL *symbol = addVarWithType("", Boolean);
                         writeAssembly(AFC" %d 1", symbol->addr);
                         $$ = symbol;
                 }
         | tFALSE
                 {
                         S_SYMBOL *symbol = addVarWithType("", Boolean);
                         writeAssembly(AFC" %d 0", symbol->addr);
                         $$ = symbol;
                 }
         | tNULL
                 {
                         S_SYMBOL *symbol = addVarWithType("", Boolean);
                         writeAssembly(AFC" %d 0", symbol->addr);
                         $$ = symbol;
                 };

ExpressionPrimary : tID {
                                S_SYMBOL *id = getSymbolByName($1);
                                if (id == NULL) {
                                    yyerror("Unknown id: '%s'", $1);
                                } else {
                                    $$ = id;
                                }
                        }
                  | Constant
                  | '(' Expression ')' { $$ = $2; }

ExpressionPostfix : ExpressionPrimary
                  | ExpressionPostfix '{' { pushBlock(); } Expression '}' { popBlock(); }
                  | ExpressionPostfix '(' ')'
                  | ExpressionPostfix '(' ArgumentExpressionList ')'
                  | ExpressionPostfix '.' tID
                  | ExpressionPostfix tPTR_OP tID
                  | ExpressionPostfix tINCR
                          {
                                S_SYMBOL *left = $1; // getLastSymbol();
                                S_SYMBOL *copy = addVarWithType("", left->type);
                                writeAssembly(COP" %d %d", copy->addr, left->addr);
                                S_SYMBOL *one = addVarWithType("", Integer);
                                writeAssembly(AFC" %d 1", one->addr);

                                binaryOperationAssignment(ADD, $1, one);
                                $$ = copy;
                        }
                  | ExpressionPostfix tDECR
                          {
                                S_SYMBOL *left = $1; // getLastSymbol();
                                S_SYMBOL *copy = addVarWithType("", left->type);
                                writeAssembly(COP" %d %d", copy->addr, left->addr);
                                S_SYMBOL *one = addVarWithType("", Integer);
                                writeAssembly(AFC" %d 1", one->addr);

                                binaryOperationAssignment(SOU, $1, one);
                                $$ = copy;
                        };

ArgumentExpressionList :                            ExpressionAssignment
                       | ArgumentExpressionList ',' ExpressionAssignment;

ExpressionUnary : ExpressionPostfix
                | tINCR   ExpressionUnary
                        {
                                S_SYMBOL *one = addVarWithType("", Integer);
                                writeAssembly(AFC" %d 1", one->addr);
                                $$ = binaryOperationAssignment(ADD, $2, one);
                        }
                | tDECR   ExpressionUnary
                        {
                                S_SYMBOL *one = addVarWithType("", Integer);
                                writeAssembly(AFC" %d 1", one->addr);
                                $$ = binaryOperationAssignment(SOU, $2, one);
                        }
                | tSIZEOF ExpressionUnary
                        {
                                S_SYMBOL *s = $2, *result = addVarWithType("", Integer);
                                writeAssembly(AFC" %d %d", result->addr, getSymbolSize(s));
                                freeIfTmp(s);
                                $$ = result;
                        }
                | '&' ExpressionCast
                        {
                                S_SYMBOL *s = $2;
                                S_SYMBOL *a = addVarWithType("", s->type);
                                writeAssembly(AFC" %d %d", a->addr, s->addr);
                                $$ = a;
                        }
                | '*' ExpressionCast
                        {
                                warning("The present compiler is not able to manage the dereferencement of pointer: %d, skipping.", $2->addr);
                                $$ = $2;
                        }
                | '+' ExpressionCast %prec '*' { $$ = $2; }
                | '-' ExpressionCast %prec '*'
                        {
                                S_SYMBOL *tmp = addVarWithType("", Integer);
                                writeAssembly(AFC" %d -1", tmp->addr);
                                $$ = binaryOperation(MUL, $2, tmp);
                        }
                | '~' ExpressionCast { $$ = bitnot($2); }
                | '!' ExpressionCast { $$ = negate($2); };

ExpressionCast : ExpressionUnary;
               | '(' FinalType ')' ExpressionCast
                               {
                                       switch ($2) {
                                           case Integer:
                                           {
                                               S_SYMBOL *s = $4;
                                               s->type = Integer;
                                               $$ = s;
                                               break;
                                           }

                                           case Character:
                                           {
                                               S_SYMBOL *s = $4;
                                               s->type = Character;

                                               S_SYMBOL *mask = addVarWithType("", Integer);
                                               writeAssembly(AFC" %d 255", mask->addr);

                                               $$ = bitand(s, mask);
                                               break;
                                           }

                                           case Boolean:
                                               $$ = toBool($4);
                                               break;

                                           case Void:
                                               yyerror("Impossible to cast to the void type.");
                                               $$ = $4;
                                               break;

                                           case Error:
                                           default:
                                               yyerror("Impossible to cast, error on the type.");
                                               $$ = $4;
                                       }
                               };

// Multiplicative operators ('*', '/', '%')
ExpressionMultiplicative :                              ExpressionUnary
                         | ExpressionMultiplicative '*' ExpressionUnary { $$ = binaryOperation(MUL, $1, $3); }
                         | ExpressionMultiplicative '/' ExpressionUnary { $$ = binaryOperation(DIV, $1, $3); }
                         | ExpressionMultiplicative '%' ExpressionUnary { $$ = modulo($1, $3); };

// Additive operators ('+', '-')
ExpressionAdditive :                        ExpressionMultiplicative
                   | ExpressionAdditive '+' ExpressionMultiplicative { $$ = binaryOperation(ADD, $1, $3); }
                   | ExpressionAdditive '-' ExpressionMultiplicative { $$ = binaryOperation(SOU, $1, $3); };

// Shift operators ('<<', '>>')
ExpressionShift :                           ExpressionAdditive
                | ExpressionShift tRIGHT_OP ExpressionAdditive { $$ = binaryOperation(DIV, $1, powerOfTwo($3)); }
                | ExpressionShift tLEFT_OP  ExpressionAdditive { $$ = binaryOperation(MUL, $1, powerOfTwo($3)); };

// Relational operators ('<', '<=', '>', '>=')
ExpressionRelational :                          ExpressionShift
                     | ExpressionRelational '<' ExpressionShift { $$ = binaryOperation(INF, $1, $3); }
                     | ExpressionRelational '>' ExpressionShift { $$ = binaryOperation(INF, $3, $1); }
                     | ExpressionRelational tLE ExpressionShift { $$ = negate(binaryOperation(INF, $3, $1)); }
                     | ExpressionRelational tGE ExpressionShift { $$ = negate(binaryOperation(INF, $1, $3)); };

// Equality operators ('==', '!=')
ExpressionEquality :                        ExpressionRelational
                   | ExpressionEquality tEQ ExpressionRelational { $$ = binaryOperation(EQU, $1, $3); }
                   | ExpressionEquality tNE ExpressionRelational { $$ = negate(binaryOperation(EQU, $1, $3)); };

// Bitwise AND operator ('&')
ExpressionAnd :                   ExpressionEquality
              | ExpressionAnd '&' ExpressionEquality { $$ = bitand($1, $3); };

// Bitwise XOR operator ('^')
ExpressionExclusiveOr :                           ExpressionAnd
                      | ExpressionExclusiveOr '^' ExpressionAnd { $$ = bitxor($1, $3); };

// Bitwise OR operator ('|')
ExpressionInclusiveOr :                           ExpressionExclusiveOr
                      | ExpressionInclusiveOr '|' ExpressionExclusiveOr { $$ = bitor($1, $3); };

// Logical AND operator ('&&')
ExpressionLogicalAnd :                           ExpressionInclusiveOr
                     | ExpressionLogicalAnd tAND ExpressionInclusiveOr
                         {
                                S_SYMBOL *s = binaryOperation(ADD, toBool($1), toBool($3));
                                S_SYMBOL *two = addVarWithType("", Integer);
                                writeAssembly(AFC" %d 2", two->addr);
                                $$ = binaryOperation(EQU, s, two);
                         };

// Logical OR operator ('||')
ExpressionLogicalOr :                         ExpressionLogicalAnd
                    | ExpressionLogicalOr tOR ExpressionLogicalAnd
                         {
                                S_SYMBOL *s = binaryOperation(ADD, toBool($1), toBool($3));
                                S_SYMBOL *zero = addVarWithType("", Integer);
                                writeAssembly(AFC" %d 0", zero->addr);
                                $$ = binaryOperation(INF, zero, s);
                         };

// Conditional operator (… '?' … ':' …)
ExpressionConditional : ExpressionLogicalOr
                      | ExpressionLogicalOr '?' Expression ':' ExpressionConditional;

// Assignment operators ('=', '<<=', '>>=', '+=', '-=', '*=', '/=', '%=', '&=', '^=', '|=')
ExpressionAssignment : ExpressionConditional
                     | ExpressionUnary '=' ExpressionAssignment
                        {
                                affectation($1, $3);
                                $$ = $1;
                        }
                     | ExpressionUnary tRIGHT_ASSIGN ExpressionAssignment
                        {
                                S_SYMBOL *tmp = powerOfTwo($3);
                                $$ = binaryOperationAssignment(DIV, $1, tmp);
                        }
                     | ExpressionUnary tLEFT_ASSIGN ExpressionAssignment
                        {
                                S_SYMBOL *tmp = powerOfTwo($3);
                                $$ = binaryOperationAssignment(MUL, $1, tmp);
                        }
                     | ExpressionUnary tADD_ASSIGN ExpressionAssignment
                        {
                                $$ = binaryOperationAssignment(ADD, $1, $3);
                        }
                     | ExpressionUnary tSUB_ASSIGN ExpressionAssignment
                        {
                                $$ = binaryOperationAssignment(SOU, $1, $3);
                        }
                     | ExpressionUnary tMUL_ASSIGN ExpressionAssignment
                        {
                                $$ = binaryOperationAssignment(MUL, $1, $3);
                        }
                     | ExpressionUnary tDIV_ASSIGN ExpressionAssignment
                        {
                                $$ = binaryOperationAssignment(DIV, $1, $3);
                        }
                     | ExpressionUnary tMOD_ASSIGN ExpressionAssignment
                        {
                                affectation($1, modulo($1, $3));
                                $$ = $1;
                        }
                     | ExpressionUnary tAND_ASSIGN ExpressionAssignment
                        {
                                affectation($1, bitand($1, $3));
                                $$ = $1;
                        }
                     | ExpressionUnary tXOR_ASSIGN ExpressionAssignment
                        {
                                affectation($1, bitxor($1, $3));
                                $$ = $1;
                        }
                     | ExpressionUnary tOR_ASSIGN ExpressionAssignment
                        {
                                affectation($1, bitor($1, $3));
                                $$ = $1;
                        };

Expression :                ExpressionAssignment
           | Expression ',' ExpressionAssignment;

ExpressionConstant : ExpressionConditional;

/// Statements
Statement : StatementLabeled
          | StatementCompound
          | StatementExpression
          | StatementSelection
          | StatementIteration
          | StatementJump;

StatementLabeled : tID ':' Statement
                 | tCASE ExpressionConstant ':' Statement
                 | tDEFAULT ':' Statement;

FunctionStatementCompound : '{' { pushBlock(); } { if (implementation_enabled == 0) { yyerror("parameter name ommitted"); } }               '}' { popBlock(); }
                          | '{' { pushBlock(); } { if (implementation_enabled == 0) { yyerror("parameter name ommitted"); } } BlockItemList '}' { popBlock(); };

StatementCompound : '{' { pushBlock(); }               '}' { popBlock(); }
                  | '{' { pushBlock(); } BlockItemList '}' { popBlock(); };

BlockItemList : BlockItem
              | BlockItemList BlockItem;

BlockItem : Declaration
          | Statement;

StatementExpression : End
                    | Expression End
                    | tPRINTF '(' Expression ')' End;

StatementSelection : tIF CondIf Statement %prec EndIf
                   | tIF CondIf Statement tELSE Statement
                   | tSWITCH CondIf Statement;

CondIf : '(' Expression ')';

StatementIteration :               tWHILE '(' Expression ')' Statement
                   | tDO Statement tWHILE '(' Expression ')' End
                   | tFOR '(' StatementExpression StatementExpression            ')' Statement
                   | tFOR '(' StatementExpression StatementExpression Expression ')' Statement
                   | tFOR '(' Declaration         StatementExpression            ')' Statement
                   | tFOR '(' Declaration         StatementExpression Expression ')' Statement;

StatementJump : tCONTINUE End
              | tBREAK End
              | tRETURN End
              | tRETURN Expression End;

%%

int main(int argc, char const **argv) {
    initSymbolTable();

    char *outputPath = strdup("build/a.s");
    initAssemblyOutput(outputPath);

    yyparse();

    closeAssemblyOutput(outputPath);
    free(outputPath);

    resetSymbolTable();

    if(errorsOccured() > 0) {
        fprintf(stderr, "\x1b[0m\x1b[41m%d errors occured during compilation, which is aborted.\x1b[0m\n", errorsOccured());
        return FAILURE_COMPILATION;
    }

    return 0;
}
