//
// Created by terae on 20/03/19.
//

#ifndef COMPILER_ASSEMBLY_H
#define COMPILER_ASSEMBLY_H

#include "Symbols.h"

extern int count_assembly;

#define TEXT_ASSEMBLY
#define DEBUG

#if defined(DEBUG)
    #define r0  "r0"
    #define r1  "r1"
    #define r2  "r2"
    #define esp "esp"
    #define tmpR "tmpR"
#else
    #define r0  "00"
    #define r1  "01"
    #define r2  "02"
    #define esp "03"
    #define tmpR "04"
#endif
#if defined(TEXT_ASSEMBLY)

    #define ADD   "ADD  " // 0x01
    #define MUL   "MUL  " // 0x02
    #define SOU   "SOU  " // 0x03
    #define DIV   "DIV  " // 0x04

    #define COP   "COP  " // 0x05
    #define AFC   "AFC  " // 0x06
    #define LOAD  "LOAD " // 0x07
    #define STORE "STORE" // 0x08

    #define EQU   "EQU  " // 0x09
    #define INF   "INF  " // 0x0A
    // #define INFE  "INFE"  // 0x0B
    // #define SUP   "SUP"   // 0x0C
    // #define SUPE  "SUPE"  // 0x0D

    #define PRINT "PRINT" // 0x0B
    #define SCANF "SCANF" // 0x0C

    #define JMP   "JMP  " // 0x0E
    #define JMPC  "JMPC " // 0x0F

    #define PUSH  "PUSH " // 0x10
    #define POP   "POP  " // 0x11

#else // defined(TEXT_ASSEMBLY)

    #define ADD   "0x01"
    #define MUL   "0x02"
    #define SOU   "0x03"
    #define DIV   "0x04"

    #define COP   "0x05"
    #define AFC   "0x06"
    #define LOAD  "0x07"
    #define STORE "0x08"

    #define EQU   "0x09"
    #define INF   "0x0A"
    // #define INFE  "B"
    // #define SUP   "C"
    // #define SUPE  "D"

    #define PRINT "0x0B"
    #define SCANF "0x0C"

    #define JMP   "0x0E"
    #define JMPC  "0x0F"

    #define PUSH  "0x10"
    #define POP   "0x11"

#endif

void initAssemblyOutput(const char *path);
void closeAssemblyOutput(char const *path);

void writeAssembly(const char *line, ...) __attribute__ ((__format__ (__printf__, 1, 2)));

void writeDebug(const char *line, ...) __attribute__ ((__format__ (__printf__, 1, 2)));

void patchJumpAssembly(int assembly_line, int patch_addr);

S_SYMBOL *binaryOperation(const char *op, S_SYMBOL *s1, S_SYMBOL *s2);

S_SYMBOL *binaryOperationAssignment(const char *op, S_SYMBOL *id, S_SYMBOL *value);

void affectation(S_SYMBOL *id, S_SYMBOL *value);

S_SYMBOL *createConstant(T_Type type, int value);

S_SYMBOL *negate(S_SYMBOL *s);

S_SYMBOL *toBool(S_SYMBOL *s);

S_SYMBOL *modulo(S_SYMBOL *s1, S_SYMBOL *s2);

S_SYMBOL *bitnot(S_SYMBOL *s);

S_SYMBOL *bitand(S_SYMBOL *s1, S_SYMBOL *s2);

S_SYMBOL *bitxor(S_SYMBOL *s1, S_SYMBOL *s2);

S_SYMBOL *bitor(S_SYMBOL *s1, S_SYMBOL *s2);

S_SYMBOL *powerOfTwo(S_SYMBOL *s);

#endif //COMPILER_ASSEMBLY_H
