%{
    #include <stdio.h>
    #include <string.h>

    #include "y.tab.h"

    void yyerror(const char*, ...);

    int count_line = 1;

    // Replace the first `N` characters of `target` by the `size` characters of `subsitution`
    void helperStringReplace(char *target, size_t N, const char* subsitution, size_t size) {
        if(size == 0) {
            size = strlen(subsitution);
        }

        memcpy(target, subsitution, size);
        size_t finalSize = strlen(target + N - size);
        memmove(target + size, target + N, finalSize);
        target[finalSize] = 0;
    }

    char *helperStringCleaner(const char* str) {
        // Remove both delimiters '"'
        size_t len = strlen(str) - 2;
        char* val = malloc(len + 1);
        strncpy(val, str + 1, len);
        val[len] = 0;

        // Simplification of the string
        char* pos = val;
        while((pos = strstr(pos, "\\n")) != NULL) {
            helperStringReplace(pos, 2, "\n", 0);
        }
        pos = val;
        while((pos = strstr(pos, "\\t")) != NULL) {
            helperStringReplace(pos, 2, "\t", 0);
        }
        pos = val;
        while((pos = strstr(pos, "\\\\")) != NULL) {
            helperStringReplace(pos, 2, "\\", 0);
        }

        return val;
    }

    #define echo printf("\x1b[34m"); ECHO; printf("\x1b[0m");
%}

identifier      [_a-zA-Z][_a-zA-Z0-9]*
digit           [0-9]
octoDigit       [0-7]
hexaDigit       [0-9a-fA-F]
number          (({digit}+)|(0{octoDigit}+)|(0[xX]{hexaDigit}+))
numberExp       {digit}+(\.{digit}+)?([eE][+\-]?{digit}+)?

%x COMMENT_MODE
%x LCOMMENT_MODE

%%

"/*"                {BEGIN(COMMENT_MODE);}
<COMMENT_MODE>"*/"  {BEGIN(INITIAL);}
<COMMENT_MODE>"\n"  {++count_line;}
<COMMENT_MODE>.     {}

"//"                {BEGIN(LCOMMENT_MODE);}
<LCOMMENT_MODE>"\n" {BEGIN(INITIAL); ++count_line;}
<LCOMMENT_MODE>.    {}

\"(\\.|[^\\"])*\"   {
                        echo;
                        yylval.string = helperStringCleaner(yytext);
                        return tSTRING_LITERAL;
                    }

\'(\\.|[^\\'])+\'    {
                        echo;
                        char* val = helperStringCleaner(yytext);
                        if(strlen(val) != 1) {
                            yyerror("A char literal can only be composed by a single character.");
                        }
                        yylval.string = val;
                        return tCHAR_LITERAL;
							//"main"          {echo; return tID;}
                    }
"printf"        {echo; return tPRINTF;}
"scanf"         {echo; return tSCANF;}

"const"         {echo; return tCONST;}
"int"           {echo; return tINT;}
"void"          {echo; return tVOID;}
"char"          {echo; return tCHAR;}
"enum"          {echo; return tENUM;}
"bool"          {echo; return tBOOL;}
"NULL"          {echo; return tNULL;}

"if"            {echo; return tIF;}
"else"          {echo; return tELSE;}
"switch"        {echo; return tSWITCH;}
"case"          {echo; return tCASE;}
"default"       {echo; return tDEFAULT;}
"for"           {echo; return tFOR;}
"while"         {echo; return tWHILE;}
"do"            {echo; return tDO;}
"break"         {echo; return tBREAK;}
"continue"      {echo; return tCONTINUE;}
"return"        {echo; return tRETURN;}
"sizeof"        {echo; return tSIZEOF;}

"&&"            {echo; return tAND;}
"||"            {echo; return tOR;}
"true"          {echo; return tTRUE;}
"false"         {echo; return tFALSE;}

">>="           {echo; return tRIGHT_ASSIGN;}
"<<="           {echo; return tLEFT_ASSIGN;}
"+="            {echo; return tADD_ASSIGN;}
"-="            {echo; return tSUB_ASSIGN;}
"*="            {echo; return tMUL_ASSIGN;}
"/="            {echo; return tDIV_ASSIGN;}
"%="            {echo; return tMOD_ASSIGN;}
"&="            {echo; return tAND_ASSIGN;}
"^="            {echo; return tXOR_ASSIGN;}
"|="            {echo; return tOR_ASSIGN;}

">>"            {echo; return tRIGHT_OP;}
"<<"            {echo; return tLEFT_OP;}
"->"            {echo; return tPTR_OP;}

"<="            {echo; return tLE;}
">="            {echo; return tGE;}
"=="            {echo; return tEQ;}
"!="            {echo; return tNE;}

("{"|"<%")      {echo; return '{';}
("}"|"%>")      {echo; return '}';}
"("             {echo; return '(';}
")"             {echo; return ')';}
[ \t]+          {echo;}
\n              {echo; ++count_line;}

"++"            {echo; return tINCR;}
"--"            {echo; return tDECR;}

"+"             {echo; return '+';}
"-"             {echo; return '-';}
"/"             {echo; return '/';}
"*"             {echo; return '*';}
"%"             {echo; return '%';}
"="             {echo; return '=';}
","             {echo; return ',';}
"!"             {echo; return '!';}
";"             {echo; return ';';}

("["|"<:")      {echo; return '[';}
("]"|":>")      {echo; return ']';}

"."             {echo; return '.';}
"~"             {echo; return '~';}
"^"             {echo; return '^';}
"?"             {echo; return '?';}
":"             {echo; return ':';}
"<"             {echo; return '<';}
">"             {echo; return '>';}

{identifier}    {
                    echo;
                    yylval.string = strdup(yytext);
                    return tID;
                }

{number}        {
                    echo;
                    char *str;
                    yylval.nbr = strtol(yytext, &str, 0);
                    if(str - yytext < (int)strlen(yytext)) {
                        yyerror("Invalid number constant: %s", yytext);
                    }
                    return tNBR;
                }

{numberExp}     {
                    echo;
                    char *str;
                    yylval.nbr = (int)strtod(yytext, &str);
                    if(str - yytext < (int)strlen(yytext)) {
                        yyerror("Invalid exponential number constant: %s", yytext);
                    }
                    return tNBR;
                }

.               {/* ignore bad characters */}

%%

int yywrap(void) {
    return 1;
}
