cmake_minimum_required(VERSION 3.13)
project(Compiler C)

add_executable(Interpreter src/Interpreter.c)

set(CMAKE_C_STANDARD 11)
SET(CMAKE_C_FLAGS " ${CMAKE_C_FLAGS} -Wall -Wextra -D_GNU_SOURCE=1 -std=gnu99") # -lfl

find_package(FLEX)
find_package(BISON)
flex_target(Lexer ${CMAKE_CURRENT_BINARY_DIR}/../src/compiler.l ${CMAKE_CURRENT_BINARY_DIR}/../src/lex.yy.c COMPILE_FLAGS "--header-file=${CMAKE_CURRENT_BINARY_DIR}/../src/lex.yy.h")
bison_target(Parser ${CMAKE_CURRENT_BINARY_DIR}/../src/compiler.y ${CMAKE_CURRENT_BINARY_DIR}/../src/syntax.c COMPILE_FLAGS "-d -v")

ADD_FLEX_BISON_DEPENDENCY(Lexer Parser)

set(SRC_FILES ${BISON_Parser_OUTPUTS} ${FLEX_Lexer_OUTPUTS} src/Symbols.c src/Error.c src/Assembly.c src/Functions.c)

include_directories(${CMAKE_CURRENT_BINARY_DIR}/../src)
add_executable(Symbols ${SRC_FILES})
