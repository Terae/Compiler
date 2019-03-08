%%
"main" {printf("tMAIN\n");}
"printf" {printf("tPRINTF\n");}
"{" {printf("tACCO\n");}
"}" {printf("tACCF\n");}
"const" {printf("tCONST\n");}
"int" {printf("tINT\n");}
"if" {printf("tIF\n");}
"else" {printf("tELSE\n");}
"for" {printf("tFOR\n");}
"while" {printf("tWHILE\n");}
";" {printf("tPV\n");}
"(" {printf("tPARO\n");}
")" {printf("tPARF\n");}
"+" {printf("tPLUS\n");}
"-" {printf("tMINUS\n");}
"/" {printf("tSLASH\n");}
"*" {printf("tSTAR\n");}
"=" {printf("tEQU\n");}
[ \t,] {printf("tSEP\n");}
[\n] {printf("tNLINE\n");}
[a-zA-Z][a-zA-Z0-9_]* {printf("tID : \"%s\"\n",yytext);}
