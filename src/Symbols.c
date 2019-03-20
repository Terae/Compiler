//
// Created by terae on 12/03/19.
//

#include <malloc.h>
#include <string.h>
#include "Symbols.h"
#include <stdio.h>


int getSymbolAddr(L_SYMBOL * list, char * name){
	int found=-1;
	if (list != NULL){
		S_SYMBOL * aux = list->head;
		while (aux != NULL && found == -1){
			if (strcmp(name,aux->name) == 0){
				found=aux->addr;
			}
			aux=aux->next;
		}
	}	
	return found;
}

void free_symbol(S_SYMBOL * tofree){
    free(tofree->name);
    free(tofree);
}
/**
 * @description Create a List
 * @return L_SYMBO * list
 */
L_SYMBOL * createListSymbol(){
    L_SYMBOL * ret= malloc(sizeof(L_SYMBOL));
    if (ret!=NULL){
        ret->size=0;
        ret->head=NULL;
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
 * @return -1 if nothing is inserted and 0 if insertion is ok.
 */
int addSymbol(L_SYMBOL * list, char * name, enum T_Type type, int depth, int addr) {
    int isInserted=-1;
    if (list!= NULL) {
        S_SYMBOL *newSymbol = malloc(sizeof(S_SYMBOL));
        newSymbol->addr = addr;
        newSymbol->depth = depth;
        newSymbol->name=strdup(name);
        newSymbol->type = type;

        if (list->head != NULL) { // Liste vide
            newSymbol->next=list->head;
            list->head=newSymbol;
        }else{
        		newSymbol->next = NULL;
            list->head = newSymbol;
        }
        list->size += 1;
        isInserted = 0;
    }
    return isInserted;
}
/**
 * @description Pop last element
 * @param L_SYMBOL list
 */
void popHead(L_SYMBOL * list){
    if (list != NULL) {
        if (list->head!=NULL){
            S_SYMBOL * aux = list->head;
            list->head=aux->next;
            free_symbol(aux);
            list->size-=1;
        }
    }
}
/**
 * @description Free the list
 * @param list L_SYMBOL ** list
 */
void freeList(L_SYMBOL * listAddr){
	if (listAddr != NULL){
		while((listAddr)->head != NULL){
			popHead(listAddr);
		}
		free(listAddr);
  }
}


/**
 * @description Pop all Symbols at the end that matches the same depth
 * @param list
 * @param depth
 * @return
 */
void popDepth(L_SYMBOL * list,int depth){
    if (list!=NULL){
        if (list->head!=NULL){
            while(list->head->depth>=depth){
                popHead(list);
            }
        }
    }
}

void printTable(L_SYMBOL * list){
    if (list != NULL){
        printf("/*********************************************************/\n");
        printf("Size : %d \n",list->size);
        printf("-----------------------------------------------------------\n");
        S_SYMBOL * aux=list->head;
        while (aux != NULL){
            printf("Varname : %s , address : %x, Type %d , depth %d \n",aux->name,aux->addr,aux->type,aux->depth);
            printf("-----------------------------------------------------------\n");
            aux=aux->next;
        }
        printf("/*********************************************************/\n\n");
    }
}
