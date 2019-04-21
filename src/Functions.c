//
// Created by terae on 09/04/19.
//

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "Functions.h"

static L_Functions * FunctionTable = NULL;

void initFunctionsTable(){
  FunctionTable = malloc(sizeof(L_Functions));
  if (FunctionTable != NULL) {
    FunctionTable->size = 0;
    FunctionTable->head = NULL;
  }
}

void freeFunction(S_Functions *tofree) {
  free(tofree->name);
  free(tofree);
}

void popHeadFunctions(){
  if (FunctionTable != NULL && FunctionTable->head != NULL) {
    S_Functions * aux = FunctionTable->head;
    FunctionTable->head = aux->next;
		freeFunction(aux);
    FunctionTable->size -= 1;
  }
}

void resetFunctionsTable(){
  if (FunctionTable != NULL) {
    while ((FunctionTable)->head != NULL) {
      popHeadFunctions();
    }
    free(FunctionTable);
  }
}

S_Functions * createSpecFunction(const char *name, unsigned int nbParam){
  S_Functions * aux =NULL;
	if (FunctionTable != NULL){
		aux = malloc(sizeof(S_Functions));
    aux->name=strdup(name);
    aux->nbParam=nbParam;
    // On suppose qu'aucune fonction sera à l'adresse 0 vu qu'il faudra initaliser esp etc.
    aux->addr = -1;
    if (FunctionTable->head != NULL){
      aux->next=FunctionTable->head;
      FunctionTable->head=aux;
    }else{
      aux->next=NULL;
      FunctionTable->head=aux;
    }
    FunctionTable->size+=1;
		//printf("Aux inserted at %d____",aux->addr);
  }
 	return aux;
}

void patchSpecFunction(S_Functions * f, int addr){
  if (FunctionTable != NULL){
    if (FunctionTable->head != NULL){
      if (f->addr == -1){
        f->addr= addr;
      }
    }
  }
}

S_Functions * createDeclarativeFunction(const char *name, int addr, unsigned int nbParam){
  S_Functions* aux=createSpecFunction(name,nbParam);
  if (aux != NULL){
    patchSpecFunction(aux,addr);
  }
  return aux;
}

S_Functions *  getFunctionByName(const char * name){
	S_Functions * aux = NULL;
  if (FunctionTable != NULL){
    if (FunctionTable->head != NULL){
			aux = FunctionTable->head;
      while (aux != NULL){
        if (strcmp(aux->name,name)==0){
          return aux;
        }
        aux=aux->next;
      }
    }
  }
	return aux;
}

void printFunctionsTable(){
	S_Functions * aux = NULL;
  if (FunctionTable != NULL){
		printf("\n\033[0;31m/*****************************************************/\n");
		printf("Size : %d\n",FunctionTable->size);
    if (FunctionTable->head != NULL){
			aux = FunctionTable->head;
      while (aux != NULL){
				printf("Functions : %s at %d\n",aux->name,aux->addr);
        aux=aux->next;
      }
			printf("/*****************************************************/\033[0m\n\n");
    }else{
			printf("Table function empty\n");
		}
  }else{
		printf("Table function not initialized\n");
	}
}
