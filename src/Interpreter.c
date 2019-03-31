//
// Created by terae on 29/03/19.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define DEBUG

#define STRINGIFY(X) #X

#define STACK_CAPACITY 1000
#define MAX_LINES      10000
#define SIZE_MEMORY    100000

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

static int stack_size = 0;
static int sp = 0;
static int stack[STACK_CAPACITY];
static int *memory;

void push(int value) {
    assert(stack_size < STACK_CAPACITY - 1);
    stack[stack_size++] = value;
}

int pop(void) {
    assert(stack_size > 0);
    return stack[--stack_size];
}

void error_read(const char *op, int expected, int got) {
    fprintf(stderr, "The op code %s needs %d operand%s, but only %d found.\n", op, expected, (expected > 1 ? "s" : ""),
            got);
    exit(1);
}

#define READ_ONE(OP)   { int got = sscanf(line, "%d",       &arg1);               if(got != 1) { error_read(OP, 1, got); } }
#define READ_TWO(OP)   { int got = sscanf(line, "%d %d",    &arg1, &arg2);        if(got != 2) { error_read(OP, 2, got); } }
#define READ_THREE(OP) { int got = sscanf(line, "%d %d %d", &arg1, &arg2, &arg3); if(got != 3) { error_read(OP, 3, got); } }

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

/// @input Hexa value on a single byte and without the '0x' prefix
int hexa_to_int(char hexa) {
    if (hexa >= '0' && hexa <= '9') {
        return hexa - '0';
    }
    if (hexa >= 'A' && hexa <= 'F') {
        return hexa - 'A' + 10;
    }
    if (hexa >= 'a' && hexa <= 'f') {
        return hexa - 'a' + 10;
    }
    fprintf(stderr, "Invalid hexadecimal number: '0x%d'\n", hexa);
    exit(1);
}

int *get_memory(int addr) {
    addr += sp;
    assert(addr >= 0);
    assert(addr < SIZE_MEMORY);
    return &memory[addr];
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

    int op, arg1, arg2, arg3, pc = 0;

    while (pc < (int)lines_count) {
        char *line = &assembly_source[lines_index[pc]];
        op = hexa_to_int(line[0]);
        line++;

#if defined(DEBUG)
        printf("Line: %d\nStackPointer: %d\n", pc + 1, sp);

        for (int i = 0; i < 50; ++i) {
            printf("\tmemory[%d]: %d\n", i, memory[i]);
        }
        fputc('\n', stdout);
#endif

        switch (op) {
            case ADD: {
                READ_THREE(STRINGIFY(ADD));
                *get_memory(arg1) = *get_memory(arg2) + *get_memory(arg3);
                break;
            }
            case MUL: {
                READ_THREE(STRINGIFY(MUL));
                *get_memory(arg1) = *get_memory(arg2) * *get_memory(arg3);
                break;
            }
            case SOU: {
                READ_THREE(STRINGIFY(SOU));
                *get_memory(arg1) = *get_memory(arg2) - *get_memory(arg3);
                break;
            }
            case DIV: {
                READ_THREE(STRINGIFY(DIV));
                *get_memory(arg1) = *get_memory(arg2) / *get_memory(arg3);
                break;
            }
            case COP: {
                READ_TWO(STRINGIFY(COP));
                *get_memory(arg1) = *get_memory(arg2);
                break;
            }
            case AFC: {
                READ_TWO(STRINGIFY(AFC));
                *get_memory(arg1) = arg2;
                break;
            }
            case LOAD: {
                READ_TWO(STRINGIFY(LOAD));
                *get_memory(arg1) = memory[*get_memory(arg2)];
                break;
            }
            case STORE: {
                READ_TWO(STRINGIFY(STORE));
                memory[*get_memory(arg1)] = *get_memory(arg2);
                break;
            }
            case EQU: {
                READ_THREE(STRINGIFY(EQU));
                *get_memory(arg1) = *get_memory(arg2) == *get_memory(arg3);
                break;
            }
            case INF: {
                READ_THREE(STRINGIFY(INF));
                *get_memory(arg1) = *get_memory(arg2) < *get_memory(arg3);
                break;
            }
            /*case INFE: {
                READ_THREE(STRINGIFY(INFE));
                *get_memory(arg1) = *get_memory(arg2) <= *get_memory(arg3);
                break;
            }
            case SUP: {
                READ_THREE(STRINGIFY(SUP));
                *get_memory(arg1) = *get_memory(arg2) > *get_memory(arg3);
                break;
            }
            case SUPE: {
                READ_THREE(STRINGIFY(SUPE));
                *get_memory(arg1) = *get_memory(arg2) >= *get_memory(arg3);
                break;
            }*/
            case JMP: {
                READ_ONE(STRINGIFY(JWP));
                pc = arg1;
                continue;
            }
            case JMPC: {
                /*READ_TWO(STRINGIFY(JMPC));
                if(*get_memory(arg2) == 0) {
                    pc = arg1;
                    continue;
                }
                break;*/
                READ_ONE(STRINGIFY(JMPC));
                printf("%d", *get_memory(arg1));
                fflush(stdout);
                break;
            }
            default: {
                fprintf(stderr, "ERROR: unknown op code: '%d'\n", op);
                exit(1);
            }
        }
        pc++;
    }

    free(memory);
    free(assembly_source);
}
