//
// Created by terae on 20/03/19.
//

#include "Error.h"

#include <stdio.h>
#include <stdlib.h>

#define NBR_ERRORS_MAX 10

extern int count_line;
static int count_error = 0;

void yyerror(const char *msg, ...) {
    va_list args;

    va_start(args, msg);
    fprintf(stderr, "\033[1;31mERROR line %d: \033[0m", count_line);
    vfprintf(stderr, msg, args);
    fputc('\n', stderr);
    va_end(args);

    count_error++;


    if (count_error >= NBR_ERRORS_MAX) {
        fprintf(stderr, "Too many errors, abandoning the compilation.\n");
        exit(FAILURE_COMPILATION);
    }
}

void warning(const char *msg, ...) {
    va_list args;

    va_start(args, msg);
    fprintf(stderr, "\033[1;35mWarning line %d:\033[0m ", count_line);
    vfprintf(stderr, msg, args);
    fputc('\n', stderr);
    va_end(args);
}

int errorsOccured() {
    return count_error;
}
