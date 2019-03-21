//
// Created by terae on 12/03/19.
//

#ifndef AUL_SYMBOLS_H
#define AUL_SYMBOLS_H

enum T_Type {
	Integer=4,
	Character=1,
	Error=0
};

typedef struct Symbol {
    int addr;
    char *  name;
    enum T_Type type;
    /*int isConst;
    int isInitialized;*/
    int depth;
    struct Symbol * next;
} S_SYMBOL;

typedef struct ListSymbol{
    unsigned int size;
    S_SYMBOL * head;
} L_SYMBOL;

L_SYMBOL * createListSymbol();

int addSymbol(L_SYMBOL * list, char * name, enum T_Type type, int depth, int addr);

void freeList(L_SYMBOL * list);

int popDepth(L_SYMBOL * list, int depth);

void printTable(L_SYMBOL * list);

int getSymbolAddr(L_SYMBOL * list, char * name);

#endif //AUL_SYMBOLS_H
