//
// Created by terae on 20/03/19.
//

#ifndef COMPILER_ASSEMBLY_H
#define COMPILER_ASSEMBLY_H

#include "Symbols.h"

//#define TEXT_ASSEMBLY

#if defined(TEXT_ASSEMBLY)

    #define r0 "r0"
    #define r1 "r1"
    #define r2 "r2"

    #define ADD   "ADD"   // 0x01
    #define MUL   "MUL"   // 0x02
    #define SOU   "SOU"   // 0x03
    #define DIV   "DIV"   // 0x04

    #define COP   "COP"   // 0x05
    #define AFC   "AFC"   // 0x06
    #define LOAD  "LOAD"  // 0x07
    #define STORE "STORE" // 0x08

    #define EQU   "EQU"   // 0x09
    #define INF   "INF"   // 0x0A
    #define INFE  "INFE"  // 0x0B
    #define SUP   "SUP"   // 0x0C
    #define SUPE  "SUPE"  // 0x0D

    #define JMP   "JMP"   // 0x0E
    #define JMPC  "JMPC"  // 0x0F

#else // defined(TEXT_ASSEMBLY)

    #define r0 "0"
    #define r1 "1"
    #define r2 "2"

    #define ADD   "1"
    #define MUL   "2"
    #define SOU   "3"
    #define DIV   "4"

    #define COP   "5"
    #define AFC   "6"
    #define LOAD  "7"
    #define STORE "8"

    #define EQU   "9"
    #define INF   "A"
    #define INFE  "B"
    #define SUP   "C"
    #define SUPE  "D"

    #define JMP   "E"
    #define JMPC  "F"

#endif

void initAssemblyOutput(const char *path);
void closeAssemblyOutput(char const *path);

void writeAssembly(const char *line, ...) __attribute__ ((__format__ (__printf__, 1, 2)));

S_SYMBOL *binaryOperation(const char *op, S_SYMBOL *s1, S_SYMBOL *s2);

S_SYMBOL *negate(S_SYMBOL *s);

S_SYMBOL *toBool(S_SYMBOL *s);

S_SYMBOL *modulo(S_SYMBOL *s1, S_SYMBOL *s2);

S_SYMBOL *bitnot(S_SYMBOL *s);

S_SYMBOL *bitand(S_SYMBOL *s1, S_SYMBOL *s2);

S_SYMBOL *bitxor(S_SYMBOL *s1, S_SYMBOL *s2);

S_SYMBOL *bitor(S_SYMBOL *s1, S_SYMBOL *s2);

S_SYMBOL *powerOfTwo(S_SYMBOL *s);

#endif //COMPILER_ASSEMBLY_H
