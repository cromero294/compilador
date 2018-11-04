/* 
 * Fichero: librera.h
 * Autor: Mario Calle y Alberto Garcia
 * Curso: 2017-178 */

#ifndef TABLASIMBOLOS_H
#define TABLASIMBOLOS_H

#include "tablaHash.h"

#define TAM_TABLA 100 

typedef enum { FALSE = 0, TRUE = 1 } BOOL;

typedef struct {
    TABLA_HASH* global;
    TABLA_HASH* local;
    BOOL abierto_local;
    BOOL abierto_global;
} TABLAS;

TABLAS* inicializar();
TABLA_HASH* crear_ambito(TABLAS* tablas);
STATUS cerrar_ambito(TABLAS* tablas);
INFO_SIMBOLO* buscar_ambito(TABLAS* tablas, char* lexema);
STATUS insertar(TABLAS* tablas, const char *lexema, CATEGORIA categ, TIPO tipo, CLASE clase, int adic1, int adic2);
BOOL isLocal(TABLAS* tablas);
BOOL estaEnLocal(TABLAS* tablas, char* lexema);

#endif