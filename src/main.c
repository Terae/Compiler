#include <stdio.h>
#include "Symbols.h"

int main(){
	L_SYMBOL * list=createListSymbol();
	addSymbol(list,"a",Entier,0,400);
	addSymbol(list,"b",Entier,0,404);
	addSymbol(list,"c",Entier,1,408);
	int addr_b=getSymbolAddr(list,"b");	
	int addr_a=getSymbolAddr(list,"a");
	int addr_c=getSymbolAddr(list,"c");
	printf("Address a %d\n",addr_a);
	printf("Address b %d\n",addr_b);
	printf("Address c %d\n",addr_c);
	popDepth(list,1);
	popDepth(list,0);
	printTable(list);
}
