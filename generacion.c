#include <stdio.h>
#include "generacion.h"

void escribir_cabecera_compatibilidad(FILE* fpasm){
    fprintf(fpasm, "%%ifdef TIPO_MSVC\n");
    fprintf(fpasm, "%%define main _main\n");
    fprintf(fpasm, "%%endif\n");
}

void escribir_subseccion_data(FILE* fpasm){
    fprintf(fpasm, "\nsegment .data\n");
    fprintf(fpasm, "div_0 db \"Error: Division por 0\", 0\n");
    fprintf(fpasm, "msg_1 db \"Error: Tamaño del vector incorrecto\", 0\n");
}

void escribir_cabecera_bss(FILE* fpasm){
    fprintf(fpasm, "\nsegment .bss\n");
    fprintf(fpasm, "__esp resd 1\n");
}

void declarar_variable(FILE* fpasm, char * nombre,  int tipo,  int tamano){
    if(tipo == ENTERO){
        fprintf(fpasm, "_%s resd %d\n", nombre, tamano);
    }else if(tipo == BOOLEANO){
        fprintf(fpasm, "_%s resd %d\n", nombre, tamano);
    }
}

void escribir_segmento_codigo(FILE* fpasm){
    fprintf(fpasm, "\nsegment .text\n");
    fprintf(fpasm, "global main\n");
    fprintf(fpasm, "extern print_int, print_boolean, print_string, print_blank, print_endofline, scan_int, scan_boolean\n\n");
}

void escribir_inicio_main(FILE* fpasm){
    fprintf(fpasm, "\nmain:\n");
    fprintf(fpasm, "\tmov dword [__esp], esp\n");
}

void escribir_fin(FILE* fpasm){
    fprintf(fpasm, "\tjmp fin\n");
    fprintf(fpasm, "error_div0:\n");
    fprintf(fpasm, "\tpush dword div_0\n");
    fprintf(fpasm, "\tcall print_string\n");
    fprintf(fpasm, "\tadd esp, 4\n");
    fprintf(fpasm, "\tjmp fin\n");
    
    fprintf(fpasm, "mensaje_1:\n");
    fprintf(fpasm, "\tpush dword msg_1\n");
    fprintf(fpasm, "\tcall print_string\n");
    fprintf(fpasm, "\tadd esp, 4\n");
    fprintf(fpasm, "\tjmp near fin\n");
    
    fprintf(fpasm, "fin:\n");
    fprintf(fpasm, "\tmov dword esp, [__esp]\n");
    fprintf(fpasm, "\tret\n");
    
}

void escribir_operando(FILE* fpasm, char* nombre, int es_var){
    if(es_var == 1){
        fprintf(fpasm, "\tpush dword [_%s]\n", nombre);
    }else{
        fprintf(fpasm, "\tpush dword _%s\n", nombre);
    }
}

void asignar(FILE* fpasm, char* nombre, int es_referencia){
    
    fprintf(fpasm, "\tpop dword eax\n");
    if(es_referencia == 1){
        
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
        fprintf(fpasm, "\tmov dword [_%s], eax\n", nombre);
    }else{
        fprintf(fpasm, "\tmov dword [_%s], eax\n", nombre);
    }
}

void sumar(FILE* fpasm, int es_referencia_1, int es_referencia_2){
    fprintf(fpasm, "\tpop dword eax\n");
    
    if(es_referencia_2 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
    }
    
    fprintf(fpasm, "\tpop dword ebx\n");
    
    if(es_referencia_1 == 1){
        fprintf(fpasm, "\tmov dword ebx, [ebx]\n");
    }
    
    fprintf(fpasm, "\tadd dword ebx, eax\n");
    fprintf(fpasm, "\tpush ebx\n");
}

void restar(FILE* fpasm, int es_referencia_1, int es_referencia_2){
    fprintf(fpasm, "\tpop dword eax\n");
    
    if(es_referencia_2 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
    }
    
    fprintf(fpasm, "\tpop dword ebx\n");
    if(es_referencia_1 == 1){
        fprintf(fpasm, "\tmov dword ebx, [ebx]\n");
    }
    
    fprintf(fpasm, "\tsub dword ebx, eax\n");
    fprintf(fpasm, "\tpush ebx\n");
}

void multiplicar(FILE* fpasm, int es_referencia_1, int es_referencia_2){ /*PENSAR ESTA*/
    fprintf(fpasm, "\tpop dword ecx\n");

    if(es_referencia_2 == 1){
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");
    }

    fprintf(fpasm, "\tpop dword eax\n");

    if(es_referencia_1 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
    }

    fprintf(fpasm, "\timul dword ecx\n");
    fprintf(fpasm, "\tpush dword eax\n");
}

void dividir(FILE* fpasm, int es_referencia_1, int es_referencia_2){ /*PENSAR ESTA*/
    fprintf(fpasm, "\tpop dword ecx\n");

    if(es_referencia_2 == 1){
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");
    }

    fprintf(fpasm, "\tpop dword eax\n");

    if(es_referencia_1 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
    }
    
    fprintf(fpasm, "\tcdq\n");

    fprintf(fpasm, "\tcmp dword ecx, 0\n");
    fprintf(fpasm, "\tje error_div0\n");
    fprintf(fpasm, "\tidiv dword ecx\n");
    fprintf(fpasm, "\tpush dword eax\n");

}

void o(FILE* fpasm, int es_referencia_1, int es_referencia_2){
    fprintf(fpasm, "\tpop dword eax\n");

    if(es_referencia_2 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
    }

    fprintf(fpasm, "\tpop dword ecx\n");

    if(es_referencia_1 == 1){
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");
    }

    fprintf(fpasm, "\tor dword ecx, eax\n");
    fprintf(fpasm, "\tpush dword ecx\n");
}

void y(FILE* fpasm, int es_referencia_1, int es_referencia_2){
    fprintf(fpasm, "\tpop dword eax\n");

    if(es_referencia_2 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
    }

    fprintf(fpasm, "\tpop dword ecx\n");

    if(es_referencia_1 == 1){
        fprintf(fpasm, "\tmov dword ecx, [ecx]\n");
    }

    fprintf(fpasm, "\tand dword ecx, eax\n");
    fprintf(fpasm, "\tpush dword ecx\n");
}

void cambiar_signo(FILE* fpasm, int es_referencia){
    fprintf(fpasm, "\tpop dword eax\n");

    if(es_referencia == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
    }

    fprintf(fpasm, "\tneg dword eax\n");
    fprintf(fpasm, "\tpush dword eax\n");
}

void no(FILE* fpasm, int es_referencia, int cuantos_no){
    fprintf(fpasm, "\tpop dword eax\n");

    if(es_referencia == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
    }
    
    fprintf(fpasm, "\tcmp eax, 0\n");
    fprintf(fpasm, "\tje etiqueta_%d\n", cuantos_no);
    fprintf(fpasm, "\tmov eax, 0\n");
    
    fprintf(fpasm, "\tjmp fin_no_%d\n",cuantos_no);
    fprintf(fpasm, "\tetiqueta_%d:\n", cuantos_no);
    fprintf(fpasm, "\tmov eax, 1\n");
    
    fprintf(fpasm, "\tfin_no_%d:\n",cuantos_no);
    fprintf(fpasm, "\tpush eax\n");
}

void leer(FILE* fpasm, char* nombre, int tipo){
    
    fprintf(fpasm, "\tpush dword _%s\n", nombre);
    
    if(tipo == ENTERO){
        fprintf(fpasm, "\tcall scan_int\n");
        fprintf(fpasm, "\tadd esp, 4\n");  
    }else if(tipo == BOOLEANO){
        fprintf(fpasm, "\tcall scan_boolean\n");
        fprintf(fpasm, "\tadd esp, 4\n");  
    }
}

void escribir(FILE* fpasm, int es_referencia, int tipo){   
    if(es_referencia == 1){
        fprintf(fpasm, "\tpop dword eax\n");
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
        fprintf(fpasm, "\tpush dword eax\n");
    }
    
    if(tipo == ENTERO){
        fprintf(fpasm, "\tcall print_int\n");
        fprintf(fpasm, "\tadd esp, 4\n");  
    }else if(tipo == BOOLEANO){
        fprintf(fpasm, "\tcall print_boolean\n");
        fprintf(fpasm, "\tadd esp, 4\n");  
    }
    
    fprintf(fpasm, "\tcall print_endofline\n");
}