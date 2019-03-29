%{
		#include <stdio.h>

    #include "Assembly.h"
    #include "Error.h"
    #include "Symbols.h"

    extern int const count_line;

    int yylex(void);

		int implementation_enabled = 1;


		/** Symbols **/
		// Global vars
		L_SYMBOL * TabSymbol;
		int depth=0;
		int ESP=4000;
		enum T_Type type_var;

		/** Symbols **/
		// functions
		void initSymbolTab(){
			TabSymbol=createListSymbol();
		}
		int addVar(char * name){
			int ret=addSymbol(TabSymbol,name,type_var,depth,ESP);
			if (ret==-1){
				yyerror("ERROR: Variable name already taken: %s", name);
			}else{
				ESP+=(int)type_var;
				printTable(TabSymbol);
			}
			return ret;
		}
%}

%union{
    int nbr;
    char * string;
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

End : ';' {ESP-=popTmp(TabSymbol);};

Program :         ExternalDeclaration
        | Program ExternalDeclaration;

ExternalDeclaration : FunctionDefinition
                    | Declaration;

FunctionDefinition : FinalType tID '(' Params ')' FunctionStatementCompound
                   | FinalType tID '(' Params ')' End;

TypeSpecifier : tINT {type_var=Integer;}
              | tVOID
              | tCHAR {type_var=Character;}
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

TypedDeclarationAssignment : tID  {addVar($1);} '=' ExpressionAssignment TypedDeclarationAssignmentNext;

TypedDeclarationNext : End
                     | ',' TypedDeclaration;
// Non-affected declaration : int a,b;
TypedDeclaration : tID {addVar($1);} TypedDeclarationNext
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

Constant : tNBR {
			int index=addVar("");
		 	int address = getAddrByIndex(TabSymbol, index);
		 	writeAssembly(AFC" %s %d", r0, $1);
			writeAssembly(STORE" %d %s", address, r0);
		}
         | tCHAR_LITERAL
         | tSTRING_LITERAL
         | tTRUE
         | tFALSE
         | tNULL;

ExpressionPrimary : tID {$1=addVar("");}
                  | Constant
                  | '(' Expression ')';

ExpressionPostfix : ExpressionPrimary
                  | ExpressionPostfix '{' {depth+=1;} Expression '}' {ESP-=popDepth(TabSymbol,depth);depth-=1;}
                  | ExpressionPostfix '(' ')'
                  | ExpressionPostfix '(' ArgumentExpressionList ')'
                  | ExpressionPostfix '.' tID
                  | ExpressionPostfix tPTR_OP tID
                  | ExpressionPostfix tINCR
                  	{
                        	int index=addVar("");
                                int address = getAddrByIndex(TabSymbol, index);
                                writeAssembly(AFC" %s %d", r0, 1);
                                writeAssembly(STORE" %d %s", address, r0);

                                binaryOperation(ADD, TabSymbol);
                                ESP-=popHead(TabSymbol);
                        }
                  | ExpressionPostfix tDECR
                  	{
                        	int index=addVar("");
                                int address = getAddrByIndex(TabSymbol, index);
                                writeAssembly(AFC" %s %d", r0, 1);
                                writeAssembly(STORE" %d %s", address, r0);

                                binaryOperation(SOU, TabSymbol);
                                ESP-=popHead(TabSymbol);
                        };

ArgumentExpressionList :                            ExpressionAssignment
                       | ArgumentExpressionList ',' ExpressionAssignment;

ExpressionUnary : ExpressionPostfix
                | tINCR   ExpressionUnary
                	{
                		int index=addVar("");
                		int address = getAddrByIndex(TabSymbol, index);
                		writeAssembly(AFC" %s %d", r0, 1);
                                writeAssembly(STORE" %d %s", address, r0);

                                binaryOperation(ADD, TabSymbol);
                                ESP-=popHead(TabSymbol);
                	}
                | tDECR   ExpressionUnary
                {
                	{
                		int index=addVar("");
                		int address = getAddrByIndex(TabSymbol, index);
                		writeAssembly(AFC" %s %d", r0, 1);
                		writeAssembly(STORE" %d %s", address, r0);

                		binaryOperation(SOU, TabSymbol);
				ESP-=popHead(TabSymbol);
                	}
                }
                | tSIZEOF ExpressionUnary
                | UnaryOperator ExpressionCast;

UnaryOperator : '&'
              | '*'
              | '+'
              | '-'
              | '~'
              | '!';

ExpressionCast : ExpressionUnary;
               | '(' FinalType ')' ExpressionCast;

// Multiplicative operators ('*', '/', '%')
ExpressionMultiplicative :                              ExpressionUnary
                         | ExpressionMultiplicative '*' ExpressionUnary
                         	{
                                	binaryOperation(MUL, TabSymbol);
                                        ESP-=popHead(TabSymbol);
                                }
                         | ExpressionMultiplicative '/' ExpressionUnary
                         	{
                                	binaryOperation(DIV, TabSymbol);
                                	ESP-=popHead(TabSymbol);
                                }
                         | ExpressionMultiplicative '%' ExpressionUnary;

// Additive operators ('+', '-')
ExpressionAdditive :                        ExpressionMultiplicative
                   | ExpressionAdditive '+' ExpressionMultiplicative
                   	{
                   		binaryOperation(ADD, TabSymbol);
                   		ESP-=popHead(TabSymbol);
                   	}
                   | ExpressionAdditive '-' ExpressionMultiplicative
                   	{
                   		binaryOperation(SOU, TabSymbol);
                   		ESP-=popHead(TabSymbol);
                   	}
                   ;

// Shift operators ('<<', '>>')
ExpressionShift :                           ExpressionAdditive
                | ExpressionShift tRIGHT_OP ExpressionAdditive
                | ExpressionShift tLEFT_OP  ExpressionAdditive;

// Relational operators ('<', '<=', '>', '>=')
ExpressionRelational :                          ExpressionShift
                     | ExpressionRelational '<' ExpressionShift
                     	{
                     		binaryOperation(INF, TabSymbol);
                     		ESP-=popHead(TabSymbol);
                     	}
                     | ExpressionRelational '>' ExpressionShift
                     	{
                     		binaryOperation(SUP, TabSymbol);
                     		ESP-=popHead(TabSymbol);
                     	}
                     | ExpressionRelational tLE ExpressionShift
                     	{
                     		binaryOperation(INFE, TabSymbol);
                     		ESP-=popHead(TabSymbol);
                     	}
                     | ExpressionRelational tGE ExpressionShift
                     	{
                     		binaryOperation(SUPE, TabSymbol);
                     		ESP-=popHead(TabSymbol);
                     	};

// Equality operators ('==', '!=')
ExpressionEquality :                        ExpressionRelational
                   | ExpressionEquality tEQ ExpressionRelational
                   	{
                   		binaryOperation(EQU, TabSymbol);
                   		ESP-=popHead(TabSymbol);
                   	}
                   | ExpressionEquality tNE ExpressionRelational
                   	{
                   		binaryOperation(EQU, TabSymbol);
                   		ESP-=popHead(TabSymbol);
                   		negate(TabSymbol);
                   	};

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

FunctionStatementCompound : '{' {depth+=1;} { if(implementation_enabled == 0) { yyerror("parameter name ommitted"); } }               '}' {ESP-=popDepth(TabSymbol,depth);depth-=1;}
                          | '{' {depth+=1;} { if(implementation_enabled == 0) { yyerror("parameter name ommitted"); } } BlockItemList '}' {ESP-=popDepth(TabSymbol,depth);depth-=1;};

StatementCompound : '{'{depth+=1;}               '}' {ESP-=popDepth(TabSymbol,depth);depth-=1;}
                  | '{'{depth+=1;} BlockItemList '}' {ESP-=popDepth(TabSymbol,depth);depth-=1;};

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
    initSymbolTab();
    char *outputPath = strdup("a.s");
    initAssemblyOutput(outputPath);

    yyparse();


    closeAssemblyOutput(outputPath);
    free(outputPath);

    freeList(TabSymbol);

    if(errorsOccured() > 0) {
    	vfprintf(stderr, "%d errors occured during compilation whicph is aborted.", errorsOccured());
    	return FAILURE_COMPILATION;
    }

    return 0;
}
