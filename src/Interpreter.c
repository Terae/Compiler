//
// Created by terae on 29/03/19.
//

#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEBUG

#define STRINGIFY(X) #X

#define MAX_LINES      10000
#define SIZE_MEMORY    100000
#define SIZE_REGISTERS 16

#define ADD   0x1
#define MUL   0x2
#define SOU   0x3
#define DIV   0x4

#define COP   0x5
#define AFC   0x6
#define LOAD  0x7
#define STORE 0x8

#define EQU   0x9
#define INF   0xA
// #define INFE  0xB
// #define SUP   0xC
// #define SUPE  0xD

#define PRINT 0xB
#define SCANF 0xC

#define JMPR  0xD
#define JMP   0xE
#define JMPC  0xF

void print_help(const char *program) {
    fprintf(stderr, "Usage: %s <assembly_file.s>\n", program);
    exit(1);
}

void interprete(const char *path);

int main(int argc, const char **argv) {
    if (argc != 2) {
        print_help(argv[0]);
    }

    const char *extension = strrchr(argv[1], '.');
    if (!strcmp(extension, "s")) {
        print_help(argv[0]);
    }

    interprete(argv[1]);
}

typedef u_int16_t memory_size_t;
static memory_size_t *memory;
static memory_size_t registers[SIZE_REGISTERS];
static memory_size_t *r0, *r1, *r2, *esp, *tmpR;

void error_read(const char *op, int expected, int got) {
    fprintf(stderr, "The op code %s needs %d operand%s, but only %d found.\n", op, expected, (expected > 1 ? "s" : ""),
            got);
    exit(1);
}

#define READ_ONE(OP)   { int got = sscanf(line, "%hu",           &arg1);               if(got != 1) { error_read(OP, 1, got); } }
#define READ_TWO(OP)   { int got = sscanf(line, "%hu, %hu",      &arg1, &arg2);        if(got != 2) { error_read(OP, 2, got); } }
#define READ_THREE(OP) { int got = sscanf(line, "%hu, %hu, %hu", &arg1, &arg2, &arg3); if(got != 3) { error_read(OP, 3, got); } }

void debug_print_memory(int pc) {
#if defined(DEBUG)
    printf("Line: %d\nESP: %d\n", pc + 1, *esp);

    printf("r0: %hu\nr1: %hu\nr2: %hu\ntmpR: %hu\n", *r0, *r1, *r2, *tmpR);
    for (int i = 0; i < 10; ++i) {
        printf("\tmemory[%d]: %d\n", i, memory[i]);
    }
#endif
}

void debug_print_op(const char *op, const char *msg, ...) {
#if defined(DEBUG)
    va_list args;

    va_start(args, msg);
    printf("Operation '%s':\t", op);
    vprintf(msg, args);
    fputc('\n', stdout);
    va_end(args);
#endif
}

void debug_newline() {
#if defined(DEBUG)
    printf("\n");
#endif
}

/// @return The size of the given file
size_t get_file_size(FILE *file) {
    if (file == NULL) {
        return 0;
    }
    fseek(file, 0, SEEK_END);
    size_t size = (size_t)ftell(file);
    fseek(file, 0, SEEK_SET);
    return size;
}

u_int8_t extract_op_from_string(const char *line) {
    char *copy = strdup(line);
    strchr(copy, ' ')[0] = '\0';

    if (strcmp(copy, "ADD") == 0) {
        return ADD;
    }
    if (strcmp(copy, "MUL") == 0) {
        return MUL;
    }
    if (strcmp(copy, "SOU") == 0) {
        return SOU;
    }
    if (strcmp(copy, "DIV") == 0) {
        return DIV;
    }
    if (strcmp(copy, "COP") == 0) {
        return COP;
    }
    if (strcmp(copy, "AFC") == 0) {
        return AFC;
    }
    if (strcmp(copy, "LOAD") == 0) {
        return LOAD;
    }
    if (strcmp(copy, "STORE") == 0) {
        return STORE;
    }
    if (strcmp(copy, "EQU") == 0) {
        return EQU;
    }
    if (strcmp(copy, "INF") == 0) {
        return INF;
    }
    if (strcmp(copy, "PRINT") == 0) {
        return PRINT;
    }
    if (strcmp(copy, "SCANF") == 0) {
        return SCANF;
    }
    if (strcmp(copy, "JMPR") == 0) {
        return JMPR;
    }
    if (strcmp(copy, "JMP") == 0) {
        return JMP;
    }
    if (strcmp(copy, "JMPC") == 0) {
        return JMPC;
    }
    return 255;
}

u_int16_t *get_memory(int addr) {
    addr += *esp;
    assert(addr >= 0);
    assert(addr < SIZE_MEMORY);
    return &memory[addr];
}

u_int16_t *get_register(int addr) {
    assert(addr >= 0);
    assert(addr < SIZE_REGISTERS);
    return &registers[addr];
}

void interprete(const char *path) {
    FILE *assembly_file;
    char *assembly_source;

    size_t lines_count = 0;
    size_t lines_index[MAX_LINES] = {0};

    // Opening the assembly file to read its content
    assembly_file = fopen(path, "rb");
    if (assembly_file != NULL) {
        size_t size = get_file_size(assembly_file);

        assembly_source = malloc(size);

        if (assembly_source != NULL) {
            fread(assembly_source, 1, size, assembly_file);
            for (size_t i = 0, last = 0; i < size; ++i) {
                // Memoization of assembly lines for each instruction
                if (assembly_source[i] == '\n') {
                    lines_index[lines_count++] = last;
                    last = i + 1;
                }
            }
        }
        fclose(assembly_file);
    } else {
        fprintf(stderr, "Impossible to open the file: '%s'\n", path);
        return;
    }

    memory = malloc(SIZE_MEMORY * sizeof(int));
    memset(memory, 0x00, SIZE_MEMORY);

    u_int8_t op;
    u_int16_t arg1, arg2, arg3;
    int pc = 0;
    r0 = registers + 0;
    r1 = registers + 1;
    r2 = registers + 2;
    esp = registers + 3;
    tmpR = registers + 4;
    *esp = 0;

    for (u_int16_t reg = 0; reg < SIZE_REGISTERS; ++reg) {
        registers[reg] = 0;
    }

    while (pc < (int)lines_count) {
        char *line = &assembly_source[lines_index[pc]];
        strchr(line, '\n')[0] = '\0';

        // Allow comments
        if (line[0] == ';') {
#if defined(DEBUG)
            printf("\x1b[34m%s\n\x1b[0m", line);
#endif
            pc++;
            continue;
        }

        op = extract_op_from_string(line);

        line = strchr(line, ' ');

        debug_print_memory(pc);

        switch (op) {
            case ADD: {
                READ_THREE(STRINGIFY(ADD));
                *get_register(arg1) = *get_register(arg2) + *get_register(arg3);
                debug_print_op(STRINGIFY(ADD), "@%d <- @%d + @%d", arg1, arg2, arg3);
                break;
            }
            case MUL: {
                READ_THREE(STRINGIFY(MUL));
                *get_register(arg1) = *get_register(arg2) * *get_register(arg3);
                debug_print_op(STRINGIFY(MUL), "@%d <- @%d * @%d", arg1, arg2, arg3);
                break;
            }
            case SOU: {
                READ_THREE(STRINGIFY(SOU));
                *get_register(arg1) = *get_register(arg2) - *get_register(arg3);
                debug_print_op(STRINGIFY(SOU), "@%d <- @%d - @%d", arg1, arg2, arg3);
                break;
            }
            case DIV: {
                READ_THREE(STRINGIFY(DIV));
                *get_register(arg1) = *get_register(arg2) / *get_register(arg3);
                debug_print_op(STRINGIFY(DIV), "@%d <- @%d / @%d", arg1, arg2, arg3);
                break;
            }
            case COP: {
                READ_TWO(STRINGIFY(COP));
                *get_register(arg1) = *get_register(arg2);
                debug_print_op(STRINGIFY(COP), "@%d <- @%d", arg1, arg2);
                break;
            }
            case AFC: {
                READ_TWO(STRINGIFY(AFC));
                *get_register(arg1) = arg2;
                debug_print_op(STRINGIFY(AFC), "@%d <- %d", arg1, arg2);
                break;
            }
            case LOAD: {
                READ_TWO(STRINGIFY(LOAD));
                *get_register(arg1) = *get_memory(arg2);
                debug_print_op(STRINGIFY(LOAD), "@%d <- mem[%d]", arg1, arg2);
                break;
            }
            case STORE: {
                READ_TWO(STRINGIFY(STORE));
                *get_memory(arg1) = *get_register(arg2);
                debug_print_op(STRINGIFY(STORE), "mem[%d] <- @%d", arg1, arg2);
                break;
            }
            case EQU: {
                READ_THREE(STRINGIFY(EQU));
                *get_register(arg1) = (u_int16_t)(*get_register(arg2) == *get_register(arg3));
                debug_print_op(STRINGIFY(EQU), "@%d <- @%d == @%d", arg1, arg2, arg3);
                break;
            }
            case INF: {
                READ_THREE(STRINGIFY(INF));
                *get_register(arg1) = (u_int16_t)(*get_register(arg2) < *get_register(arg3));
                debug_print_op(STRINGIFY(INF), "@%d <- @%d < @%d", arg1, arg2, arg3);
                break;
            }
            /*case INFE: {
                READ_THREE(STRINGIFY(INFE));
                *get_register(arg1) = *get_register(arg2) <= *get_register(arg3);
                break;
            }
            case SUP: {
                READ_THREE(STRINGIFY(SUP));
                *get_register(arg1) = *get_register(arg2) > *get_register(arg3);
                break;
            }
            case SUPE: {
                READ_THREE(STRINGIFY(SUPE));
                *get_register(arg1) = *get_register(arg2) >= *get_register(arg3);
                break;
            }*/
            case PRINT: {
                READ_ONE(STRINGIFY(PRINT));
                debug_print_op(STRINGIFY(PRINT), "printf(%d)", arg1);
                printf("printf: \x1b[32m%d\x1b[0m\n", *get_memory(arg1));
                break;
            }
            case SCANF: {
                READ_ONE(STRINGIFY(SCANF));
                debug_print_op(STRINGIFY(SCANF), "scanf(%%d)");
                char c;
                if (scanf("%hu%c", &arg2, &c) != 2 || c != '\n') {
                    while (getchar() != '\n') {}
                    arg2 = 0;
                }
                *get_register(arg1) = arg2;
                break;
            }
            case JMPR: {
                READ_ONE(STRINGIFY(JMPR));
                pc = *get_register(arg1);
                debug_print_op(STRINGIFY(JMPR), "PC <- @%d", arg1);
                debug_newline();
                continue;
            }
            case JMP: {
                READ_ONE(STRINGIFY(JMP));
                pc = arg1;
                debug_print_op(STRINGIFY(JMP), "PC <- %d", arg1);
                debug_newline();
                continue;
            }
            case JMPC: {
                READ_TWO(STRINGIFY(JMPC));
                if (*get_register(arg2) == 0) {
                    pc = arg1;
                    debug_print_op(STRINGIFY(JMPC), "PC <- %d (@%d == 0)", arg1, arg2);
                    debug_newline();
                    continue;
                }
                debug_print_op(STRINGIFY(JMPC), "no conditional jump (@%d == %hu != 0)", arg2, *get_register(arg2));
                break;
            }
            default: {
                fprintf(stderr, "ERROR: unknown op code: '%d'. Assembly line: number %d, '%s'\n", op, pc, line);
                exit(1);
            }
        }
        pc++;
        debug_newline();
    }

#if defined(DEBUG)
    printf("\n\n=== END OF PROGRAM ===\nFinal memory state:");
    debug_print_memory(pc);
#endif

    free(memory);
    free(assembly_source);
}

