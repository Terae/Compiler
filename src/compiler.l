%{
    #include <stdio.h>
    #include <string.h>

    #include "y.tab.h"

    void yyerror(const char*);

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
<COMMENT_MODE>.     {}
"//"                {BEGIN(LCOMMENT_MODE);}
<LCOMMENT_MODE>"\n" {BEGIN(INITIAL);}
<LCOMMENT_MODE>.    {}

\"(\\.|[^\\"])*\"   {ECHO; const char* result = helperStringCleaner(yytext); return tSTRING_LITERAL;}

\'(\\.|[^\\'])+\'    {
                        ECHO;
                        const char* val = helperStringCleaner(yytext);
                        if(strlen(val) > 1) {
                            yyerror("A char literal can only be composed by a single character.");
                        }
                        return tCHAR_LITERAL;
                    }

"main"          {ECHO; return tID;}
"printf"        {ECHO; return tPRINTF;}

"const"         {ECHO; return tCONST;}
"int"           {ECHO; return tINT;}
"void"          {ECHO; return tVOID;}
"char"          {ECHO; return tCHAR;}
"enum"          {ECHO; return tENUM;}
"bool"          {ECHO; return tBOOL;}
"NULL"          {ECHO; return tNULL;}

"if"            {ECHO; return tIF;}
"else"          {ECHO; return tELSE;}
"switch"        {ECHO; return tSWITCH;}
"case"          {ECHO; return tCASE;}
"default"       {ECHO; return tDEFAULT;}
"for"           {ECHO; return tFOR;}
"while"         {ECHO; return tWHILE;}
"do"            {ECHO; return tDO;}
"break"         {ECHO; return tBREAK;}
"continue"      {ECHO; return tCONTINUE;}
"return"        {ECHO; return tRETURN;}
"sizeof"        {ECHO; return tSIZEOF;}

"&&"            {ECHO; return tAND;}
"||"            {ECHO; return tOR;}
"true"          {ECHO; return tTRUE;}
"false"         {ECHO; return tFALSE;}

">>="           {ECHO; return tRIGHT_ASSIGN;}
"<<="           {ECHO; return tLEFT_ASSIGN;}
"+="            {ECHO; return tADD_ASSIGN;}
"-="            {ECHO; return tSUB_ASSIGN;}
"*="            {ECHO; return tMUL_ASSIGN;}
"/="            {ECHO; return tDIV_ASSIGN;}
"%="            {ECHO; return tMOD_ASSIGN;}
"&="            {ECHO; return tAND_ASSIGN;}
"^="            {ECHO; return tXOR_ASSIGN;}
"|="            {ECHO; return tOR_ASSIGN;}

">>"            {ECHO; return tRIGHT_OP;}
"<<"            {ECHO; return tLEFT_OP;}
"->"            {ECHO; return tPTR_OP;}

"<="            {ECHO; return tLE;}
">="            {ECHO; return tGE;}
"=="            {ECHO; return tEQ;}
"!="            {ECHO; return tNE;}

("{"|"<%")      {ECHO; return '{';}
("}"|"%>")      {ECHO; return '}';}
"("             {ECHO; return '(';}
")"             {ECHO; return ')';}
[ \t]+          {ECHO;}
[\n]            {ECHO;}

"++"            {ECHO; return tINCR;}
"--"            {ECHO; return tDECR;}

"+"             {ECHO; return '+';}
"-"             {ECHO; return '-';}
"/"             {ECHO; return '/';}
"*"             {ECHO; return '*';}
"%"             {ECHO; return '%';}
"="             {ECHO; return '=';}
","             {ECHO; return ',';}
"!"             {ECHO; return '!';}
";"             {ECHO; return ';';}

("["|"<:")      {ECHO; return '[';}
("]"|":>")      {ECHO; return ']';}

"."             {ECHO; return '.';}
"~"             {ECHO; return '~';}
"^"             {ECHO; return '^';}
"?"             {ECHO; return '?';}
":"             {ECHO; return ':';}
"."             {ECHO; return '.';}
"<"             {ECHO; return '<';}
">"             {ECHO; return '>';}

{identifier}    {ECHO; return tID;}
{number}        {ECHO; return tNBR;}
{numberExp}     {ECHO; return tNBR;}

.               {/* ignore bad characters */}

%%

int yywrap(void) {
    return 1;
}
