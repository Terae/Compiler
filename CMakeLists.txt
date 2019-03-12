cmake_minimum_required(VERSION 3.13)
project(aul C)

set(CMAKE_C_STANDARD 11)
SET(CMAKE_C_FLAGS "-lfl ${CMAKE_C_FLAGS} -Wall -Wextra")

find_package(FLEX)
find_package(BISON)
flex_target(Lexer ${CMAKE_CURRENT_BINARY_DIR}/../src/lex.l ${CMAKE_CURRENT_BINARY_DIR}/../src/lex.yy.c COMPILE_FLAGS "--header-file=${CMAKE_CURRENT_BINARY_DIR}/../src/lex.yy.h")
bison_target(Parser ${CMAKE_CURRENT_BINARY_DIR}/../src/syntax.y ${CMAKE_CURRENT_BINARY_DIR}/../src/syntax.c COMPILE_FLAGS "-d")

ADD_FLEX_BISON_DEPENDENCY(Lexer Parser)

set(SRC_FILES src/main.c ${BISON_Parser_OUTPUTS} ${FLEX_Lexer_OUTPUTS} src/ast.h src/ast.c)

include_directories(${CMAKE_CURRENT_BINARY_DIR}/../src)
add_executable(aul ${SRC_FILES})