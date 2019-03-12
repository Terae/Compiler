cmake_minimum_required(VERSION 3.13)
project(Compiler)

set(CMAKE_CXX_STANDARD 14)

include_directories(src)

add_executable(Compiler
        cmake-build-debug/cmake_install.cmake
        cmake-build-debug/CMakeCache.txt
        cmake-build-debug/Compiler.cbp
        cmake-build-debug/Makefile
        src/compiler.l
        src/compiler.y
        src/lex.yy.h
        src/main.c
        src/Symbols.c
        src/Symbols.h
        src/syntax.c
        src/syntax.h
        CMakeLists.txt
        input
        input.bak
        Makefile
        Projet_Syst_Info_2018.pdf
        README.md
        y.output)
