%{
#include<stdio.h>
#include"Fonctions.h"
extern int ligne;
extern FILE* yyin;
extern int col;
int yyparse();
int yylex();
int yyerror(char *s);
%}

%union {
int entier;
char* chaine;
float reel;
}
%start S
%token err mc_Program  mc_PDEC mc_PINST mc_Begin mc_End deuxpoints pvg mc_define mc_Pfloat mc_Pint
%token aff Affectation barrelateral etcomercial pardroite pargauche 
%token Superieur Inferieur Superieurouegal Inferieurouegal Egal different mc_FOR mc_WHILE mc_DO mc_ENDFOR mc_IF mc_ELSE mc_ENDIF
%token <chaine>idf <entier>cst 
%left Addition Soustraction
%left Multiplication division
%type <entier>TYPE
%%

S : prog mc_PDEC PartieDeclaration mc_PINST mc_Begin PartieInstructions mc_End {printf("syntax correcte\n"); print_list(); YYACCEPT;}
;

prog: mc_Program idf
;

PartieDeclaration: DEC PartieDeclaration | DEC
;

DEC: DEC_VAR 
    | DEC_CST 
;

DEC_VAR : LIST_idf deuxpoints TYPE pvg {while (!queue_is_empty()) {
                                            insert(queue_first(),0,$3);
                                            pop_queue();}
                                            }
;

LIST_idf : idf barrelateral LIST_idf {push_queue($1);}
        | idf {push_queue($1);}

DEC_CST: mc_define TYPE idf aff cst pvg {insert($3,1,$2);}
;

TYPE: mc_Pint {$$=0;}
    | mc_Pfloat {$$=1;}
;

PartieInstructions: INST PartieInstructions | INST  
;

INST: INST_AFF | INST_LOOP | INST_IF
;

INST_AFF: idf Affectation idf pvg { if(!Search_element($1)) printf("erreur sémantique %s non déclarer à la ligne %d \n",$1,ligne);
                                    if(!compatible_type(return_type($1),return_type($3))) printf("erreur semantique %s, incompatibilite de type à la ligne %d \n",$1,ligne); 
                                    if(affectation_constant($1)) printf("erreur sémantique %s affectation_constant à la ligne %d \n",$1,ligne); }
        | idf Affectation cst pvg { if(!Search_element($1)) printf("erreur sémantique %s non déclarer à la ligne %d \n",$1,ligne);
                                    if(!compatible_type(return_type($1),0)) printf("erreur semantique %s, incompatibilite de type à la ligne %d \n",$1,ligne); 
                                    if(affectation_constant($1)) printf("erreur sémantique %s affectation_constant à la ligne %d \n",$1,ligne); }
        | idf Affectation idf OPERATION cst pvg {if(affectation_constant($1)) printf("erreur sémantique %s affectation_constant à la ligne %d \n",$1,ligne); }
        | idf Affectation idf OPERATION idf pvg {if(affectation_constant($1)) printf("erreur sémantique %s affectation_constant à la ligne %d \n",$1,ligne); }
;

INST_LOOP: mc_FOR idf Affectation cst mc_WHILE cst mc_DO PartieInstructions mc_ENDFOR
;

INST_IF: mc_DO PartieInstructions mc_IF deuxpoints pardroite CONDITION pargauche mc_ENDIF
        | mc_DO PartieInstructions mc_IF deuxpoints pardroite CONDITION pargauche mc_ELSE PartieInstructions mc_ENDIF
;

CONDITION: idf Expression_comparaison cst
;

Expression_comparaison: Egal | Inferieur | Inferieurouegal | Superieur | Superieurouegal | different
;

OPERATION: Addition | Soustraction | Multiplication | division
;

%%
int yyerror(char* msg)
{
    printf("%s ligne %d et colonne %d\n",msg,ligne,col);
return 0;
}
int main(){ 
yyin = fopen("test.txt", "r");
yyparse();  
return 0;  
} 
