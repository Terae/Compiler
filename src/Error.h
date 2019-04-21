//
// Created by terae on 20/03/19.
//

#ifndef COMPILER_ERROR_H
#define COMPILER_ERROR_H

#include <errno.h>
#include <stdarg.h>
#include <stdio.h>

#define FAILURE_OPEN_OUTPUT 2
#define FAILURE_COMPILATION 3
#define FAILURE_INTERNAL 4

void yyerror(const char *, ...) __attribute__ ((__format__ (__printf__, 1, 2)));
void warning(const char *, ...) __attribute__ ((__format__ (__printf__, 1, 2)));

int errorsOccured();

#endif //COMPILER_ERROR_H
