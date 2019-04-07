//
// Created by terae on 20/03/19.
//

#include "Assembly.h"
#include "Error.h"
#include "Symbols.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ASSEMBLY_SIZE 4096

static FILE *output = NULL;

/*typedef struct AssemblyLine {
    const char* OP;
    const char* arg1;
    const char* arg2;
    const char* arg3;
    const char* arg4;
} Assembly[MAX_ASSEMBLY_SIZE];
static int assembly_count = 0;*/
static char *bufferAssembly = NULL;
static const char *REPLACE_JUMP = "NULL";

void initAssemblyOutput(const char *path) {
    output = fopen(path, "w");
    if (output == NULL) {
        fprintf(stderr, "The output file '%s' has not been opened: %s\n", path, strerror(errno));
        exit(FAILURE_OPEN_OUTPUT);
    }
    bufferAssembly = malloc(1);
    bufferAssembly[0] = '\0';
    count_assembly = 0;
}

void closeAssemblyOutput(const char *path) {
    if (errorsOccured()) {
        fclose(output);
        remove(path);
    } else {
        fputs(bufferAssembly, output);
        fclose(output);
    }
    free(bufferAssembly);
}

void writeAssembly(const char *line, ...) {
    va_list args;
    va_start(args, line);

    char **buffer = &bufferAssembly;

    char *buf1, *buf2;
    vasprintf(&buf1, line, args);
    asprintf(&buf2, "%s%s\n", *buffer, buf1);
    free(buf1);
    free(*buffer);

    va_end(args);
    *buffer = buf2;
    count_assembly++;
}

void writeDebug(const char *line, ...) {
#if defined(DEBUG)
    va_list args;
    va_start(args, line);

    char **buffer = &bufferAssembly;

    char *buf1, *buf2;
    vasprintf(&buf1, line, args);
    asprintf(&buf2, "%s; %s\n", *buffer, buf1);
    free(buf1);
    free(*buffer);

    va_end(args);
    *buffer = buf2;
    count_assembly++;
#endif
}

char *getNthOccurence(char *str, char c, int n) {
    char *result = NULL;

    while (str != NULL && result == NULL) {
        if (n-- == 0) {
            result = str;
        }
        str = strchr(str, c) + 1;
    }
    return result;
}

void strreplace(char *src, const char *str, const char *rep) {
    char *p = strstr(src, str);
    if (p) {
        size_t len = strlen(src) + strlen(rep) - strlen(str);
        char r[len];
        memset(r, 0, len);
        if (p >= src) {
            strncpy(r, src, p - src);
            r[p - src] = '\0';
            strncat(r, rep, strlen(rep));
            strncat(r, p + strlen(str), p + strlen(str) - src + strlen(src));
            strcpy(src, r);
            strreplace(p + strlen(rep), str, rep);
        }
    }
}

void patchJumpAssembly(int assembly_line, int patch_addr) {
    char *line = getNthOccurence(bufferAssembly, '\n', assembly_line);
    char str[12];
    sprintf(str, "%d", patch_addr);
    strreplace(line, REPLACE_JUMP, str);
}

S_SYMBOL *binaryOperation(const char *op, S_SYMBOL *s1, S_SYMBOL *s2) {
    S_SYMBOL *result = createTmpSymbol(s1->type);

    writeDebug("operation %s", op);
    writeAssembly(LOAD" %s, %d", r1, s1->addr);
    writeAssembly(LOAD" %s, %d", r2, s2->addr);
    writeAssembly("%s %s, %s, %s", op, r0, r1, r2);
    writeAssembly(STORE" %d, %s", result->addr, r0);
    //writeAssembly("%s %d %d %d", op, result->addr, s1->addr, s2->addr);
    freeIfTmp(s2);
    freeIfTmp(s1);

    //int lastIndex = TabSymbol->size - 1;
    //int addrLeft = getAddrByIndex(TabSymbol, lastIndex - 1);
    //int addrRight = getAddrByIndex(TabSymbol, lastIndex);
    //writeAssembly(LOAD" %s %d", r1, addrLeft);
    //writeAssembly(LOAD" %s %d", r2, addrRight);
    //writeAssembly("%s %s %s %s", op, r0, r1, r2);

    return result;
}

S_SYMBOL *binaryOperationAssignment(const char *op, S_SYMBOL *id, S_SYMBOL *value) {
    if (isTmp(id)) {
        yyerror("Impossible to assign the result to a rvalue.");
        return NULL;
    }

    writeDebug("%s assignment operation", op);
    writeAssembly(LOAD" %s, %d", r1, id->addr);
    writeAssembly(LOAD" %s, %d", r2, value->addr);
    writeAssembly("%s %d, %d, %d", op, id->addr, id->addr, value->addr);
    freeIfTmp(value);
    return id;
}

void affectation(S_SYMBOL *id, S_SYMBOL *value) {
    if (isTmp(id)) {
        yyerror("Impossible to assign the result to a rvalue.");
        return;
    }

#if defined(DEBUG)
    writeAssembly(COP" %d, %d ; %s", id->addr, value->addr, id->name);
#else
    writeAssembly(COP" %d, %d", id->addr, value->addr);
#endif
    freeIfTmp(value);
}

S_SYMBOL *createConstant(T_Type type, int value) {
    S_SYMBOL *symbol = createTmpSymbol(type);
    writeDebug("create a '%s' const symbol with value %d", typeToString(type), value);
    writeAssembly(AFC" %s, %d", r0, value);
    writeAssembly(STORE" %d, %s", symbol->addr, r0);
    printSymbolTable();
    return symbol;
}

S_SYMBOL *negate(S_SYMBOL *s) {
    S_SYMBOL *zero = createTmpSymbol(Integer);

    writeDebug("negate the symbol %s (@%d)", s->name, s->addr);
    writeAssembly(AFC" %d, %d", zero->addr, 0);
    return binaryOperation(EQU, s, zero);
}

S_SYMBOL *toBool(S_SYMBOL *s) {
    S_SYMBOL *result = negate(negate(s));
    result->type = Boolean;
    return result;
}

S_SYMBOL *modulo(S_SYMBOL *s1, S_SYMBOL *s2) {
    writeDebug("@%d modulo @%d", s1->addr, s2->addr);
    S_SYMBOL *s1Copy = createTmpSymbol(Integer);
    S_SYMBOL *s2Copy = createTmpSymbol(Integer);
    writeAssembly(COP" %d, %d", s1Copy->addr, s1->addr);
    writeAssembly(COP" %d, %d", s2Copy->addr, s2->addr);

    S_SYMBOL *tmp = binaryOperation(DIV, s1, s2);
    S_SYMBOL *result = binaryOperation(MUL, tmp, s2Copy);

    return binaryOperation(SOU, s1Copy, result);
}

S_SYMBOL *bitnot(S_SYMBOL *s) {
    // TODO
    warning("'bitnot' not yet supported.");
    return NULL;
}

S_SYMBOL *bitand(S_SYMBOL *s1, S_SYMBOL *s2) {
    // TODO
    warning("'bitand' not yet supported.");
    return NULL;
}

S_SYMBOL *bitxor(S_SYMBOL *s1, S_SYMBOL *s2) {
    // TODO
    warning("'bitxor' not yet supported.");
    return NULL;
}

S_SYMBOL *bitor(S_SYMBOL *s1, S_SYMBOL *s2) {
    // TODO
    warning("'bitor' not yet supported.");
    return NULL;
}

S_SYMBOL *powerOfTwo(S_SYMBOL *s) {
    // TODO
    warning("'powerOfTwo' not yet supported.");
    return NULL;
}
