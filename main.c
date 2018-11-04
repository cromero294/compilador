#include <stdio.h>
#include "tablaSimbolos.h"

extern int yyleng;
extern FILE* yyin;
extern char* yytext;
extern int yylex();
extern int yyparse();
extern FILE* salida;
TABLAS* tablas;

int main(int argc, char** argv)
{
    
    if (argc != 3) {fprintf (stdout, "\n***Error: Pocos argumentos.\n"); return -1;}

    yyin = fopen(argv[1], "r");
    if(!yyin){
        fprintf(stdout, "\n***Error al abrir archivo de lectura.\n");
        return -1;
    }
    
    salida = fopen(argv[2], "w");
    if(!salida){
        fprintf(stdout, "\n***Error al abrir archivo de escritura.\n");
        fclose(yyin);
        return -1;
    }
    
    tablas = inicializar();
    crear_ambito(tablas);
    yyparse();
    cerrar_ambito(tablas);

    fclose(yyin);
    fclose(salida);

    return 1;
}