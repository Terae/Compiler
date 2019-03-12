%{
    #include "y.tab.h"
%}

identifier      [_a-zA-Z][_a-zA-Z0-9]*
digit           [0-9]
octoDigit       [0-7]
hexaDigit       [0-9a-fA-F]
number          (({digit}+)|(0{octoDigit}+)|((0x|0X){hexaDigit}+))
numberExp       {digit}+(\.{digit}+)?((E|e)[+\-]?{digit}+)?

%x COMMENT_MODE
%x LCOMMENT_MODE

%%

"/*"                {BEGIN(COMMENT_MODE);}
<COMMENT_MODE>"*/"  {BEGIN(INITIAL);}
<COMMENT_MODE>.     {}
"//"                {BEGIN(LCOMMENT_MODE);}
<LCOMMENT_MODE>"\n" {BEGIN(INITIAL);}
<LCOMMENT_MODE>.    {}

"main"          {ECHO; return tID;}
"printf"        {ECHO; return tPRINTF;}

"const"         {ECHO; return tCONST;}
"int"           {ECHO; return tINT;}
"void"          {ECHO; return tVOID;}
"char"          {ECHO; return tCHAR;}
"enum"          {ECHO; return tENUM;}

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

"&&"            {ECHO; return tAND;}
"||"            {ECHO; return tOR;}
"true"          {ECHO; return tTRUE;}
"false"         {ECHO; return tFALSE;}

"{"             {ECHO; return tACCO;}
"}"             {ECHO; return tACCF;}
"("             {ECHO; return tPARO;}
")"             {ECHO; return tPARF;}
[ \t]+          {ECHO;}
[\n]            {ECHO;}


"+"             {ECHO; return tPLUS;}
"-"             {ECHO; return tMINUS;}
"/"             {ECHO; return tDIV;}
"*"             {ECHO; return tSTAR;}
"%"             {ECHO; return tMOD;}
"="             {ECHO; return tEQUAL;}
","             {ECHO; return tCOMMA;}
"!"             {ECHO; return tNOT;}
";"             {ECHO; return tSEMI;}

{identifier}    {ECHO; return tID;}
{number}        {ECHO; return tNBR;}
{numberExp}     {ECHO; return tNBR;}
