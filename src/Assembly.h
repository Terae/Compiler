//
// Created by terae on 20/03/19.
//

#ifndef COMPILER_ASSEMBLY_H
#define COMPILER_ASSEMBLY_H

#define ADD "ADD" // 0x01
#define SOU "SOU" // 0x03
#define MUL "MUL" // 0x02
#define DIV "DIV" // 0x04

void initAssemblyOutput(const char *path);
void closeAssemblyOutput(char const *path);

#endif //COMPILER_ASSEMBLY_H
