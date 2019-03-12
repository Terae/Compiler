.PHONY: clean yacc lex build run all
.DEFAULT_GOAL:= all

PROG_NAME=YaccUza
# yaccuza
# duralex
clean:
	rm -f *.c *.h $(PROG_NAME)

yacc:
	yacc -d compiler.y -v

lex:
	flex compiler.l

build: yacc lex
	gcc -o $(PROG_NAME) lex.yy.c y.tab.c -ll

run: build
	./$(PROG_NAME) < input

all: clean build run

$(V).SILENT:
