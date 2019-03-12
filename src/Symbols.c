//
// Created by terae on 12/03/19.
//

#include <malloc.h>
#include <string.h>
#include "Symbols.h"

/**
 * @description Create a List
 * @return L_SYMBO * list
 */
L_SYMBOL * createListSymbol(){
    L_SYMBOL * ret= malloc(sizeof(L_SYMBOL));
    if (ret!=NULL){
        ret->size=0;
        ret->head=NULL;
        ret->tail=NULL;
    }
    return ret;
}

/**
 * @description Insert Symbol at the end
 * @param list L_SYMBOL * list
 * @param name Char * Variable's name
 * @param type Char * Variable's type
 * @param depth int Depth
 * @param addr int Memory addr
 * @return -1 if nothing is inserted and 1 if insertion is ok.
 */
int addSymbol(L_SYMBOL * list, char * name, char * type, int depth, int addr) {
    int isInserted=-1;
    if (list!= NULL) {
        // Can't insert a symbol of depth 3 if the max depth is actually 5
        // This should assure order
        if (list->tail->depth<depth){
            S_SYMBOL *newSymbol = malloc(sizeof(S_SYMBOL));
            if (newSymbol != NULL) {
                newSymbol->addr = addr;
                newSymbol->depth = depth;
                newSymbol->name = strdup(name);
                newSymbol->type = strdup(type);
                newSymbol->next = NULL;

                if (list->tail == NULL) { // Liste vide
                    list->head = newSymbol;
                    list->tail = newSymbol;
                    newSymbol->prev = NULL;
                } else {
                    list->tail->next = newSymbol;
                    newSymbol->prev = list->tail;
                    list->tail = newSymbol;
                }
                list->size += 1;
                isInserted = 1;
            }
        }
    }
    return isInserted;
}
/**
 * @description Free the list
 * @param list L_SYMBOL ** list
 */
void freeList(L_SYMBOL ** list){
    if (*list != NULL){
        S_SYMBOL * aux=(*list)->head;
        while(aux != NULL){
            S_SYMBOL * to_free=aux;
            aux=to_free->next;
            free(to_free);
        }
        free(*list),*list=NULL;
    }
}
/**
 * @description Pop last element
 * @param L_SYMBOL list
 */
void popTail(L_SYMBOL * list){
    if (list != NULL) {
        S_SYMBOL * aux = list->tail;
        list->tail=aux->prev;
        list->tail->next=NULL;
        free(aux);
    }
}

/**
 * @description Pop all Symbols at the end that matches the same depth
 * @param list
 * @param depth
 * @return
 */
int popDepth(L_SYMBOL * list,int depth){
    int isPoped=-1;
    if (list!=NULL){
        while(list->tail->depth==depth){
            popTail(list);
        }
    }
    return isPoped;
}


