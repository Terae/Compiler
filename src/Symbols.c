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
static address_t ESP_pers=0;
static char *tmpSymbol;

void freeSymbol(S_SYMBOL *tofree) {
    if (strcmp(tofree->name, "") != 0) {
        free(tofree->name);
    }
    free(tofree);
}

address_t getESP(){
	return ESP;
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
    if (strcmp(name, "") == 0) {
        yyerror("Empty variable name forbidden");
        return NULL;
    }

    S_SYMBOL *symbol = NULL;
    if (SymbolTable != NULL) {
        S_SYMBOL *aux = SymbolTable->head;
        while (aux != NULL) {
            if (strcmp(aux->name, tmpSymbol) != 0) {
                if (strcmp(aux->name, name) == 0) {
                    // The symbol already exists
                    yyerror("Variable name already taken: %s", name);
                    return NULL;
                }
            }
            aux = aux->next;
        }

        symbol = malloc(sizeof(S_SYMBOL));
        symbol->index = SymbolTable->size;
        symbol->addr = ESP_pers;
        symbol->depth = SymbolTable->depth;
        symbol->name = strdup(name);
        symbol->type = type;

        symbol->next = SymbolTable->head;
        SymbolTable->head = symbol;

        SymbolTable->size++;

        ESP_pers += getSymbolSize(symbol);
    }
    return symbol;
}

/**
 * @description Pop last element and all intermediate temporary values
 */
void popHead() {
    if (SymbolTable != NULL && SymbolTable->head != NULL) {
        do {
            S_SYMBOL *aux = SymbolTable->head;
            ESP_pers -= getSymbolSize(aux);
            SymbolTable->head = aux->next;
            freeSymbol(aux);
            SymbolTable->size -= 1;
        } while (SymbolTable->head != NULL && strcmp(SymbolTable->head->name, "") == 0);
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
void popAllTmp(void) {
    int count = 0;
    if (SymbolTable != NULL) {
        while (SymbolTable->head != NULL && (strcmp(SymbolTable->head->name, tmpSymbol) == 0 ||
                                             strcmp(SymbolTable->head->name, "") == 0)) {
            popHead();
            count++;
        }
    }
    // printf("popTmp called with %d tmp variables popped.\n", count);
}

void popOneTmp(void) {
    if (SymbolTable != NULL) {
        if (isTmp(SymbolTable->head)) {
            popHead();
        }
    }
}

int isTmp(S_SYMBOL *s) {
    return strcmp(s->name, tmpSymbol) == 0;
}

void freeIfTmp(S_SYMBOL *s) {
    if (isTmp(s)) {
        if (SymbolTable->head == s) {
            popHead();
        } else {
            // An intermediate temporary symbol will be released later
            s->name = "";
        }
    }
}

int getSymbolSize(const S_SYMBOL *s) {
    switch (s->type) {
        case Integer:
            return 2;
        case Character:
            return 2;
        case Boolean:
            return 2;
        case Void:
        case Error:
        default:
            yyerror("Impossible to find the size of the symbol %s", s->name);
            return 0;
    }
}

char *typeToString(T_Type type) {
    switch (type) {
        case Integer:
            return "int";
        case Character:
            return "char";
        case Boolean:
            return "bool";
        case Void:
            return "void";
        default:
            return "_error";
    }
}

void printSymbolTable() {
    if (SymbolTable != NULL) {
        printf("\n\033[0;32m/************************************************************************/\n");
        printf("Size : %d \n", SymbolTable->size);
        printf("-------------------------------------------------------------------------\n");
        S_SYMBOL *aux = SymbolTable->head;
        while (aux != NULL) {
            printf("Index: %d,\tvarname: '%s',\taddress: %d,\tType: %s,\tdepth: %d\n",
                   aux->index,
                   (strcmp(aux->name, tmpSymbol) == 0 ? "\x1b[3m\x1b[4mtmp\x1b[0m\033[0;32m" : aux->name),
                   aux->addr,
                   typeToString(aux->type),
                   aux->depth);
            printf("-------------------------------------------------------------------------\n");
            aux = aux->next;
        }
        printf("/************************************************************************/\033[0m\n\n");
    }
}

S_SYMBOL *getSymbolByName(const char *name) {
    S_SYMBOL *symbol = NULL;
    if (SymbolTable != NULL) {
        S_SYMBOL *aux = SymbolTable->head;
        while (aux != NULL && symbol == NULL) {
            if (strcmp(aux->name, tmpSymbol) != 0 && strcmp(aux->name, "") != 0) {
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
            if (strcmp(aux->name, "") != 0) {
                if (index == aux->index) {
                    symbol = aux;
                }
            }
            aux = aux->next;
        }
    }
    return symbol;
}

S_SYMBOL *getLastSymbol(void) {
    S_SYMBOL *symbol = NULL;
    if (SymbolTable != NULL) {
        S_SYMBOL *aux = SymbolTable->head;
        while (aux != NULL && symbol == NULL) {
            if (strcmp(aux->name, "") != 0) {
                symbol = aux;
            }
            aux = aux->next;
        }
    }
    return symbol;
}
