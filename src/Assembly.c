//
// Created by terae on 20/03/19.
//

#include "Assembly.h"
#include "Error.h"

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

void initAssemblyOutput(const char *path) {
    output = fopen(path, "w");
    if (output == NULL) {
        fprintf(stderr, "The output file '%s' has not been opened: %s\n", path, strerror(errno));
        exit(FAILURE_OPEN_OUTPUT);
    }
    bufferAssembly = malloc(1);
    bufferAssembly[0] = '\0';
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
}

void exportAssembly(const char *line, ...) {

}

void binaryOperation(const char *op, L_SYMBOL *TabSymbol) {
    int lastIndex = TabSymbol->size - 1;
    int addrLeft = getAddrByIndex(TabSymbol, lastIndex - 1);
    int addrRight = getAddrByIndex(TabSymbol, lastIndex);
    writeAssembly(LOAD" %s %d", r1, addrLeft);
    writeAssembly(LOAD" %s %d", r2, addrRight);
    writeAssembly("%s %s %s %s", op, r0, r1, r2);
}

void negate(L_SYMBOL *TabSymbol) {
    int lastIndex = TabSymbol->size - 1;
    int addrLeft = getAddrByIndex(TabSymbol, lastIndex);
    writeAssembly(LOAD" %s %d", r0, addrLeft);
    writeAssembly(AFC" %s %d", r1, 0);
    writeAssembly(EQU" %s %s %s", r0, r0, r1);
}
