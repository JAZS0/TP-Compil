%{
#include<stdio.h>
#include"Fonctions.h"
extern int ligne;
extern FILE* yyin;
extern int col;
int yyparse();
int yylex();
int yyerror(char *s);
int operation=0;
%}

%union {
int entier;
char* chaine;
float reel;
}
%start S
%token mc_Program  mc_PDEC mc_PINST mc_Begin mc_End deuxpoints pvg mc_define mc_Pfloat mc_Pint
%token aff division Affectation Addition Soustraction Multiplication barrelateral etcomercial pardroite pargauche 
%token Superieur Inferieur Superieurouegal Inferieurouegal Egal different mc_FOR mc_WHILE mc_DO mc_ENDFOR mc_IF mc_ELSE mc_ENDIF
%token <chaine>idf <entier>cst 
%type <entier>TYPE
%%

S : prog mc_PDEC PartieDeclaration mc_PINST mc_Begin PartieInstructions mc_End {printf("syntaxe correcte\n"); print_list(); YYACCEPT;}
;

prog: mc_Program idf
;

PartieDeclaration: DEC PartieDeclaration | DEC
;

DEC: DEC_VAR | DEC_CST 
;

DEC_VAR : LIST_idf deuxpoints TYPE pvg {insert(queue_first(),0,$3); pop_queue();}
;

LIST_idf : idf barrelateral LIST_idf {if double_dec($1)==1 push_queue($1); 
                                     else printf("erreur à la ligne %d: idf %s deja déclaré \n",ligne,$3);)} 
        | idf {if double_dec($1)==1 push_queue($1); 
                                     else printf("erreur à la ligne %d: idf %s deja déclaré \n",ligne,$3);}
;       
DEC_CST: mc_define TYPE idf aff cst pvg {if double_dec($3)==1 insert($3,1,$2);
                                        else printf("erreur à la ligne %d: idf %s deja déclaré \n",ligne,$3);}
;

TYPE: mc_Pint {$$=0} | mc_Pfloat {$$=1;}
;

PartieInstructions: INST PartieInstructions | INST  
;

INST: INST_AFF | INST_LOOP | INST_IF
;

INST_AFF: idf Affectation TYPE_AFF pvg {if (Search_element($1)==false)  printf("erreur a la ligne %d : idf %s non déclaré",ligne,$3);
                                        else { (affectation_constant($3))==true printf("erreur a la ligne %d : modification de constante",ligne);
                                        else{ if(return_type($1)!=return_type($3)) printf("erreur a la ligne %d : types incompatibles",ligne); 
                                            else ($1=$3);} } }
;

TYPE_AFF: idf{$$=$1;} | cst{$$=$1;} | idf OPERATION cst{switch (operation){
                                                        case 0: $1+$3; case 1: $1-$3; case 2: $1*$3; case 3: if ($3==0) printf("erreur a la ligne %d : division par 0 impossible.",ligne);
                                                                                                                else $1/$3;}} 
                                  | idf OPERATION idf {switch (operation){
                                                        case 0: $1+$3; case 1: $1-$3; case 2: $1*$3; case 3: if ($3==0) printf("erreur a la ligne %d : division par 0 impossible.",ligne);
                                                                                                                else $1/$3;}}
;

INST_LOOP: mc_FOR idf Affectation cst mc_WHILE cst mc_DO PartieInstructions mc_ENDFOR {if (Search_element($1)==false)  printf("erreur a la ligne %d : idf %s non déclaré",ligne,$3);}
;

INST_IF: mc_DO PartieInstructions mc_IF deuxpoints pardroite CONDITION pargauche mc_ENDIF
        | mc_DO PartieInstructions mc_IF deuxpoints pardroite CONDITION pargauche mc_ELSE PartieInstructions mc_ENDIF
;

CONDITION: idf Expression_comparaison cst
;

Expression_comparaison: Egal | Inferieur | Inferieurouegal | Superieur | Superieurouegal | different
;

OPERATION: Addition{operation=0;} | Soustraction{operation=1;} | Multiplication{operation=2;} | division{operation=3;} 
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
