%code requires {
    #include "Symbols.h"
}

%{
    #include <stdio.h>
    #include <string.h>

    #include "Assembly.h"
    #include "Error.h"
    #include "Symbols.h"
    #include "Functions.h"

    #define YYERROR_VERBOSE

    extern int const count_line;
    int count_assembly;

    int yylex(void);

    int implementation_enabled = 1;
    int is_in_function_call = 0;

    // Global vars
    T_Type type_var;
    T_Qualifier type_qualifier;

    /** Symbols **/
    // functions
    S_SYMBOL *addVarWithType(const char *name, T_Type type) {
        S_SYMBOL *symbol = NULL;
        if(strcmp(name, "") == 0) {
            symbol = createTmpSymbol(type);
        } else {
            symbol = createSymbol(name, type, type_qualifier);
        }

        return symbol;
    }

    S_SYMBOL *addVar(const char *name) {
        return addVarWithType(name, type_var);
    }

    void PatchAddOrDieFunction(const char * name, int addr, int nbParam){
      S_Functions * temp = getFunctionByName(name);
      if (temp != NULL){
        if (temp->addr != -1){
          //Already defined &/or patched
          yyerror("Function '%s' already defined at %d", name,temp->addr);
        }else{
          patchSpecFunction(temp,addr);
        }
      }else{
        createDeclarativeFunction(name,addr,nbParam);
      }
      printFunctionsTable();
    }
    void handleArgumentsFunctions(S_SYMBOL * symb){
      if (!isTmp(symb)){
        printf("Not tmp symbol %s\n",symb->name);
        S_SYMBOL * pseudotmp = createTmpSymbolFromSymbol(symb);
        writeAssembly(LOAD" %s %d",tmpR,symb->addr);
        writeAssembly(STORE" %d %s ; copie de %s dans tmp",pseudotmp->addr,tmpR,symb->name);
      }
    }
%}

%union{
    int nbr;
    char *string;
    struct Symbol *symbol;
    struct func * func;
    enum Type type;
		enum Qualifier qualifier;
}

%token <nbr>    tNBR
%token <string> tID
%token <string> tCHAR_LITERAL
%token <string> tSTRING_LITERAL


%type <nbr> tDO
%type <nbr> '('
%type <nbr> ')'
%type <symbol> '='
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

%type <type> TypeSpecifier
%type <type> FinalType

%type <qualifier> TypeQualifier

%type <nbr> Params
%type <nbr> ParamsNamedList
%type <nbr> ParamsUnnamedList
%type <func> FunctionCall
%type <nbr> ArgumentExpressionList

%token tMAIN tPRINTF tSCANF
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
    | ';' { popAllTmp(); type_qualifier = Nothing; };

Program :         ExternalDeclaration
        | Program ExternalDeclaration;

ExternalDeclaration : FunctionDefinition
                    | Declaration;

PushBlocFunction: {pushBlock();}


// Verify if body not inserted yet
FunctionDefinition : FinalType tID '(' PushBlocFunction Params ')' { PatchAddOrDieFunction($2,count_assembly - 1,$5); } FunctionStatementCompound
                   | FinalType tID '(' PushBlocFunction Params ')' End  { popBlock(); createSpecFunction($2,$5); };

FunctionCall : tID {pushBlock();is_in_function_call=1;} '(' ArgumentExpressionList ')' { printSymbolTable(); is_in_function_call=0;popBlock();S_Functions * f = getFunctionByName($1);
  if (f == NULL){
    yyerror("Unknown function '%s'", $1);
  }else{
    if (f->addr != -1){
      $$ = f;
      writeAssembly(AFC" 0, %d ; nbParam in 0",f->nbParam);
      writeAssembly(ADD" %s, XX  ; Increase ebp",esp,f->nbParam);
      writeAssembly(JMP" %d    ; jump to %s",f->addr,f->name);
    }else{
      yyerror("Calling to an missing body function '%s'\n",f->name);
    }
  }
 };

TypeSpecifier : tINT  { $$ = type_var = Integer; }
              | tVOID { $$ = type_var = Void; }
              | tCHAR { $$ = type_var = Character; }
              | tBOOL { $$ = type_var = Boolean; };

TypeQualifier : tCONST { $$ = type_qualifier = Const; };

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

TypedDeclarationAssignment : tID '=' { $2 = addVar($1); } ExpressionAssignment { affectation($2, $4); } TypedDeclarationAssignmentNext;

TypedDeclarationNext : End
                     | ',' TypedDeclaration;
// Non-affected declaration : int a,b;
TypedDeclaration : tID { addVar($1); } TypedDeclarationNext
                 | TypedDeclarationAssignment;

Declaration : FinalType TypedDeclaration;

// int a, char c, ...
// Left recursion is better than right recursion for memory management (not so much 'shift' before reduce-ing)
ParamsNamedList :                     ParamNamed { $$=$$+1; }
                | ParamsNamedList ',' ParamNamed { $$=$$+1; };

ParamNamed : FinalType tID { addVarWithType($2, $1); };

// int, char, ...
ParamsUnnamedList :                       ParamUnnamed { $$=$$+1; }
                  | ParamsUnnamedList ',' ParamUnnamed { $$=$$+1; };

ParamUnnamed : FinalType;

Params :                   { implementation_enabled = 1; $$= 0; }
       | ParamsNamedList   { implementation_enabled = 1; $$=$1; }
       | ParamsUnnamedList { implementation_enabled = 0; $$=$1; };

Constant : tNBR {
                         $$ = createConstant(Integer, $1);
                }
         | tCHAR_LITERAL
                 {
                         $$ = createConstant(Character, (int)($1[0]));
                 }
         | tSTRING_LITERAL
                 {
                         warning("The present compiler is not able to manage strings: %s. Transforming it into '%d'.", $1, $1[0]);
                         $$ = createConstant(Character, (int)($1[0]));
                 }
         | tTRUE
                 {
                         $$ = createConstant(Boolean, 1);
                 }
         | tFALSE
                 {
                         $$ = createConstant(Boolean, 0);
                 }
         | tNULL
                 {
                         $$ = createConstant(Integer, 0);
                 };

ExpressionPrimary : tID {
                                S_SYMBOL *id = getSymbolByName($1);
                                if (id == NULL) {
                                    yyerror("Unknown id: '%s'", $1);
                                } else {
                                    if (is_in_function_call){
                                      //$$ = id;
                                      $$ = createTmpSymbolFromSymbol(id);
                                      //handleArgumentsFunctions(id);
                                    }else{
                                      $$ = id;
                                    }
                                }
                        }
                  | Constant
                  | '(' Expression ')' { $$ = $2; }
                  | FunctionCall;

ExpressionPostfix : ExpressionPrimary
                  | ExpressionPostfix '{' { pushBlock(); } Expression '}' { popBlock(); }
                  | ExpressionPostfix '.' tID
                  | ExpressionPostfix tPTR_OP tID
                  | ExpressionPostfix tINCR
                          {
                            //| ExpressionPostfix '(' ')'
                            //| ExpressionPostfix '(' ArgumentExpressionList ')'
                                writeDebug("postfix increment");
                                S_SYMBOL *left = $1; // getLastSymbol();
                                S_SYMBOL *copy = addVarWithType("", left->type);
                                writeAssembly(COP" %d, %d", copy->addr, left->addr);
                                S_SYMBOL *one = createConstant(Integer, 1);

                                binaryOperationAssignment(ADD, $1, one);
                                $$ = copy;
                        }
                  | ExpressionPostfix tDECR
                          {
                                writeDebug("postfix decrement");
                                S_SYMBOL *left = $1; // getLastSymbol();
                                S_SYMBOL *copy = addVarWithType("", left->type);
                                writeAssembly(COP" %d, %d", copy->addr, left->addr);
                                S_SYMBOL *one = createConstant(Integer, 1);

                                binaryOperationAssignment(SOU, $1, one);
                                $$ = copy;
                        };

ArgumentExpressionList :                      { $$ = 0;      }
                       | ExpressionAssignment { $$ = 1;}
                       | ExpressionAssignment ',' ArgumentExpressionList {$$=$3+1;} ;

ExpressionUnary : ExpressionPostfix
                | tINCR   ExpressionUnary
                        {
                                writeDebug("prefix increment");
                                S_SYMBOL *one = createConstant(Integer, 1);
                                $$ = binaryOperationAssignment(ADD, $2, one);
                        }
                | tDECR   ExpressionUnary
                        {
                                writeDebug("prefix decrement");
                                S_SYMBOL *one = createConstant(Integer, 1);
                                $$ = binaryOperationAssignment(SOU, $2, one);
                        }
                | tSIZEOF ExpressionUnary
                        {
                                writeDebug("sizeof");
                                S_SYMBOL *s = $2, *size = createConstant(Integer, getSymbolSize(s));
                                freeIfTmp(s);
                                $$ = size;
                        }
                | '&' ExpressionCast
                        {
                                writeDebug("referencement");
                                S_SYMBOL *s = $2;
                                $$ = createConstant(Integer, s->addr);
                        }
                | '*' ExpressionCast
                        {
                                writeDebug("dereferencement");
                                warning("The present compiler is not able to manage the dereferencement of pointer: %d, skipping.", $2->addr);
                                $$ = $2;
                        }
                | '+' ExpressionCast %prec '*' { $$ = $2; }
                | '-' ExpressionCast %prec '*'
                        {
                                writeDebug("inverse");
                                S_SYMBOL *minusOne = createConstant(Integer, -1);
                                $$ = binaryOperation(MUL, $2, minusOne);
                        }
                | '~' ExpressionCast
                        {
                                writeDebug("bitwise not");
                                $$ = bitnot($2);
                        }
                | '!' ExpressionCast
                        {
                                writeDebug("negate");
                                $$ = negate($2);
                        };

ExpressionCast : ExpressionUnary;
               | '(' FinalType ')' ExpressionCast
                               {
                                       switch ($2) {
                                           case Integer:
                                           {
                                               writeDebug("casting from %s to %s", typeToString($4->type), "int");
                                               S_SYMBOL *s = $4;
                                               s->type = Integer;
                                               $$ = s;
                                               break;
                                           }

                                           case Character:
                                           {
                                               writeDebug("casting from %s to %s", typeToString($4->type), "char");
                                               S_SYMBOL *s = $4;
                                               s->type = Character;

                                               S_SYMBOL *mask = createConstant(Integer, 255);

                                               $$ = bitand(s, mask);
                                               break;
                                           }

                                           case Boolean:
                                               writeDebug("casting from %s to %s", typeToString($4->type), "int");
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
                                S_SYMBOL *two = createConstant(Integer, 2);
                                $$ = binaryOperation(EQU, s, two);
                         };

// Logical OR operator ('||')
ExpressionLogicalOr :                         ExpressionLogicalAnd
                    | ExpressionLogicalOr tOR ExpressionLogicalAnd
                         {
                                S_SYMBOL *s = binaryOperation(ADD, toBool($1), toBool($3));
                                S_SYMBOL *zero = createConstant(Integer, 0);
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

Expression : ExpressionAssignment ',' Expression 
           | ExpressionAssignment ;

/// Statements
Statement : StatementCompound
          | StatementExpression
          | StatementSelection
          | StatementIteration
          | StatementJump;

FunctionStatementCompoundFactor : '{' { if (implementation_enabled == 0) { yyerror("parameter name ommitted"); } };

FunctionStatementCompound : FunctionStatementCompoundFactor               '}' { popBlock(); }
                          | FunctionStatementCompoundFactor BlockItemList '}' { popBlock(); };

StatementCompound : '{' { pushBlock(); }               '}' { popBlock(); }
                  | '{' { pushBlock(); } BlockItemList '}' { popBlock(); };

BlockItemList : BlockItem
              | BlockItemList BlockItem;

BlockItem : Declaration
          | Statement;

StatementExpression : End
                    | Expression End
                    | tPRINTF { writeDebug("PRINTF"); } '(' Expression ')' End { writeAssembly(PRINT" %hu", $4->addr); }
                    | tSCANF  { writeDebug("SCANF");  } '(' tID ')' End
                        {
                            S_SYMBOL *id = getSymbolByName($4);
                            if (id == NULL) {
                                yyerror("Unknown id: '%s'", $4);
                            } else {
                                writeAssembly(SCANF" %s", tmpR);
                                writeAssembly(STORE" %d, %s", id->addr, tmpR);
                            }
                        } ;

StatementSelectionFactor: { writeDebug("IF"); writeAssembly(LOAD" %s, %d", r0, ($<symbol>-1)->addr); ($<nbr>-2) = count_assembly; writeAssembly(JMPC" NULL, %s", r0); };

StatementSelection : tIF '(' Expression ')' StatementSelectionFactor Statement       { $4 = count_assembly; patchJumpAssembly($2, $4); } %prec EndIf
                   | tIF '(' Expression ')' StatementSelectionFactor Statement tELSE { $4 = count_assembly; patchJumpAssembly($2, $4 + 1); writeAssembly(JMP" NULL"); writeDebug("ELSE"); } Statement { patchJumpAssembly($4, count_assembly);}
                   | tSWITCH '(' Expression ')' Statement;

StatementIteration :               tWHILE '(' { $2 = count_assembly; } Expression ')' { writeDebug("WHILE"); writeAssembly(LOAD" %s, %d", r1, $4->addr); writeAssembly(AFC" %s, 0", r2); writeAssembly(EQU" %s, %s, %s", r0, r1, r2); $5 = count_assembly; writeAssembly(JMPC" NULL, %s", r0); } Statement { writeAssembly(JMP" %d", $2); patchJumpAssembly($5, count_assembly); }
                   | tDO { writeDebug("DO"); $1 = count_assembly; } Statement tWHILE '(' Expression ')' End { writeDebug("WHILE"); writeAssembly(LOAD" %s, %d", r1, $6->addr); writeAssembly(AFC" %s, 0", r2); writeAssembly(EQU" %s, %s, %s", r0, r1, r2); writeAssembly(JMPC" %d, %s", $1, r0); }
                   | tFOR '(' StatementExpression StatementExpression            ')' Statement
                   | tFOR '(' StatementExpression StatementExpression Expression ')' Statement
                   | tFOR '(' Declaration         StatementExpression            ')' Statement
                   | tFOR '(' Declaration         StatementExpression Expression ')' Statement;

StatementJump : tCONTINUE End
              | tBREAK End
              | tRETURN End
              | tRETURN Expression End {writeAssembly("RETURN "); printf ("Value to return named %s\n", $2->name);};

%%

int main(int argc, char const **argv) {
    initSymbolTable();
    initFunctionsTable();
    char *outputPath = strdup("build/a.s");
    initAssemblyOutput(outputPath);

    // Init esp
    writeAssembly(AFC" %s, %d",esp, getESP());
    // Jump to main (undefined addr)
    writeAssembly(JMP" NULL");
    yyparse();

    S_Functions * mainFunc=getFunctionByName("main");
    if (mainFunc != NULL){
      patchJumpAssembly(1, mainFunc->addr);
    }else{
      yyerror("Error missing function main !");
    }
    closeAssemblyOutput(outputPath);
    free(outputPath);

    resetFunctionsTable();
    resetSymbolTable();

    if(errorsOccured() > 0) {
        fprintf(stderr, "\x1b[0m\x1b[41m%d errors occured during compilation, which is aborted.\x1b[0m\n", errorsOccured());
        return FAILURE_COMPILATION;
    }

    return 0;
}
