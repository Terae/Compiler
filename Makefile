.PHONY: clean yacc lex build run all
.DEFAULT_GOAL:= all
.ONESHELL:

SHELL=/bin/bash

SOURCE_DIR=src
BUILD_DIR=build
TEST_DIR=test

YACC_OUTPUT=y.tab
LEX_OUTPUT=lex.yy.c

PROG_NAME=YaccUza.out
# yaccuza
# duralex

clean:
	rm -f $(SOURCE_DIR)/syntax.* $(BUILD_DIR)/$(LEX_OUTPUT) $(BUILD_DIR)/$(YACC_OUTPUT).* $(BUILD_DIR)/*.output $(BUILD_DIR)/$(PROG_NAME)

yacc: $(SOURCE_DIR)/compiler.y clean
	mkdir -p $(BUILD_DIR)
	yacc -v -d $(SOURCE_DIR)/compiler.y -o $(BUILD_DIR)/$(YACC_OUTPUT).c

lex: $(SOURCE_DIR)/compiler.l yacc
	cd $(BUILD_DIR)
	flex ../src/compiler.l
	cd ..

build: yacc lex
	gcc -o $(BUILD_DIR)/$(PROG_NAME) $(BUILD_DIR)/$(LEX_OUTPUT) $(BUILD_DIR)/$(YACC_OUTPUT).c -ll

run: build
	$(BUILD_DIR)/$(PROG_NAME) < $(TEST_DIR)/input

# Automatic testing all the syntax
TestsNoGood:=$(shell cd $(TEST_DIR); ls impostor_C | egrep '^[0-9]+' | sort -n )
TestsGood:=$(shell cd $(TEST_DIR); ls legitime_C | egrep '^[0-9]+' | sort -n )
test: build
	$(foreach file, $(TestsNoGood), $(SHELL) $(TEST_DIR)/checker.sh $(BUILD_DIR)/$(PROG_NAME) $(TEST_DIR)/impostor_C/$(file) 0; )
	echo ""
	$(foreach file, $(TestsGood), $(SHELL) $(TEST_DIR)/checker.sh $(BUILD_DIR)/$(PROG_NAME) $(TEST_DIR)/legitime_C/$(file) 1; )

all: build run

$(V).SILENT:
