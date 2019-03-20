%{
    #include <stdio.h>

    #include "Assembly.h"
    #include "Error.h"
    #include "Symbols.h"

    int yylex(void);

    int implementation_enabled = 1;
%}

%union{
    int nbr;
    char const* string;
}

%token <nbr>    tNBR
%token <string> tID
%token <string> tCHAR_LITERAL
%token <string> tSTRING_LITERAL

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

End : ';';

Program :         ExternalDeclaration
        | Program ExternalDeclaration;

ExternalDeclaration : FunctionDefinition
                    | Declaration;

FunctionDefinition : FinalType tID '(' Params ')' FunctionStatementCompound
                   | FinalType tID '(' Params ')' End;

TypeSpecifier : tINT
              | tVOID
              | tCHAR
              | tBOOL;

TypeQualifier : tCONST;

TypeQualifierList :                   TypeQualifier
                  | TypeQualifierList TypeQualifier;

Pointer : TypeQualifierList '*' Pointer
        | TypeQualifierList '*'
        | '*' Pointer
        | '*';

FinalType :                   TypeSpecifier
          |                   TypeSpecifier Pointer
          | TypeQualifierList TypeSpecifier
          | TypeQualifierList TypeSpecifier Pointer;

TypedDeclarationAssignmentNext : End
                               | ',' TypedDeclarationAssignment;

TypedDeclarationAssignment : tID '=' ExpressionAssignment TypedDeclarationAssignmentNext;

TypedDeclarationNext : End
                     | ',' TypedDeclaration;

TypedDeclaration : tID TypedDeclarationNext
                 | TypedDeclarationAssignment;

Declaration : FinalType TypedDeclaration;

// int a, char c, ...
// Left recursion is better than right recursion for memory management (not so much 'shift' before reduce-ing)
ParamsNamedList :                     ParamNamed
                | ParamsNamedList ',' ParamNamed;

ParamNamed : FinalType tID;

// int, char, ...
ParamsUnnamedList :                       ParamUnnamed
                  | ParamsUnnamedList ',' ParamUnnamed;

ParamUnnamed : FinalType;

Params :                   { implementation_enabled = 1; }
       | ParamsNamedList   { implementation_enabled = 1; }
       | ParamsUnnamedList { implementation_enabled = 0; };

Constant : tNBR
         | tCHAR_LITERAL
         | tSTRING_LITERAL
         | tTRUE
         | tFALSE
         | tNULL;

ExpressionPrimary : tID
                  | Constant
                  | '(' Expression ')';

ExpressionPostfix : ExpressionPrimary
                  | ExpressionPostfix '{' Expression '}'
                  | ExpressionPostfix '(' ')'
                  | ExpressionPostfix '(' ArgumentExpressionList ')'
                  | ExpressionPostfix '.' tID
                  | ExpressionPostfix tPTR_OP tID
                  | ExpressionPostfix tINCR
                  | ExpressionPostfix tDECR;

ArgumentExpressionList :                            ExpressionAssignment
                       | ArgumentExpressionList ',' ExpressionAssignment;

ExpressionUnary : ExpressionPostfix
                | tINCR   ExpressionUnary
                | tDECR   ExpressionUnary
                | tSIZEOF ExpressionUnary
                | UnaryOperator ExpressionCast;

UnaryOperator : '&'
              | '*'
              | '+'
              | '-'
              | '~'
              | '!';

ExpressionCast : ExpressionUnary;
               //| '(' TypeName ')' ExpressionCast;

// Multiplicative operators ('*', '/', '%')
ExpressionMultiplicative :                              ExpressionUnary
                         | ExpressionMultiplicative '*' ExpressionUnary
                         | ExpressionMultiplicative '/' ExpressionUnary
                         | ExpressionMultiplicative '%' ExpressionUnary;

// Additive operators ('+', '-')
ExpressionAdditive :                        ExpressionMultiplicative
                   | ExpressionAdditive '+' ExpressionMultiplicative
                   | ExpressionAdditive '-' ExpressionMultiplicative;

// Shift operators ('<<', '>>')
ExpressionShift :                           ExpressionAdditive
                | ExpressionShift tRIGHT_OP ExpressionAdditive
                | ExpressionShift tLEFT_OP  ExpressionAdditive;

// Relational operators ('<', '<=', '>', '>=')
ExpressionRelational :                          ExpressionShift
                     | ExpressionRelational '<' ExpressionShift
                     | ExpressionRelational '>' ExpressionShift
                     | ExpressionRelational tLE ExpressionShift
                     | ExpressionRelational tGE ExpressionShift;

// Equality operators ('==', '!=')
ExpressionEquality :                        ExpressionRelational
                   | ExpressionEquality tEQ ExpressionRelational
                   | ExpressionEquality tNE ExpressionRelational;

// Bitwise AND operator ('&')
ExpressionAnd :                   ExpressionEquality
              | ExpressionAnd '&' ExpressionEquality;

// Bitwise XOR operator ('^')
ExpressionExclusiveOr :                           ExpressionAnd
                      | ExpressionExclusiveOr '^' ExpressionAnd;

// Bitwise OR operator ('|')
ExpressionInclusiveOr :                           ExpressionExclusiveOr
                      | ExpressionInclusiveOr '|' ExpressionExclusiveOr;

// Logical AND operator ('&&')
ExpressionLogicalAnd :                           ExpressionInclusiveOr
                     | ExpressionLogicalAnd tAND ExpressionInclusiveOr;

// Logical OR operator ('||')
ExpressionLogicalOr :                         ExpressionLogicalAnd
                    | ExpressionLogicalOr tOR ExpressionLogicalAnd;

// Conditional operator (… '?' … ':' …)
ExpressionConditional : ExpressionLogicalOr
                      | ExpressionLogicalOr '?' Expression ':' ExpressionConditional;

// Assignment operators ('=', '<<=', '>>=', '+=', '-=', '*=', '/=', '%=', '&=', '^=', '|=')
ExpressionAssignment : ExpressionConditional
                     | ExpressionUnary AssignmentOperator ExpressionAssignment;

AssignmentOperator : '='
                   | tRIGHT_ASSIGN
                   | tLEFT_ASSIGN
                   | tADD_ASSIGN
                   | tSUB_ASSIGN
                   | tMUL_ASSIGN
                   | tDIV_ASSIGN
                   | tMOD_ASSIGN
                   | tAND_ASSIGN
                   | tXOR_ASSIGN
                   | tOR_ASSIGN;

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

FunctionStatementCompound : '{' { if(implementation_enabled == 0) { yyerror("parameter name ommitted"); } } '}'
                          | '{' { if(implementation_enabled == 0) { yyerror("parameter name ommitted"); } } BlockItemList '}';

StatementCompound : '{'               '}'
                  | '{' BlockItemList '}';

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
    yyparse();

    return 0;
}
