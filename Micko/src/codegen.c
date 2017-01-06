#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "codegen.h"
#include "symtab.h"


extern FILE *output;
int free_reg_num = 0;
char invalid_value[] = "???";
char* tabm="&nbsp;&nbsp;";
char* tabl="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

// REGISTERS

int take_reg(void) {
  if(free_reg_num > LAST_WORKING_REG) {
    err("Compiler error! No free registers!");
    exit(EXIT_FAILURE);
  }
  return free_reg_num++;
}

void free_reg(void) {
   if(free_reg_num < 1) {
      err("Compiler error! No more registers to free!");
      exit(EXIT_FAILURE);
   }
   else
      set_reg_type(--free_reg_num, NO_TYPE);
}

// Ako je u pitanju indeks registra, oslobodi registar
void release_reg(int reg_index) {
  if(reg_index >= 0 && reg_index <= LAST_WORKING_REG)
    free_reg();
}

// LABELS

void indent(bool tabs) {
  code("<br/>\n");
  if(tabs)
    code("%s\t\t\t", tabl);
}

void gen_sslab(char *str1, char *str2) {
  indent(FALSE);
  code("@%s%s:", str1, str2);
}

void gen_snlab(char *str, int num) {
  indent(FALSE);
  code("@%s%d:", str, num);
}


// SYMBOL
void print_symbol(int index) {
  if(index > -1) {
    // - n * 4 (%14)
    if(get_kind(index) == VAR)
      code("-%d(%%14)", get_attr(index) * 4);

    // m * 4 (%14)
    else 
      if(get_kind(index) == PAR)
        code("%d(%%14)", 4 + get_attr(index) *4);

      // identifier
      else 
        if(get_kind(index) == LIT)
          code("$%s", get_name(index));
        else
          code("%s", get_name(index));
  }
}


// OTHER

void gen_cmp(int operand1_index, int operand2_index) {
  indent(TRUE);
  if(get_type(operand1_index) == INT)
    code("CMPS %s\t", tabm);
  else
    code("CMPU %s\t", tabm);
  print_symbol(operand1_index);
  code(",");
  print_symbol(operand2_index);
  release_reg(operand2_index);
  release_reg(operand1_index);
}

void gen_mov(int input_index, int output_index) {
  indent(TRUE);
  code("MOV %s\t", tabm);
  print_symbol(input_index);
  code(",");
  print_symbol(output_index);

  //ako se smešta u registar, treba preneti tip 
  if(output_index >= 0 && output_index <= LAST_WORKING_REG)
    set_reg_type(output_index, get_type(input_index));
  release_reg(input_index);
}


// STATEMENTS
int gen_arith(int stmt, int op1_index, int op2_index) {
  int output_index;
  int t = get_type(op1_index);

  indent(TRUE);
  code("%s%s\t", get_arop(t-1,stmt), tabm);
  print_symbol(op1_index);
  code(",");
  print_symbol(op2_index);
  code(",");
  release_reg(op2_index);
  release_reg(op1_index);
  output_index = take_reg();
  print_symbol(output_index);

  //tip izraza = tip jednog od operanada (recimo prvog)
  set_reg_type(output_index, t);
  return output_index;
}


// FUNCTION

void gen_fcall(int name_index) {
  indent(TRUE);
  code("CALL%s\t", tabm);
  print_symbol(name_index);
}

void gen_clear_args(int num) {
  if(num > 0) {
   indent(TRUE);
   code("ADDS%s\t%%15,$%d,%%15", tabm, num * 4);
  }
}

void gen_push(int arg_index) {
   release_reg(arg_index);
   indent(TRUE);
   fprintf(output, "PUSH%s\t", tabm);
   print_symbol(arg_index);
}

char* get_arop(int sign, int op) {
    if ((sign < 0) || (sign > 1) || (op < 0) || (op >= AROP_NUMBER))
        return invalid_value;
    else
        return arithmetic_operators[sign][op];
}

char* get_opjump(int jump) {
    if ((jump < 0) || (jump >= RELOP_NUMBER * 2))
        return invalid_value;
    else
        return opposite_jumps[jump];
}

