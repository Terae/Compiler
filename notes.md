TP 

Token qui transitent de lex à yacc 
-- Définition de qui transite entre lex & yacc ( à écrire dans yacc)
%union{
 -- soit un entier
	int e; (nom de l'étiquette)
	-- soit une chaîne de char
	char * nb;
}

dans le lexe 
%% 
[0-9]+ { yield e=atoi(yytext) } -> on donne la valeur dans e


& dans le yacc

E : E + E
	| tNb + tNb { print "%d" $1 pour le premier tNb, et $3 pour le dernier }

Mais là, $1 pour le token tNb ça peut être e ou nb, donc le type est pas sur
Sauf si on fixe par 

%type<e> tNB -> token Nb sera forcément du type e
