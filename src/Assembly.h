//
// Created by terae on 20/03/19.
//

#ifndef COMPILER_ASSEMBLY_H
#define COMPILER_ASSEMBLY_H

#define TEXT_ASSEMBLY

#if defined(TEXT_ASSEMBLY)

#define ADD   "ADD"   // 0x01
#define MUL   "MUL"   // 0x02
#define SOU   "SOU"   // 0x03
#define DIV   "DIV"   // 0x04

#define COP   "COP"   // 0x05
#define AFC   "AFC"   // 0x06
#define LOAD  "LOAD"  // 0x07
#define STORE "STORE" // 0x08

#define EQU   "EQU"   // 0x09
#define INF   "INF"   // 0xA
#define INFE  "INFE"  // 0xB
#define SUP   "SUP"   // 0xC
#define SUPE  "SUPE"  // 0xD

#define JMP   "JMP"   // 0xE
#define JMPC  "JMPC"  // 0xF

#else // defined(TEXT_ASSEMBLY)

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

#define r0 "r0"
#define r1 "r1"

void initAssemblyOutput(const char *path);
void closeAssemblyOutput(char const *path);

void writeAssembly(const char *line, ...) __attribute__ ((__format__ (__printf__, 1, 2)));

void exportAssembly(const char *line, ...) __attribute__ ((__format__ (__printf__, 1, 2)));

#endif //COMPILER_ASSEMBLY_H
