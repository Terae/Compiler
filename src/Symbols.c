//
// Created by terae on 12/03/19.
//

#include <malloc.h>
#include <string.h>
#include "Symbols.h"
#include "Error.h"
#include <stdio.h>
#include <assert.h>

static L_SYMBOL *SymbolTable = NULL;
static address_t ESP = 4000;
static char *tmpSymbol;

void freeSymbol(S_SYMBOL *tofree) {
    free(tofree->name);
    free(tofree);
}

/**
 * @description Initialize a symbols List
 */
void initSymbolTable(void) {
    tmpSymbol = strdup("__tmp__");

    SymbolTable = malloc(sizeof(L_SYMBOL));
    if (SymbolTable != NULL) {
        SymbolTable->size = 0;
        SymbolTable->head = NULL;
        SymbolTable->depth = 0;
    }
}

/**
 * @description Free the list
 */
void resetSymbolTable(void) {
    if (SymbolTable != NULL) {
        while ((SymbolTable)->head != NULL) {
            popHead();
        }
        free(SymbolTable);
    }
}

/**
 * @description Insert Symbol at the end
 * @param name const Char * Variable's name
 * @param type enum T_Type Variable's type
 * @return A pointer to the created symbol
 */
S_SYMBOL *createSymbol(const char *name, T_Type type) {
    S_SYMBOL *symbol = NULL;
    if (SymbolTable != NULL) {
        S_SYMBOL *aux = SymbolTable->head;
        while (aux != NULL) {
            if (strcmp(aux->name, tmpSymbol) != 0) {
                if (strcmp(aux->name, name) == 0) {
                    // The symbol already exists
                    yyerror("ERROR: Variable name already taken: %s", name);
                    return NULL;
                }
            }
            aux = aux->next;
        }

        symbol = malloc(sizeof(S_SYMBOL));
        symbol->index = SymbolTable->size;
        symbol->addr = ESP;
        symbol->depth = SymbolTable->depth;
        symbol->name = strdup(name);
        symbol->type = type;

        symbol->next = SymbolTable->head;
        SymbolTable->head = symbol;

        SymbolTable->size++;

        ESP += getSymbolSize(symbol);
    }
    return symbol;
}

/**
 * @description Pop last element
 */
void popHead() {
    if (SymbolTable != NULL) {
        if (SymbolTable->head != NULL) {
            S_SYMBOL *aux = SymbolTable->head;
            ESP -= aux->type;
            SymbolTable->head = aux->next;
            freeSymbol(aux);
            SymbolTable->size -= 1;
        }
    }
}

void pushBlock() {
    assert(SymbolTable->depth < MAX_DEPTH - 1);
    SymbolTable->depth++;
}

/**
 * @description Pop all Symbols at the end that matches the deepest block
 */
void popBlock() {
    assert(SymbolTable->depth > 0);

    if (SymbolTable->head != NULL) {
        while (SymbolTable->head->depth >= SymbolTable->depth) {
            popHead();
            if (SymbolTable->head == NULL) {
                break;
            }
        }
    }

    SymbolTable->depth--;
}

S_SYMBOL *createTmpSymbol(T_Type type) {
    return createSymbol(tmpSymbol, type);
}

/**
 * @description Pop all temporary Symbols at the end
 */
void popTmp(void) {
    if (SymbolTable != NULL) {
        while (SymbolTable->head != NULL && !strcmp(SymbolTable->head->name, tmpSymbol)) {
            popHead();
        }
    }
}

int isTmp(S_SYMBOL *s) {
    return s->name == tmpSymbol;
}

int getSymbolSize(const S_SYMBOL *s) {
    switch (s->type) {
        case Integer:
            return 4;
        case Character:
            return 1;
        case Error:
        default:
            yyerror("Impossible to find the size of the symbol %s", s->name);
            return 0;
    }
}

void printSymbolTable(L_SYMBOL *list) {
    if (list != NULL) {
        printf("\n/*********************************************************/\n");
        printf("Size : %d \n", list->size);
        printf("-----------------------------------------------------------\n");
        S_SYMBOL *aux = list->head;
        while (aux != NULL) {
            printf("Index : %d , varname : %s , address : %d, Type %d , depth %d \n", aux->index, aux->name, aux->addr,
                   aux->type, aux->depth);
            printf("-----------------------------------------------------------\n");
            aux = aux->next;
        }
        printf("/*********************************************************/\n\n");
    }
}

S_SYMBOL *getSymbolByName(const char *name) {
    S_SYMBOL *symbol = NULL;
    if (SymbolTable != NULL) {
        S_SYMBOL *aux = SymbolTable->head;
        while (aux != NULL && symbol == NULL) {
            if (strcmp(aux->name, tmpSymbol) != 0) {
                if (strcmp(name, aux->name) == 0) {
                    symbol = aux;
                }
            }
            aux = aux->next;
        }
    }
    return symbol;
}

S_SYMBOL *getSymbolByIndex(unsigned int index) {
    S_SYMBOL *symbol = NULL;
    if (SymbolTable != NULL) {
        S_SYMBOL *aux = SymbolTable->head;
        while (aux != NULL && symbol == NULL) {
            if (index == aux->index) {
                symbol = aux;
            }
            aux = aux->next;
        }
    }
    return symbol;
}
