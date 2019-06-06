//
// Created by terae on 12/03/19.
//

#ifndef AUL_SYMBOLS_H
#define AUL_SYMBOLS_H

#define MAX_DEPTH 128

typedef unsigned int address_t;

typedef enum Type {
    Integer,
    Character,
    Boolean,
    Void,
    Error
} T_Type;

typedef enum Qualifier {
    Nothing,
    Const
} T_Qualifier;

typedef struct Symbol {
    unsigned int index;
    address_t addr;
    char *name;
    T_Type type;
    T_Qualifier qualifier;
    int isInitialized;
    unsigned int depth;
    struct Symbol *next;
} S_SYMBOL;

typedef struct ListSymbol {
    unsigned int size;
    unsigned int depth;
    S_SYMBOL *head;
} L_SYMBOL;

// init tableSybol
void initSymbolTable(void);

// reset
void resetSymbolTable(void);

// Create a symbol with a type
S_SYMBOL *createSymbol(const char *name, T_Type type, T_Qualifier qualifier);

// Remove the last element of our stack
void popHead(void);

// Increase depth
void pushBlock(void);

// Decrease depth & remove all last depth var
void popBlock(void);

/// Temporary variables manipulation
S_SYMBOL *createTmpSymbol(T_Type type);

// To create temporary variables from already defined ones
S_SYMBOL *createTmpSymbolFromSymbol(S_SYMBOL *symb);

// Remove all tmp at the top of our stack
void popAllTmp(void);

// Remove only one tmp
void popOneTmp(void);

/// Meta-data of symbols
int isConst(S_SYMBOL *s);
int isTmp(S_SYMBOL *s);
int isInitialized(S_SYMBOL *s);

S_SYMBOL *getConstUninitialized();

// Free it if tmp only
void freeIfTmp(S_SYMBOL *s);

// get the memory size of the symbol
int getSymbolSize(const S_SYMBOL *s);

// Show it
char *typeToString(T_Type type);
char *qualifierToString(T_Qualifier qualifier);

// To print (debug) in green
void printSymbolTable();

// Search function by name
S_SYMBOL *getSymbolByName(const char *name);

// Search function by index
S_SYMBOL *getSymbolByIndex(unsigned int index);

// Get the last one defined
S_SYMBOL *getLastSymbol(void);

// Get first value of ESP constant.
address_t getESP();

#endif //AUL_SYMBOLS_H

