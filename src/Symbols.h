//
// Created by terae on 12/03/19.
//

#ifndef AUL_SYMBOLS_H
#define AUL_SYMBOLS_H

typedef struct Symbol {
    int addr;
    char *  name;
    char *  type;
    int depth;
    struct Symbol * prev;
    struct Symbol * next;
} S_SYMBOL;

typedef struct ListSymbol{
    unsigned int size;
    S_SYMBOL * head;
    S_SYMBOL * tail;
} L_SYMBOL;

L_SYMBOL * createListSymbol();

int addSymbol(L_SYMBOL * list, char * name, char * type, int depth, int addr);

void freeList(L_SYMBOL ** list);

int popDepth(L_SYMBOL * list, int depth);

#endif //AUL_SYMBOLS_H
