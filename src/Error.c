//
// Created by terae on 20/03/19.
//

#include "Error.h"

#include <stdarg.h>
#include <stdio.h>

void yyerror(const char* msg, ...) {
    va_list args;

    va_start(args, msg);
    char *total;
    vsprintf(total, msg, args);
    va_end(args);

    printf("ERROR: %s", total);
}

void warning(const char* msg, ...) {
    va_list args;

    va_start(args, msg);
    vfprintf(stderr, msg, args);
    fputc('\n', stderr);
    va_end(args);
}