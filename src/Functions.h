//
// Created by terae on 09/04/19.
//

#ifndef COMPILER_FUNCTIONS_H
#define COMPILER_FUNCTIONS_H



typedef struct f{
    int addr;
    char * name;
    unsigned int nbParam;
    struct f * next;
} S_Functions;

typedef struct {
    unsigned int size;
    S_Functions *head;
} L_Functions;

void initFunctionsTable(void);

void resetFunctionsTable(void);

S_Functions * createSpecFunction(const char *name, unsigned int nbParam);

void patchSpecFunction(S_Functions * f, int addr);

S_Functions * createDeclarativeFunction(const char *name, int addr, unsigned int nbParam);

S_Functions *  getFunctionByName(const char * name);

void printFunctionsTable();
#endif //COMPILER_FUNCTIONS_H
