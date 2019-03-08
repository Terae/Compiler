%{
    #include "y.tab.h"
%}

identifier      [_a-zA-Z][_a-zA-Z0-9]*
digit           [0-9]
number          {digit}+

%%

"main"          {ECHO; return tMAIN;}
"printf"        {ECHO; return tPRINTF;}
"{"             {ECHO; return tACCO;}
"}"             {ECHO; return tACCF;}
"const"         {ECHO; return tCONST;}
"int"           {ECHO; return tINT;}
"if"            {ECHO; return tIF;}
"else"          {ECHO; return tELSE;}
"for"           {ECHO; return tFOR;}
"while"         {ECHO; return tWHILE;}
"break"         {ECHO; return tBREAK;}
"enum"          {ECHO; return tENUM;}
";"             {ECHO; return tPV;}
"("             {ECHO; return tPARO;}
")"             {ECHO; return tPARF;}
"+"             {ECHO; return tPLUS;}
"-"             {ECHO; return tMINUS;}
"/"             {ECHO; return tSLASH;}
"*"             {ECHO; return tSTAR;}
"="             {ECHO; return tEQU;}
","             {ECHO; return tVIRG;}
[ \t]           {}
[\n]            {}
{identifier}    {ECHO; return tID;}
{number}        {ECHO; return tNBR;}
