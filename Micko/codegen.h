#ifndef CODEGEN_H
#define CODEGEN_H

#include "defs.h"

// funkcije za zauzimanje, oslobadjanje registra
int  take_reg(void);
void free_reg(void);
// oslobadja ako jeste indeks registra
void release_reg(int reg_index); 

// stampa indentaciju
void indent(bool tabs); 

// generise labelu koja se sastoji od 2 stringa 
// npr: @main_exit
void gen_sslab(char *str1, char *str2);

// generise labelu koja se sastoji 
// od jednog stringa i jednog broja npr: @if0
void gen_snlab(char *str, int num);

// ispisuje simbol (u odgovarajucem obliku) 
// koji se nalazi na datom indeksu u tabeli simbola
void print_symbol(int index);

// generise CMP naredbu, parametri su indeksi operanada u TS-a 
void gen_cmp(int operand1_index, int operand2_index);

// generise MOV naredbu, parametri su indeksi operanada u TS-a 
void gen_mov(int input_index, int output_index);

// generise naredbe ADD ili SUB
// prvi parametar je jedna od konstanti ADD ili SUB
// drugi i treci parametar su indeksi operanada u TS-a 
int gen_arith(int statement, int operand1_index, int operand2_index);

// generise poziv funkcije
void gen_fcall(int name_index);
// generise brisanje argumenata sa steka
void gen_clear_args(int num);
// generise PUSH naredbu
void gen_push(int arg_index);

//vraca aritmeticku operaciju
char* get_arop(int sign, int op);
//vraca operaciju uslovnog skoka
char* get_opjump(int jump);

#endif
