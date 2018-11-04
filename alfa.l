%{
    /***************************************************************************
    Modulo: tokens.l
    Autores: Alberto Garcia y Mario Calle
    Fecha: 30-10-2017
    Tokens
    ***************************************************************************/
    #include "alfa.h"
    #include "y.tab.h"
    #include "tablaSimbolos.h"

    FILE* salida;
    
    int linea = 1;
    int columna = 0;
    int flag = 0;
%}
%option noyywrap

IDENTIFICADOR [a-zA-Z]([0-9]|[a-zA-Z])*
CONSTANTE_ENTERA [0-9]([0-9])*
COMENTARIO "//"[^\n]*

%%

" " { columna+=yyleng; }
"\n" { columna=0; linea+=1; }
"\t" { columna+=yyleng; }
{COMENTARIO} { }

main { columna+=yyleng; return TOK_MAIN; }
int { columna+=yyleng; return TOK_INT; }
boolean { columna+=yyleng; return TOK_BOOLEAN; }
array { columna+=yyleng; return TOK_ARRAY; }
function { columna+=yyleng; return TOK_FUNCTION; }
if { columna+=yyleng; return TOK_IF; }
else { columna+=yyleng; return TOK_ELSE; }
while { columna+=yyleng; return TOK_WHILE; }
scanf { columna+=yyleng; return TOK_SCANF; }
printf { columna+=yyleng; return TOK_PRINTF; }
return { columna+=yyleng; return TOK_RETURN; }
true { columna+=yyleng; return TOK_TRUE; }
false { columna+=yyleng; return TOK_FALSE; }

";" { columna+=yyleng;  return ';' ; }
"," { columna+=yyleng;  return ','; }
"(" { columna+=yyleng;  return '('; }
")" { columna+=yyleng;  return ')'; }
"[" { columna+=yyleng;  return '['; }
"]" { columna+=yyleng;  return ']'; }
"{" { columna+=yyleng;  return '{'; }
"}" { columna+=yyleng;  return '}'; }
"=" { columna+=yyleng; return '='; }
"+" { columna+=yyleng; return '+'; }
"-" { columna+=yyleng; return '-'; }
"/" { columna+=yyleng; return '/'; }
"*" { columna+=yyleng; return '*'; }
"&&" { columna+=yyleng; return TOK_AND; }
"||" { columna+=yyleng; return TOK_OR; }
"!" { columna+=yyleng; return '!'; }
"==" { columna+=yyleng; return TOK_IGUAL; }
"!=" { columna+=yyleng; return TOK_DISTINTO; }
"<=" { columna+=yyleng; return TOK_MENORIGUAL; }
">=" { columna+=yyleng; return TOK_MAYORIGUAL; }
"<" { columna+=yyleng; return '<'; }
">" { columna+=yyleng; return '>'; }

{CONSTANTE_ENTERA} { columna+=yyleng; yylval.atributos.valor_entero = atoi(yytext); return TOK_CONSTANTE_ENTERA; }
{IDENTIFICADOR} { if(yyleng > 100){ flag = 1; columna++; printf("****Error morfológico en [lin %d, col %d]\n", linea, columna); return TOK_ERROR; } columna+=yyleng; strcpy(yylval.atributos.lexema, yytext); return TOK_IDENTIFICADOR; }

. { flag = 1; columna++; printf("****Error en [lin %d, col %d]: símbolo no permitido (%s)\n", linea, columna, yytext); return TOK_ERROR; }

%%