//
// Created by terae on 12/03/19.
//

#ifndef AUL_SYMBOLS_H
#define AUL_SYMBOLS_H

#define MAX_DEPTH 128

typedef unsigned int address_t;

typedef enum T_Type {
    Integer,
    Character,
    Error
} T_Type;

typedef struct Symbol {
    int index;
    address_t addr;
    char *name;
    enum T_Type type;
    /*int isConst;
    int isInitialized;*/
    unsigned int depth;
    struct Symbol *next;
} S_SYMBOL;

typedef struct ListSymbol {
    unsigned int size;
    unsigned int depth;
    S_SYMBOL *head;
} L_SYMBOL;

void initSymbolTable(void);

void resetSymbolTable(void);

S_SYMBOL *createSymbol(const char *name, T_Type type);

void popHead(void);

void pushBlock(void);

void popBlock(void);

/// Temporary variables manipulation
S_SYMBOL *createTmpSymbol(T_Type type);

void popTmp(void);

/// Meta-data of symbols
int isTmp(S_SYMBOL *s);

int getSymbolSize(const S_SYMBOL *s);

void printSymbolTable(L_SYMBOL *list);

S_SYMBOL *getSymbolByName(const char *name);

S_SYMBOL *getSymbolByIndex(unsigned int index);

#endif //AUL_SYMBOLS_H
