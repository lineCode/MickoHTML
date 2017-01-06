#ifndef DEFS_H
#define DEFS_H

int yyerror(char *s);
int yylex (void);

#define bool int
#define TRUE  1
#define FALSE 0

#define SYMBOL_TABLE_LENGTH   64
#define CHAR_BUFFER_LENGTH    128
#define NO_ATTR               -1
#define LAST_WORKING_REG      12
#define FUN_REG               13

//pomocni makroi za ispis
extern void warning(char *s);
#define err(args...)  sprintf(char_buffer, args), \
                      yyerror(char_buffer)
#define warn(args...) sprintf(char_buffer, args), \
                      warning(char_buffer)
#define code(args...) fprintf(output, args)
#define cprint(args...) fprintf(colormc, args)
#define ISTEP		      30
#define rprint(args...) fprintf(rout, args)

extern char char_buffer[CHAR_BUFFER_LENGTH];

//tipovi podataka
enum types { NO_TYPE, INT, UINT };

//vrste simbola (moze ih biti maksimalno 32)
enum kinds { NO_KIND = 0x1, REG = 0x2, LIT = 0x4,
             FUN = 0x8, VAR = 0x10, PAR = 0x20 };

//konstante arithmetickih operatora
enum arops { ADD, SUB, MUL, DIV, AROP_NUMBER };
//stringovi za generisanje aritmetickih naredbi
static char *arithmetic_operators[2][4] = { {"ADDS", "SUBS", "MULS", "DIVS"},
                                            {"ADDU", "SUBU", "MULU", "DIVU"} };

//konstante relacionih operatora
enum relops { LT, GT, LE, GE, EQ, NE, RELOP_NUMBER };
//stringovi za JMP narebu
static char* opposite_jumps[]={"JGES", "JLES", "JGTS", "JLTS", "JNE ", "JEQ ",
                               "JGEU", "JLEU", "JGTU", "JLTU", "JNE ", "JEQ "};


static char* program_c = "function_list\n{\nint idx;\nif((idx = lookup_symbol(&quot;main&quot;, FUN)) == -1)\n\t err(&quot;undefined reference to 'main'&quot;);\nelse\n\tif(get_type(idx) != INT)\n\t\twarn(&quot;return type of 'main' is not int&quot;);\n}";

static char* function_c = "type _ID\n{\nfun_idx = insert_symbol($3, FUN, $2, NO_ATTR); \ncode(&quot;\\n%s:&quot;, $3); \ncode(&quot;%s\\n\\t\\t\\tPUSH\\t%%14&quot;,tab);\ncode(&quot;%s\\n\\t\\t\\tMOV \\t%%15,%%14&quot;,tab);\n}\n_LPAREN parameter _RPAREN\n{\nset_attr(fun_idx, $6);\nvar_num = 0;\n}\nbody\n{\nif (get_last_element() > fun_idx)\n\tclear_symbols(fun_idx + 1);\n\ngen_sslab($3,&quot;_exit&quot;);\ncode(&quot;%s\\n\\t\\t\\tMOV \\t%%14,%%15&quot;,tab);\ncode(&quot;%s\\n\\t\\t\\tPOP \\t%%14&quot;,tab);\ncode(&quot;%s\\n\\t\\t\\tRET&quot;,tab);\n}";

static char* type_c = "_TYPE\n{\n$$ = $1;\n}";

static char* parameter_c_empty = "/* empty */\n{\n$$ = 0;\n}";

static char* parameter_c = "type _ID\n{\ninsert_symbol($3, PAR, $2, 1);\nset_ptyp(fun_idx, $2);\n$$ = 1;\n}";

static char* body_c = "_LBRACKET variable_list\n{\nif (var_num)\n\tcode(&quot;<br/>%s\\n\\t\\t\\tSUBS\\t%%15,$%d,%%15&quot;, tab, 4*var_num);\nc++;\ngen_sslab(get_name(fun_idx), &quot;_body&quot;);\n}\nstatement_list _RBRACKET";

static char* variable_c = "type _ID _SEMICOLON\n{\nif(lookup_symbol($3, PAR) != -1)\n\terr(&quot;redefinition of '%s'&quot;, $3);\nelse\n\tinsert_symbol($3, VAR, $2, ++var_num);\n}";

static char* assignment_statement_c = "_ID _ASSIGN num_exp _SEMICOLON\n{\nint i;\nif( (i = lookup_symbol($2, (VAR|PAR))) == -1 )\n\terr(&quot;invalid lvalue '%s' in assignment&quot;, $2);\nelse\n\tif(!check_types(i, $5))\n\t\t err(&quot;incompatible types in assignment&quot;);\ngen_mov($5, i);\n}";

static char* num_exp_c = "num_exp _AROP exp\n{\nif(!check_types($1, $4))\n\terr(&quot;invalid operands: arithmetic operation&quot;);\n$$ = gen_arith($2, $1, $4);\n}";

static char* exp_c_id = "_ID\n{\nif( ($$ = lookup_symbol($1, (VAR|PAR))) == -1)\n\terr(&quot;'%s' undeclared&quot;, $1);\n}";

static char* exp_c_fc = "function_call\n{\n$$ = take_reg();\ngen_mov(FUN_REG, $$);\n}";

static char* exp_c_ne = "_LPAREN num_exp _RPAREN\n{\n$$ = $3;\n}";

static char* literal_c_int = "_INT_NUMBER\n{\n$$ = insert_literal($1, INT);\n}";

static char* literal_c_uint = "_UINT_NUMBER\n{\n$$ = insert_literal($1, UINT);\n}";

static char* function_call_c = "_ID\n{\nif((fcall_idx = lookup_symbol($1, FUN)) == -1)\n\terr(&quot;'%s' is not a function&quot;, $1);\n}\n_LPAREN argument _RPAREN\n{\nif (get_attr(fcall_idx) != $5)\n\terr(&quot;wrong number of arguments to function '%s'&quot;,get_name(fcall_idx));\ngen_fcall(fcall_idx);\ngen_clear_args($5);\nset_reg_type(FUN_REG, get_type(fcall_idx));\n$$ = FUN_REG;\n}";

static char* argument_c_empty = "/* empty */\n{\n$$ = 0;\n}";

static char* argument_c_ne = "num_exp\n{\nif(get_ptyp(fcall_idx) != get_type($1))\n\terr(&quot;incompatible type for argument in '%s'&quot;,get_name(fcall_idx));\ngen_push($1);\n$$ = 1;\n}";

static char* if_statement_c_oi = "if_part %prec ONLY_IF\n{\ngen_snlab(&quot;exit&quot;, lab_num);\n}";

static char* if_statement_c_e = "if_part _ELSE\n{\ngen_snlab(&quot;exit&quot;, lab_num);\n}";

static char* if_part_c = "_IF _LPAREN\n{\nlab_num++;\ngen_snlab(&quot;if&quot;, lab_num);\n}\nrel_exp\n{\ncode(&quot;%s\\n\\t\\t\\t%s\\t@false%d&quot;, tab, get_opjump($5),lab_num);\ngen_snlab(&quot;true&quot;,lab_num);\n}\n_RPAREN\n{\ncode(&quot;%s\\n\\t\\t\\tJMP \\t@exit%d&quot;, tab, lab_num);\ngen_snlab(&quot;false&quot;, lab_num);\n}";

static char* rel_exp_c = "num_exp _RELOP num_exp\n{\nif(!check_types($2, $5))\n\terr(&quot;invalid operands to relational operator&quot;);\n$$ = $3 + (get_type($2) - 1) * RELOP_NUMBER;\ngen_cmp($2, $5);\n}";

static char* return_statement_c = "_RETURN num_exp _SEMICOLON\n{\nif(!check_types(fun_idx, $4))\n\terr(&quot;incompatible types in return&quot;);\ngen_mov($4, FUN_REG);\n}";

#endif

