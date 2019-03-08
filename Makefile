.PHONY: build clean lex
.DEFAULT_GOAL:= all

clean:
	rm -f *.yy.c compiler

lex:
	flex compiler.l

build: lex
	gcc -o compiler lex.yy.c -ll

all: clean
	$(MAKE) lex
	$(MAKE) build


$(V).SILENT:
