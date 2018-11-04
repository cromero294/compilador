%{
    #include <stdio.h>
    #include <string.h>

    #include "alfa.h"
    #include "generacion.h"
    #include "tablaSimbolos.h"
    #include "tablaHash.h"

    extern FILE* salida;

    extern int linea;
    extern int columna;
    extern int flag;

    int tipo_actual;
    int clase_actual;
    int tamanio_vector_actual;
    int pos_parametro_actual=0;
    int num_parametros_actual=0;
    int pos_variable_local_actual = 1;
    int num_variables_locales_actual = 0;
    int cuantos_no = 0;
    int etiqueta = 0;
    int en_explist = 0;
    int num_parametros_llamada_actual = 0;
    int fn_return = 0;

    extern TABLAS* tablas;

    void yyerror(char* s){
        if(flag != 1){
            printf("****Error sintactico en [lin %d, col %d]\n", linea, columna);
            return;
        }
        
        return;
    }
%}

%union
{
    tipo_atributos atributos;
}

%token <atributos> TOK_IDENTIFICADOR
%token <atributos> TOK_CONSTANTE_ENTERA

%token TOK_MAIN
%token TOK_INT
%token TOK_BOOLEAN
%token TOK_ARRAY
%token TOK_FUNCTION
%token TOK_IF
%token TOK_ELSE
%token TOK_WHILE
%token TOK_SCANF
%token TOK_PRINTF
%token TOK_AND
%token TOK_OR
%token TOK_IGUAL
%token TOK_DISTINTO
%token TOK_MENORIGUAL
%token TOK_MAYORIGUAL
%token TOK_TRUE
%token TOK_FALSE
%token TOK_RETURN
%token TOK_ERROR

%type <atributos> exp
%type <atributos> comparacion
%type <atributos> constante_entera
%type <atributos> constante_logica
%type <atributos> constante
%type <atributos> identificador
%type <atributos> if_exp
%type <atributos> condicional
%type <atributos> if_exp_sentencias
%type <atributos> inicio_while
%type <atributos> bucle
%type <atributos> exp_while
%type <atributos> elemento_vector
%type <atributos> funcion
%type <atributos> fn_declaration
%type <atributos> fn_name
%type <atributos> idf_llamada_funcion

%left '-' '+' TOK_OR
%left '*' '/' TOK_AND
%right MENOSU '!'

%start programa
%%
programa: inicio TOK_MAIN '{' escritura_TS declaraciones escritura_segmento funciones escritura_main sentencias '}' 
            {
                escribir_fin(salida);
            };

inicio:
{
    escribir_cabecera_compatibilidad(salida);
    escribir_subseccion_data(salida);
};

escritura_TS:
{
    escribir_cabecera_bss(salida);
};

escritura_segmento:
{
    escribir_segmento_codigo(salida);
}

escritura_main:
{
    escribir_inicio_main(salida);
};

declaraciones: declaracion 
                {
                    
                } 
            | declaracion declaraciones 
                {
                    
                };
                              
declaracion: clase identificadores';' 
                {
                    
                };

clase: clase_escalar 
        {
            clase_actual = ESCALAR;
        } 
    | clase_vector 
        {
            clase_actual = VECTOR;
        };
        
clase_escalar: tipo 
                {
                    
                };
                
tipo: TOK_INT 
        {
            tipo_actual=INT;
        }
    | TOK_BOOLEAN 
        {
            tipo_actual=BOOLEAN;
        };
        
clase_vector: TOK_ARRAY tipo '[' TOK_CONSTANTE_ENTERA ']' 
                {
                    tamanio_vector_actual = $4.valor_entero;
                    if((tamanio_vector_actual < 1 ) || (tamanio_vector_actual > MAX_TAMANIO_VECTOR))
                    {
                        fprintf(stdout, "****Error semantico, tamano del vector incorrecto\n");
                        return -1;
                    }
                };
                
identificadores: identificador
                {
                    
                } 
            | identificador ',' identificadores 
                {
                    
                };
                
funciones: funcion funciones 
            {
                
            } 
        | /*vacio*/ 
            {
                
            };

funcion: fn_declaration sentencias '}'
		{
		    INFO_SIMBOLO* info;

            if(fn_return == 0){
                fprintf(stdout, "****Error semantico, la funcion no tiene retorno\n");
                return -1;
            }

		    cerrar_ambito(tablas);

            if((info = buscar_ambito(tablas, $1.lexema)) == NULL){
                fprintf(stdout, "****Error semantico, funcion %s sin declarar\n", $1.lexema);
                return -1;
            }

            info->adicional1 = num_parametros_actual;
            info->adicional2 = num_variables_locales_actual;
		};

fn_declaration: fn_name '(' parametros_funcion ')' '{' declaraciones_funcion
            {
                INFO_SIMBOLO* info;

                if((info = buscar_ambito(tablas, $1.lexema)) == NULL){
                    fprintf(stdout, "****Error semantico, funcion %s sin declarar\n", $1.lexema);
                    return -1;
                }

                info->adicional1 = num_parametros_actual;
                info->adicional2 = num_variables_locales_actual;

                strcpy($$.lexema, $1.lexema);

                fprintf(salida, "_%s:\n", $1.lexema);
                fprintf(salida, "\tpush ebp\n");
                fprintf(salida, "\tmov ebp, esp\n");
                fprintf(salida, "\tsub esp, %d\n", 4*num_variables_locales_actual);
            };

fn_name: TOK_FUNCTION tipo TOK_IDENTIFICADOR
            {
                if(buscar_ambito(tablas, $3.lexema)){
                    fprintf(stdout, "****Error semantico, elemento ya incluido en la funcion\n");
                    return -1;
                }else{
                    insertar(tablas, $3.lexema, FUNCION, tipo_actual, clase_actual, 0, 0);
                    crear_ambito(tablas);
                    insertar(tablas, $3.lexema, FUNCION, tipo_actual, clase_actual, 0, 0);

                    pos_parametro_actual=0;
                    num_parametros_actual=0;
                    pos_variable_local_actual = 1;
                    num_variables_locales_actual = 0;

                    strcpy($$.lexema, $3.lexema);
                }
            };

parametros_funcion: parametro_funcion resto_parametros_funcion 
                    {
                        
                    } 
                | /*vacio*/ 
                    {
                        
                    };

resto_parametros_funcion: ';' parametro_funcion resto_parametros_funcion 
                            {
                                
                            } 
                        | /*vacio*/ 
                            {
                                
                            };

parametro_funcion: tipo idpf 
                    {
                        
                    };
                    
idpf: TOK_IDENTIFICADOR
        {
            if(!buscar_ambito(tablas, $1.lexema)){
                insertar(tablas, $1.lexema, PARAMETRO, tipo_actual, clase_actual, num_parametros_actual, pos_parametro_actual);
                pos_parametro_actual++;
                num_parametros_actual++;
            }else{
                fprintf(stdout, "****Error semantico, Identificador %s duplicado\n", $1.lexema);
                return -1;
            }
        };

declaraciones_funcion: declaraciones 
                        {
                            
                        } 
                    | /*vacio*/ 
                        {
                            
                        };

sentencias: sentencia 
                {
                    
                }
            | sentencia sentencias 
                {
                    
                };
        
sentencia: sentencia_simple ';'
            {
                
            } 
        | bloque 
            {
                
            };
            
sentencia_simple: asignacion 
                    {
                        
                    } 
                | lectura 
                    {
                        
                    } 
                | escritura 
                    {
                        
                    } 
                | retorno_funcion 
                    {
                        
                    };
                    
bloque: condicional 
            {
                
            } 
        | bucle 
            {
                
            };
            
asignacion: TOK_IDENTIFICADOR '=' exp 
        {
            INFO_SIMBOLO * info;
            
            if(!(info = buscar_ambito(tablas, $1.lexema))){
                fprintf(stdout, "****Error semantico, no se ha encontrado la variable\n");
                return -1;
            }else{
                
                if(info->categoria == FUNCION){
                    fprintf(stdout, "****Error semantico, no es posible asignar un valor a una funcion\n");
                    return -1;
                }
                
                if(info->clase == VECTOR){
                    fprintf(stdout, "****Error semantico, no es posible asignar un valor a un vector\n");
                    return -1;
                }
                
                if(info->tipo != $3.tipo){
                    fprintf(stdout, "****Error semantico, el tipo de los dos elementos de la asignacion no coincide\n");
                    return -1;
                }
                
                if(!isLocal(tablas)){
                    asignar(salida, $1.lexema, $3.es_direccion);
                }else{
                    if(info->categoria == PARAMETRO){
                        if($3.es_direccion == 1){
                            fprintf(salida, "\tmov dword eax, [ebp+%d]\n", 4+4*(num_parametros_actual-info->adicional1));
                        }else{
                            fprintf(salida, "\tlea eax, [ebp+%d]\n", 4+4*(num_parametros_actual-info->adicional1));
                        }

                        fprintf(salida, "\tpush dword eax\n");

                        fprintf(salida, "\tpop dword ebx\n");
                        fprintf(salida, "\tpop dword eax\n");

                        if($3.es_direccion == 1){
                            fprintf(salida, "\tmov dword eax, [eax]\n");
                        }

                        fprintf(salida, "\tmov dword [ebx], eax\n");
                    }else if(info->categoria == VARIABLE){
                        if($3.es_direccion == 1){
                            fprintf(salida, "\tmov dword eax, [ebp-%d]\n", 4*info->adicional2);
                        }else{
                            fprintf(salida, "\tlea eax, [ebp-%d]\n", 4*info->adicional2);
                        }

                        fprintf(salida, "\tpush dword eax\n");

                        fprintf(salida, "\tpop dword ebx\n");
                        fprintf(salida, "\tpop dword eax\n");

                        if($3.es_direccion == 1){
                            fprintf(salida, "\tmov dword eax, [eax]\n");
                        }

                        fprintf(salida, "\tmov dword [ebx], eax\n");
                    }
                }
            }
        } 
    | elemento_vector '=' exp 
        {
            if($1.tipo != $3.tipo){
                fprintf(stdout, "****Error semantico, el tipo de los dos elementos de la asignacion no coincide\n");
                return -1;
            }
            
            fprintf(salida, "\tpop dword eax\n");
            if($3.es_direccion == 1){
                fprintf(salida, "\tmov dword eax, [eax]\n");
            }
            
            fprintf(salida, "\tpop dword edx\n");
            fprintf(salida, "\tmov dword [edx], eax\n");
        };
        
elemento_vector: TOK_IDENTIFICADOR '[' exp ']' 
                    {
                        INFO_SIMBOLO* info;
                        
                        if(!(info = buscar_ambito(tablas, $1.lexema))){
                            fprintf(stdout, "****Error semantico, no se ha encontrado la variable %s\n", $1.lexema);
                            return -1;
                        }else{
                            if($3.tipo != INT){
                                fprintf(stdout, "****Error semantico, el indice no es un entero\n");
                                return -1;
                            }else if(info->clase != VECTOR){
                                fprintf(stdout, "****Error semantico, intento de indexacion de una variable que no es de tipo vector\n");
                                return -1;
                            }else{
                                $$.tipo = info->tipo;
                                $$.es_direccion = 1;
                                
                                fprintf(salida, "\tpop dword eax\n");
                                if($3.es_direccion == 1){
                                    fprintf(salida, "\tmov dword eax, [eax]\n");
                                }
                                
                                fprintf(salida, "\tcmp eax, 0\n");
                                fprintf(salida, "\tjl near mensaje_1\n");
                                fprintf(salida, "\tcmp eax, %d\n", tamanio_vector_actual-1);
                                fprintf(salida, "\tjg near mensaje_1\n");
                                
                                fprintf(salida, "\tmov dword edx, _%s\n", $1.lexema);
                                fprintf(salida, "\tlea eax, [edx + eax*4]\n");
                                fprintf(salida, "\tpush dword eax\n");
                            }
                        }
                    };
                    
condicional: if_exp ')' '{' sentencias '}' 
                {
                    fprintf(salida, "fin_si%d:\n", $1.etiqueta);
                }
            | if_exp_sentencias TOK_ELSE '{' sentencias '}' 
                {
                    fprintf(salida, "fin_sino%d:\n", $1.etiqueta);
                };
                
if_exp: TOK_IF '(' exp 
        {
            if($3.tipo != BOOLEAN){
                fprintf(stdout, "****Error semantico, if precisa de boolean en la comparacion\n");
                return -1;
            }
            
            $$.etiqueta = etiqueta++;
            
            fprintf(salida, "\tpop dword eax\n");
            if($3.es_direccion == 1){
                fprintf(salida, "\tmov dword eax, [eax]\n");
            }
            
            fprintf(salida, "\tcmp eax, 0\n");
            fprintf(salida, "\tje near fin_si%d\n", $$.etiqueta);
        };
        
if_exp_sentencias: if_exp ')' '{' sentencias '}'
                    {
                        $$.etiqueta = $1.etiqueta;
                        
                        fprintf(salida, "\tjmp near fin_sino%d\n", $1.etiqueta);
                        fprintf(salida, "fin_si%d:\n", $1.etiqueta);
                    };

bucle: exp_while sentencias '}' 
        {
            fprintf(salida, "\tjmp near inicio_while%d\n", $1.etiqueta);
            fprintf(salida, "fin_while%d:\n", $1.etiqueta);
        };
        
exp_while: inicio_while exp ')' '{'
            {
                if($2.tipo != BOOLEAN){
                    fprintf(stdout, "****Error semantico, while precisa de boolean en la comparacion\n");
                    return -1;
                }
                
                $$.etiqueta = $1.etiqueta;
                
                fprintf(salida, "\tpop dword eax\n");
                if($2.es_direccion == 1){
                    fprintf(salida, "\tmov dword eax, [eax]\n");
                }
                
                fprintf(salida, "\tcmp eax, 0\n");
                fprintf(salida, "\tje near fin_while%d\n", $$.etiqueta);
            };
        
inicio_while: TOK_WHILE '('
                {
                    $$.etiqueta = etiqueta++;
                    
                    fprintf(salida, "inicio_while%d:\n", $$.etiqueta);
                };
        
lectura: TOK_SCANF TOK_IDENTIFICADOR 
            {
            
                INFO_SIMBOLO* info;
                
                if((info = buscar_ambito(tablas, $2.lexema)) != NULL){
                    if(info->clase == ESCALAR){
                        leer(salida, $2.lexema, info->tipo);
                    }
                }
            };
            
escritura: TOK_PRINTF exp 
            {
                escribir(salida, $2.es_direccion, $2.tipo);
            };
            
retorno_funcion: TOK_RETURN exp
                    {

                        fn_return++;

                        fprintf(salida, "\tpop dword eax\n");

                        if($2.es_direccion == 1){
                            fprintf(salida, "\tmov dword eax, [eax]\n");
                        }

                        fprintf(salida, "\tmov dword esp, ebp\n");
                        fprintf(salida, "\tpop dword ebp\n");
                        fprintf(salida, "\tret\n");
                    };
                    
exp: exp '+' exp 
        {
            if($1.tipo != INT || $3.tipo != INT){
                fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                return -1;
            }
            
            $$.tipo = INT;
            $$.es_direccion = 0;
            
            sumar(salida, $1.es_direccion, $3.es_direccion);
        } 
    | exp '-' exp  
        {
            if($1.tipo != INT || $3.tipo != INT){
                fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                return -1;
            }
            
            $$.tipo = INT;
            $$.es_direccion = 0;
            
            restar(salida, $1.es_direccion, $3.es_direccion);
        } 
    | exp '/' exp  
        {
            if($1.tipo != INT || $3.tipo != INT){
                fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                return -1;
            }
            
            $$.tipo = INT;
            $$.es_direccion = 0;
            
            dividir(salida, $1.es_direccion, $3.es_direccion);
        } 
    | exp '*' exp  
        {
            if($1.tipo != INT || $3.tipo != INT){
                fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                return -1;
            }
            
            $$.tipo = INT;
            $$.es_direccion = 0;
            
            multiplicar(salida, $1.es_direccion, $3.es_direccion);
        } 
    | '-' exp %prec MENOSU 
        {
            if($2.tipo != INT){
                fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                return -1;
            }
            
            $$.tipo = INT;
            $$.es_direccion = 0;
            
            cambiar_signo(salida, $2.es_direccion);
        } 
    | exp TOK_AND exp  
        {
            if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){
                fprintf(stdout, "****Error semantico, uno de los argumentos no es logico\n");
                return -1;
            }
            
            y(salida, $1.es_direccion, $3.es_direccion);
            
            $$.tipo = BOOLEAN;
            $$.es_direccion = 0;
        } 
    | exp TOK_OR exp  
        {
            if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN){
                fprintf(stdout, "****Error semantico, uno de los argumentos no es logico\n");
                return -1;
            }
            
            o(salida, $1.es_direccion, $3.es_direccion);
            
            $$.tipo = BOOLEAN;
            $$.es_direccion = 0;
        } 
    | '!' exp  
        {
            if($2.tipo != BOOLEAN){
                fprintf(stdout, "****Error semantico, uno de los argumentos no es logico\n");
                return -1;
            }
            
            cuantos_no++;
            
            no(salida, $2.es_direccion, cuantos_no);
            
            $$.tipo = BOOLEAN;
            $$.es_direccion = 0;
        } 
    | TOK_IDENTIFICADOR 
        {
            INFO_SIMBOLO * info;
            
            if(!(info = buscar_ambito(tablas, $1.lexema))){
                fprintf(stdout, "****Error semantico, no se ha encontrado la variable\n");
                return -1;
            }else{

                $$.tipo = info->tipo;
                $$.es_direccion = 0;

                if(!isLocal(tablas)){
                    escribir_operando(salida, $1.lexema, en_explist);
                    $$.es_direccion = 1;
                }else{
                    if(info->categoria == PARAMETRO){

                        fprintf(salida, "\tlea dword eax, [ebp+%d]\n", 4+4*(num_parametros_actual-info->adicional1));
                        fprintf(salida, "\tpush dword [eax]\n");

                    }else if(info->categoria == VARIABLE){

                        fprintf(salida, "\tlea dword eax, [ebp-%d]\n", 4*info->adicional2);
                        fprintf(salida, "\tpush dword [eax]\n");

                    }
                }
                
            }
        } 
    | constante
        {
            $$.tipo=$1.tipo;
            $$.es_direccion = $1.es_direccion;
        }
    | '(' exp ')'
        {
            $$.tipo=$2.tipo;
            $$.es_direccion = $2.es_direccion;
        }
    | '(' comparacion ')'  
        {
            $$.tipo = $2.tipo;
            $$.es_direccion = $2.es_direccion;
        } 
    | elemento_vector  
        {
            
        } 
    | idf_llamada_funcion '(' lista_expresiones ')'
        {
            INFO_SIMBOLO* info;

            if((info = buscar_ambito(tablas, $1.lexema))){
                if(num_parametros_llamada_actual == info->adicional1){
                    fprintf(salida, "\tcall _%s\n", $1.lexema);
                    fprintf(salida, "\tadd esp, %d\n", 4*num_parametros_llamada_actual);
                    fprintf(salida, "\tpush dword eax\n");

                    $$.tipo = info->tipo;
                    $$.es_direccion = 0;

                    en_explist = 0;
                }else{
                    fprintf(stdout, "****Error semantico, numero de parametros incorrecto\n");
                    return -1;
                }
            }else{
                fprintf(stdout, "****Error semantico, funcion no declarada\n");
                return -1;
            }
        };

idf_llamada_funcion: TOK_IDENTIFICADOR
                        {
                            INFO_SIMBOLO* info;

                            if((info = buscar_ambito(tablas, $1.lexema))){
                                if(info->categoria != FUNCION){
                                    fprintf(stdout, "****Error semantico, no es funcion\n");
                                    return -1;
                                }

                                if(en_explist == 1){
                                    fprintf(stdout, "****Error semantico, una funcion no puede estar dentro de los parametros\n");
                                    return -1;
                                }

                                num_parametros_llamada_actual = 0;
                                en_explist = 1;

                                strcpy($$.lexema, $1.lexema);

                            }else{
                                fprintf(stdout, "****Error semantico, funcion no declarada\n");
                                return -1;
                            }
                        };

lista_expresiones: exp resto_lista_expresiones
                    {
                        num_parametros_llamada_actual++;
                    }
                | /*vacio*/
                    {

                    };

resto_lista_expresiones: ',' exp resto_lista_expresiones
                            {
                                num_parametros_llamada_actual++;
                            }
                        | /*vacio*/
                            {

                            };

comparacion: exp TOK_IGUAL exp 
                {
                    if($1.tipo != INT || $3.tipo != INT){
                        fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                        return -1;
                    }
                    
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;
                    
                    etiqueta++;
                    
                    fprintf(salida, "\tpop dword edx\n");
                    if($3.es_direccion == 1){
                        fprintf(salida, "\tmov dword edx, [edx]\n");
                    }
                    
                    fprintf(salida, "\tpop dword eax\n");
                    if($1.es_direccion == 1){
                        fprintf(salida, "\tmov dword eax, [eax]\n");
                    }
                    
                    fprintf(salida, "\tcmp eax, edx\n");
                    fprintf(salida, "\tje near igual%d\n", etiqueta);
                    fprintf(salida, "\tpush dword 0\n");
                    fprintf(salida, "\tjmp near fin_igual%d\n", etiqueta);
                    fprintf(salida, "igual%d:\tpush dword 1\n", etiqueta);
                    fprintf(salida, "fin_igual%d:\n", etiqueta);
                } 
            | exp TOK_DISTINTO exp 
                {
                    if($1.tipo != INT || $3.tipo != INT){
                        fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                        return -1;
                    }
                    
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;
                    
                    etiqueta++;
                    
                    fprintf(salida, "\tpop dword edx\n");
                    if($3.es_direccion == 1){
                        fprintf(salida, "\tmov dword edx, [edx]\n");
                    }
                    
                    fprintf(salida, "\tpop dword eax\n");
                    if($1.es_direccion == 1){
                        fprintf(salida, "\tmov dword eax, [eax]\n");
                    }
                    
                    fprintf(salida, "\tcmp eax, edx\n");
                    fprintf(salida, "\tjne near distinto%d\n", etiqueta);
                    fprintf(salida, "\tpush dword 0\n");
                    fprintf(salida, "\tjmp near fin_distinto%d\n", etiqueta);
                    fprintf(salida, "distinto%d:\tpush dword 1\n", etiqueta);
                    fprintf(salida, "fin_distinto%d:\n", etiqueta);
                } 
            | exp '<' exp 
                {
                    if($1.tipo != INT || $3.tipo != INT){
                        fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                        return -1;
                    }
                    
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;
                    
                    etiqueta++;
                    
                    fprintf(salida, "\tpop dword edx\n");
                    if($3.es_direccion == 1){
                        fprintf(salida, "\tmov dword edx, [edx]\n");
                    }
                    
                    fprintf(salida, "\tpop dword eax\n");
                    if($1.es_direccion == 1){
                        fprintf(salida, "\tmov dword eax, [eax]\n");
                    }
                    
                    fprintf(salida, "\tcmp eax, edx\n");
                    fprintf(salida, "\tjl near menor%d\n", etiqueta);
                    fprintf(salida, "\tpush dword 0\n");
                    fprintf(salida, "\tjmp near fin_menor%d\n", etiqueta);
                    fprintf(salida, "menor%d:\tpush dword 1\n", etiqueta);
                    fprintf(salida, "fin_menor%d:\n", etiqueta);
                } 
            | exp '>' exp 
                {
                    if($1.tipo != INT || $3.tipo != INT){
                        fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                        return -1;
                    }
                    
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;
                    
                    etiqueta++;
                    
                    fprintf(salida, "\tpop dword edx\n");
                    if($3.es_direccion == 1){
                        fprintf(salida, "\tmov dword edx, [edx]\n");
                    }
                    
                    fprintf(salida, "\tpop dword eax\n");
                    if($1.es_direccion == 1){
                        fprintf(salida, "\tmov dword eax, [eax]\n");
                    }
                    
                    fprintf(salida, "\tcmp eax, edx\n");
                    fprintf(salida, "\tjg near mayor%d\n", etiqueta);
                    fprintf(salida, "\tpush dword 0\n");
                    fprintf(salida, "\tjmp near fin_mayor%d\n", etiqueta);
                    fprintf(salida, "mayor%d:\tpush dword 1\n", etiqueta);
                    fprintf(salida, "fin_mayor%d:\n", etiqueta);
                } 
            | exp TOK_MAYORIGUAL exp 
                {
                    if($1.tipo != INT || $3.tipo != INT){
                        fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                        return -1;
                    }
                    
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;
                    
                    etiqueta++;
                    
                    fprintf(salida, "\tpop dword edx\n");
                    if($3.es_direccion == 1){
                        fprintf(salida, "\tmov dword edx, [edx]\n");
                    }
                    
                    fprintf(salida, "\tpop dword eax\n");
                    if($1.es_direccion == 1){
                        fprintf(salida, "\tmov dword eax, [eax]\n");
                    }
                    
                    fprintf(salida, "\tcmp eax, edx\n");
                    fprintf(salida, "\tjge near mayorigual%d\n", etiqueta);
                    fprintf(salida, "\tpush dword 0\n");
                    fprintf(salida, "\tjmp near fin_mayorigual%d\n", etiqueta);
                    fprintf(salida, "mayorigual%d:\tpush dword 1\n", etiqueta);
                    fprintf(salida, "fin_mayorigual%d:\n", etiqueta);
                } 
            | exp TOK_MENORIGUAL exp 
                {
                    if($1.tipo != INT || $3.tipo != INT){
                        fprintf(stdout, "****Error semantico, uno de los argumentos no es entero\n");
                        return -1;
                    }
                    
                    $$.tipo = BOOLEAN;
                    $$.es_direccion = 0;
                    
                    etiqueta++;
                    
                    fprintf(salida, "\tpop dword edx\n");
                    if($3.es_direccion == 1){
                        fprintf(salida, "\tmov dword edx, [edx]\n");
                    }
                    
                    fprintf(salida, "\tpop dword eax\n");
                    if($1.es_direccion == 1){
                        fprintf(salida, "\tmov dword eax, [eax]\n");
                    }
                    
                    fprintf(salida, "\tcmp eax, edx\n");
                    fprintf(salida, "\tjle near menorigual%d\n", etiqueta);
                    fprintf(salida, "\tpush dword 0\n");
                    fprintf(salida, "\tjmp near fin_menorigual%d\n", etiqueta);
                    fprintf(salida, "menorigual%d:\tpush dword 1\n", etiqueta);
                    fprintf(salida, "fin_menorigual%d:\n", etiqueta);
                };

constante: constante_logica 
            {
                $$.tipo = $1.tipo;
                $$.es_direccion = $1.es_direccion;
            } 
        | constante_entera 
            {
                $$.tipo = $1.tipo;
                $$.es_direccion = $1.es_direccion;
            };
                
constante_logica: TOK_TRUE 
                    {
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                        
                        fprintf(salida, ";numero_linea %d\n", linea);
                        fprintf(salida, "\tpush dword 1\n");
                    } 
                | TOK_FALSE 
                    {
                        $$.tipo = BOOLEAN;
                        $$.es_direccion = 0;
                        
                        fprintf(salida, ";numero_linea %d\n", linea);
                        fprintf(salida, "\tpush dword 0\n");
                    };
                    
constante_entera: TOK_CONSTANTE_ENTERA 
                    {
                        $$.tipo = INT;
                        $$.es_direccion = 0;
                        
                        fprintf(salida, "; numero de linea %d\n", linea);
                        fprintf(salida, "\tpush dword %d\n", $1.valor_entero);
                    };

identificador: TOK_IDENTIFICADOR
                {
                    if(!isLocal(tablas))
                    {
                        if(!buscar_ambito(tablas, $1.lexema))
                        {
                            insertar(tablas, $1.lexema, VARIABLE, tipo_actual, clase_actual, 0, 0);
                            
                            if(clase_actual != VECTOR){
                                declarar_variable(salida, $1.lexema,  tipo_actual,  1);
                            }else{
                                declarar_variable(salida, $1.lexema, tipo_actual, tamanio_vector_actual);
                            }
                        }else{
                            fprintf(stdout, "****Error semantico, Identificador %s duplicado\n", $1.lexema);
                            return -1;
                        }
                    }else{
                        if(!buscar_ambito(tablas, $1.lexema)){

                            if(clase_actual != VECTOR){
                                insertar(tablas, $1.lexema, VARIABLE, tipo_actual, clase_actual, 0, pos_variable_local_actual);
                                pos_variable_local_actual++;
                                num_variables_locales_actual++;
                            }else{
                                fprintf(stdout, "****Error semantico, no se pueden declarar vectores en una funcion\n");
                                return -1;
                            }
                        }else{
                            fprintf(stdout, "****Error semantico, Identificador %s duplicado\n", $1.lexema);
                            return -1;
                        }
                    }
                };

%%