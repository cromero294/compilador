#include <stdio.h>
#include <stdlib.h>
#include "tablaSimbolos.h"

TABLAS* inicializar(){
    TABLAS * tablas;

    tablas = (TABLAS*)malloc(sizeof(TABLAS));

    tablas->abierto_local = FALSE;
    tablas->abierto_global = FALSE;

    return tablas;
}

TABLA_HASH* crear_ambito(TABLAS* tablas){
    
    if (tablas->abierto_global == FALSE){
        tablas->global = crear_tabla(TAM_TABLA);
        tablas->abierto_global = TRUE;
        return tablas->global;
    }else if(tablas->abierto_local == FALSE && tablas->abierto_global == TRUE){
        tablas->local = crear_tabla(TAM_TABLA);
        tablas->abierto_local = TRUE;
        return tablas->local;
    } else{
        return NULL;
    }
}

STATUS cerrar_ambito(TABLAS* tablas){
    
    if (tablas->abierto_local == FALSE){
        liberar_tabla( tablas->global);
        return OK;
    }else{
        liberar_tabla(tablas->local);
        tablas->abierto_local = FALSE;
        return OK;
    }
    
    return ERR;
}

INFO_SIMBOLO* buscar_ambito(TABLAS* tablas, char* lexema){
    
    INFO_SIMBOLO* result;

    if (tablas->abierto_local == FALSE){
        return buscar_simbolo(tablas->global, lexema);
    }else{
        result = buscar_simbolo(tablas->local, lexema);
        if (!result){
            result = buscar_simbolo(tablas->global, lexema);
        }

        return result;
    }
}

STATUS insertar(TABLAS* tablas, const char *lexema, CATEGORIA categ, TIPO tipo, CLASE clase, int adic1, int adic2){
    
    

    if (tablas->abierto_local == FALSE){
        if(categ == FUNCION){
             if(buscar_simbolo(tablas->global, lexema)){
                return ERR;
            }
        }
        if(!insertar_simbolo(tablas->global, lexema, categ, tipo, clase, adic1, adic2)){
            return ERR;
        }
    }else{
        
        if (categ == VARIABLE){
            if (buscar_simbolo(tablas->local, lexema)){
                return ERR;
            } 
        } else if(categ == FUNCION){
             if(buscar_simbolo(tablas->global, lexema)){
                return ERR;
            }
        }

        if(!insertar_simbolo(tablas->local, lexema, categ, tipo, clase, adic1, adic2)){
            return ERR;
        }
    }
    
    return OK;
}

BOOL isLocal(TABLAS* tablas){
    if (tablas->abierto_local == FALSE){
        return FALSE;
    }else{
        return TRUE;
    }
}

BOOL estaEnLocal(TABLAS* tablas, char* lexema){
    
    INFO_SIMBOLO* result;

    if (tablas->abierto_local == TRUE){
        result = buscar_simbolo(tablas->local, lexema);
        if (result){
            return TRUE;
        }

        return FALSE;
    }
    
    return FALSE;
}