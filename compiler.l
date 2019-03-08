%%
"main"      {printf("tmain\n");}
"printf"    {printf("tprintf\n");}
"{"         {printf("tacco\n");}
"}"         {printf("taccf\n");}
"const"     {printf("tconst\n");}
"int"       {printf("tint\n");}
"if"        {printf("tif\n");}
"else"      {printf("telse\n");}
"for"       {printf("tfor\n");}
"while"     {printf("twhile\n");}
"do"        {printf("tdo\n");}
"return"    {printf("tret\n");}
";"         {printf("tpv\n");}
"("         {printf("tparo\n");}
")"         {printf("tparf\n");}
"+"                     {printf("tplus\n");}
"-"                     {printf("tminus\n");}
"/"                     {printf("tslash\n");}
"*"                     {printf("tstar\n");}
"="                     {printf("tequ\n");}
[ \t,]                  {printf("tsep\n");}
[\n]                    {printf("tnline\n");}
[a-zA-Z][a-za-z0-9_]*   {printf("tid: \"%s\"\n", yytext);}
[0-9]+                  {printf("tnbr: \"%s\"\n", yytext);}
