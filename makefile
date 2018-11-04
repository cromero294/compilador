all: alfa

alfa: main.c lex.yy.c y.tab.c generacion.o tablaSimbolos.o tablaHash.o
	gcc -Wall -ansi -pedantic -o alfa main.c lex.yy.c y.tab.c generacion.o tablaSimbolos.o tablaHash.o

nasm:
	nasm -g -o salida.o -f elf32 salida.asm

salida:
	gcc -m32 -o salida salida.o alfalib.o

y.tab.c:
	bison -dyv alfa.y

lex.yy.c: alfa.h
	flex alfa.l alfa.h

generacion.o: generacion.c generacion.h tablaHash.h
	gcc -c -Wall -g -pedantic -ansi generacion.c

tablaSimbolos.o: tablaSimbolos.c tablaSimbolos.h tablaHash.h
	gcc -c -Wall -g -pedantic -g -ansi tablaSimbolos.c
	
tablaHash.o: tablaHash.c tablaHash.h
	gcc -c -Wall -g -pedantic -g -ansi tablaHash.c

clean:
	rm lex.yy.c y.tab.c alfa y.output y.tab.h generacion.o tablaHash.o tablaSimbolos.o