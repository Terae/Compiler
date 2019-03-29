.PHONY: clean lib yacc lex build run interpreter all
.DEFAULT_GOAL:= all
.ONESHELL:

SHELL=/bin/bash

SOURCE_DIR=src
BUILD_DIR=build
TEST_DIR=test
CHECKER=$(TEST_DIR)/checker.sh
SOURCE_FILES := Assembly.c Error.c Symbols.c
HEADER_FILES := Assembly.h Error.h Symbols.h

YACC_OUTPUT=y.tab
LEX_OUTPUT=lex.yy.c

PROG_NAME=YaccUza.out
# yaccuza
# duralex

clean:
	rm -f $(SOURCE_DIR)/syntax.* $(BUILD_DIR)/$(LEX_OUTPUT) $(BUILD_DIR)/$(YACC_OUTPUT).* $(BUILD_DIR)/*.output $(BUILD_DIR)/$(PROG_NAME)
	$(foreach file, $(SOURCE_FILES), rm -f $(BUILD_DIR)/$(file);)
	$(foreach file, $(HEADER_FILES), rm -f $(BUILD_DIR)/$(file);)

lib:
	$(foreach file, $(SOURCE_FILES), cp $(SOURCE_DIR)/$(file) $(BUILD_DIR)/;)
	$(foreach file, $(HEADER_FILES), cp $(SOURCE_DIR)/$(file) $(BUILD_DIR)/;)

yacc: $(SOURCE_DIR)/compiler.y
	mkdir -p $(BUILD_DIR)
	yacc -v -d $(SOURCE_DIR)/compiler.y -o $(BUILD_DIR)/$(YACC_OUTPUT).c

lex: $(SOURCE_DIR)/compiler.l yacc
	cd $(BUILD_DIR)
	flex ../src/compiler.l
	cd ..

build: clean lib yacc lex
	cd $(BUILD_DIR)
	gcc -o $(PROG_NAME) $(LEX_OUTPUT) $(YACC_OUTPUT).c $(SOURCE_FILES) -ll -ly

run: build
	$(BUILD_DIR)/$(PROG_NAME) < $(TEST_DIR)/input

# Automatic testing all the syntax
TestsNoGood:=$(shell cd $(TEST_DIR); ls impostor_C | egrep '^[0-9]+' | sort -n )
TestsGood  :=$(shell cd $(TEST_DIR); ls legitime_C | egrep '^[0-9]+' | sort -n )
test: build
	$(foreach file, $(TestsNoGood), $(SHELL) $(CHECKER) $(BUILD_DIR)/$(PROG_NAME) $(TEST_DIR)/impostor_C/$(file) 0; )
	echo ""
	$(foreach file, $(TestsGood),   $(SHELL) $(CHECKER) $(BUILD_DIR)/$(PROG_NAME) $(TEST_DIR)/legitime_C/$(file) 1; )

interpreter: $(SOURCE_DIR)/Interpreter.c
	gcc -g $(SOURCE_DIR)/Interpreter.c -o $(BUILD_DIR)/interpreter.out

all: build run

$(V).SILENT:
