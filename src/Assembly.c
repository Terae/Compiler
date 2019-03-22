//
// Created by terae on 20/03/19.
//

#include "Assembly.h"
#include "Error.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static FILE *output = NULL;

void initAssemblyOutput(const char *path) {
    output = fopen(path, "w");
    if(output == NULL) {
        fprintf(stderr, "The output file '%s' has not been opened: %s\n", path, strerror(errno));
        exit(FAILURE_OPEN_OUTPUT);
    }
}

void closeAssemblyOutput(const char *path) {
    fclose(output);
}

void exportAssembly(const char *line, ...) {

}