.PHONY: build clean lex
.DEFAULT_GOAL:= all

PROG_NAME=20100
clean:
	rm -f *.yy.c $(PROG_NAME)

lex:
	flex compiler.l

build: lex
	gcc -o $(PROG_NAME) lex.yy.c -ll

all: clean
	$(MAKE) lex
	$(MAKE) build
	$(MAKE) run

run:build
	cat input
	./$(PROG_NAME) < input

$(V).SILENT:
