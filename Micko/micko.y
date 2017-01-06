%{
  #include <stdio.h>
  #include "defs.h"
  #include "symtab.h"
  #include "codegen.h"
  #include <string.h>
  bool check_types(int first_index, int second_index);

  extern int yylineno;
  char char_buffer[CHAR_BUFFER_LENGTH];
  int error_count = 0;
  int warning_count = 0;
  int var_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;
  int lab_num = -1;
  FILE *output;
  FILE *colormc;  
  FILE *rout;

  /*crvena zuta zelena plava ljubicasta */

  int r[]={	255,255,0,0,0,
		255,191,0,0,64,
		255,128,0,0,127,
		255,64,0,0,191,

		255,255,70,70,70,
		255,209,70,70,116,
		255,162,70,70,162,
		255,116,70,70,209,

		204,204,0,0,0,
		204,153,0,0,51,
		204,102,0,0,102,
		204,51,0,0,153};

  int g[]={	0,255,255,255,0,
		64,255,255,191,0,
		128,255,255,127,0,
		191,255,255,64,0,

		70,255,255,255,70,
		116,255,255,209,70,
		162,255,255,162,70,
		209,255,255,116,70,

		0,204,204,204,0,
		51,204,204,153,0,
		102,204,204,102,0,
		153,204,204,51,0};

  int b[]={	0,0,0,255,255,
		0,0,64,255,255,
		0,0,128,255,255,
		0,0,191,255,255,

		70,70,70,255,255,
		70,70,116,255,255,
		70,70,162,255,255,
		70,70,209,255,255,

		0,0,0,204,204,
		0,0,51,204,204,
		0,0,102,204,204,
		0,0,153,204,204};

  int c=0;
  int ind=0;
  char* style="style=\"background-color:rgb(";
  char* hindent=";padding-left:";
  char* tab="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
%}

%union {
  int i;
  char *s;
}


%token <i> _TYPE
%token _IF
%token _ELSE
%token _RETURN
%token <s> _ID
%token <s> _INT_NUMBER
%token <s> _UINT_NUMBER
%token _LPAREN
%token _RPAREN
%token _LBRACKET
%token _RBRACKET
%token _ASSIGN
%token _SEMICOLON
%token <i> _AROP
%token <i> _RELOP

%type <i> type num_exp exp literal parameter
%type <i> function_call argument rel_exp

%nonassoc ONLY_IF
%nonassoc _ELSE

%%

program
  : function_list_print
      { 
        int idx;
        if((idx = lookup_symbol("main", FUN)) == -1)
          err("undefined reference to 'main'");
        else 
          if(get_type(idx) != INT)
            warn("return type of 'main' is not int"); 

	rprint("<code title=\"%s\">",program_c);
	rprint(" program ");
	rprint("</code>");
      }
  ;

function_list_print
  : function_list { rprint("<code> function_list </code><br/> "); }

function_list
  : function
  | function_list function	
  ;

function
  :   { 
	code("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
     	cprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,ind);
	rprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0);
      	ind+=ISTEP; c++; if(c>=60) c=0;
      }	
	type _ID
      {
        if($2==INT)
		cprint("int ");
        if($2==UINT)
        	cprint("unsigned ");
        cprint("%s (",$3);
	
        fun_idx = insert_symbol($3, FUN, $2, NO_ATTR);
        
	code("\n%s:", $3);
        code("<br/>%s\n\t\t\tPUSH\t%%14",tab);
        code("<br/>%s\n\t\t\tMOV \t%%15,%%14",tab);
      }
    	_LPAREN parameter _RPAREN
      {
        cprint(")\n<br/>");
        set_attr(fun_idx, $6);
        var_num = 0;
      }
    	body
      {
        if (get_last_element() > fun_idx)
          clear_symbols(fun_idx + 1);

        gen_sslab($3,"_exit");
        code("<br/>%s\n\t\t\tMOV \t%%14,%%15",tab);
        code("<br/>%s\n\t\t\tPOP \t%%14",tab);
        code("<br/>%s\n\t\t\tRET<br/>",tab);
	
	code("<br/></code>");
	cprint("<br/></code>");
	rprint("<code title=\"%s\"> function </code>",function_c);
	rprint("</code><br/><br/>");
	ind-=ISTEP;
      }
  ;

type
  : _TYPE
      { $$ = $1; 
	rprint("<code title=\"%s\">",type_c); 
	rprint(" type "); 
	rprint("</code>"); 
      }
  ;

parameter
  : /* empty */
      { $$ = 0; rprint("<code title=\"%s\">",parameter_c_empty); rprint(" parameter "); rprint("</code><br/>"); }

  |   { 	
	code("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
	cprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
	rprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0);
	c++; if(c>=60) c=0;
      }
	type _ID
      {	
        insert_symbol($3, PAR, $2, 1);
        set_ptyp(fun_idx, $2);
        $$ = 1; // samo 1 parametar

	if($2==INT)
		cprint("int ");
        if($2==UINT)
        	cprint("unsigned ");
	cprint(" %s",$3);
	cprint("</code>");
	code("</code>");
	rprint("<code title=\"%s\"> parameter </code>",parameter_c);
	rprint("</code><br/>");
      }
  ;

body
  : _LBRACKET { cprint("{\n<br/>"); } variable_list_print
      {
        if (var_num)
	{
          code("<br/>%s\n\t\t\tSUBS\t%%15,$%d,%%15", tab, 4*var_num);
	  int i;
	  for(i=0;i<var_num;i++){
	  	code("</code>");
	  	cprint("</code>");
	  }
	}
	rprint("<br/>");
	c++; if(c>=60) c=0;
        gen_sslab(get_name(fun_idx), "_body");
      }
    statement_list_print _RBRACKET { rprint("<code title=\"%s\"> body </code>",body_c); cprint("}\n<br/>"); }
  ;

variable_list_print
  : variable_list { rprint(" variable_list "); }
  ;

variable_list
  : /* empty */
  | variable_list variable
  ;

variable
  :   { 
	code("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
	cprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,ind);
	rprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0);
	/*r=(r+20)%220; g=(g+0)%220; b=(b+20)%220;*/ ind+=ISTEP;
      } 
	type _ID _SEMICOLON
      {         
        if(lookup_symbol($3, PAR) != -1)
           err("redefinition of '%s'", $3);
        else 
           insert_symbol($3, VAR, $2, ++var_num);
	
	if($2==INT)
		cprint("int ");
        if($2==UINT)
        	cprint("unsigned ");
	cprint(" %s;\n<br/>",$3);
	
	rprint("<code title=\"%s\"> variable </code>",variable_c);
	rprint("</code>");

	//code("</variable>");
        //cprint("</variable>");
	ind-=ISTEP;
      }
  ;

statement_list_print
  : statement_list { rprint(" statement_list "); }
  ;

statement_list
  : /* empty */
  | statement_list statement
  ;

statement
  : compound_statement
  | assignment_statement
  | if_statement_print
  | return_statement
  ;

compound_statement
  : _LBRACKET { cprint("{\n<br/>"); } statement_list_print _RBRACKET { cprint("}\n<br/>"); rprint(" compound_statement "); }
  ;

assignment_statement
  :   { code("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
	cprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,ind);
	rprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0);
	ind+=ISTEP; c++; if(c>=60) c=0;
      }
	_ID _ASSIGN { cprint("%s = ", $2); } num_exp _SEMICOLON
      {
	cprint(";\n<br/>");

        int i;
        if( (i = lookup_symbol($2, (VAR|PAR))) == -1 )
          err("invalid lvalue '%s' in assignment", $2);
        else
          if(!check_types(i, $5))
            err("incompatible types in assignment");
        gen_mov($5, i);

	code("</code>");
	cprint("</code>");
	rprint("<code title=\"%s\"> assignment_statement </code>",assignment_statement_c);
	rprint("</code><br/>");
	ind-=ISTEP;
      }
  ;

num_exp
  : exp
  | num_exp _AROP 
	{ if ($2==ADD) cprint(" + "); if ($2==SUB) cprint(" - "); if ($2==MUL) cprint(" * "); if ($2==DIV) cprint(" / "); }
	 exp
      {
        if(!check_types($1, $4))
          err("invalid operands: arithmetic operation");
        $$ = gen_arith($2, $1, $4);
	rprint("<code title=\"%s\"> num_exp </code>",num_exp_c);
      }
  ;

exp
  : literal	{ rprint(" exp "); }
  | _ID
      {
        if( ($$ = lookup_symbol($1, (VAR|PAR))) == -1)
          err("'%s' undeclared", $1);

	 cprint("%s", $1);
	 rprint("<code title=\"%s\"> exp </code>",exp_c_id);
      }

  | function_call
      {
        $$ = take_reg();
        gen_mov(FUN_REG, $$);
	rprint("<code title=\"%s\"> exp </code>",exp_c_fc);
      }
  
  | _LPAREN { cprint("("); } num_exp _RPAREN { cprint(")"); }
      { $$ = $3; rprint("<code title=\"%s\"> exp </code>",exp_c_ne); }
  ;

literal
  : _INT_NUMBER
      { cprint("%s", $1); $$ = insert_literal($1, INT); rprint("<code title=\"%s\"> literal </code>",literal_c_int); }

  | _UINT_NUMBER
      { cprint("%s", $1); $$ = insert_literal($1, UINT); rprint("<code title=\"%s\"> literal </code>",literal_c_uint); }
  ;

function_call
  : _ID 
      { 

	code("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
	cprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0);
	rprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
	c++; if(c>=60) c=0;

        if((fcall_idx = lookup_symbol($1, FUN)) == -1)
          err("'%s' is not a function", $1);
	
	cprint("%s", $1);
      }
    _LPAREN { cprint("("); } argument _RPAREN { cprint(")"); }
      {
        if (get_attr(fcall_idx) != $5)
          err("wrong number of arguments to function '%s'",
            get_name(fcall_idx));
        gen_fcall(fcall_idx);
        gen_clear_args($5);
        set_reg_type(FUN_REG, get_type(fcall_idx));
        $$ = FUN_REG;

	code("</code>");
	cprint("</code>");
	rprint("<code title=\"%s\"> function_call </code>",function_call_c);
	rprint("</code><br/>");
      }
  ;

argument
  : /* empty */
      { $$ = 0; rprint("<code title=\"%s\"> argument </code>",argument_c_empty); }

  | num_exp
      { 
        if(get_ptyp(fcall_idx) != get_type($1))
           err("incompatible type for argument in '%s'",
              get_name(fcall_idx));
        gen_push($1);
        $$ = 1; // samo 1 argument
	rprint("<code title=\"%s\"> argument </code>",argument_c_ne);
      }
  ;

if_statement_print
  : { rprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); } if_statement
  ;

if_statement
  : if_part %prec ONLY_IF
      { gen_snlab("exit", lab_num); code("</code>"); cprint("</code>"); ind-=ISTEP; rprint("<code title=\"%s\"> if_statement </code>",if_statement_c_oi); rprint("</code><br/>"); }

  | if_part _ELSE { cprint("<code style=\"padding-left: %ipx;\">else\n</code><br/>",ind-ISTEP); } statement
      { gen_snlab("exit", lab_num); code("</code>"); cprint("</code>"); ind-=ISTEP; rprint("<code title=\"%s\"> if_statement </code>",if_statement_c_e); rprint("</code><br/>"); }
  ;

if_part
  :   { 
	code("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
	cprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,ind); 
	ind+=ISTEP; c++; if(c>=60) c=0;
      } 
	_IF _LPAREN
      {
        cprint("if (");
        lab_num++;
        gen_snlab("if", lab_num);
      }
    	rel_exp
      {
        code("<br/>%s\n\t\t\t%s\t@false%d", tab, get_opjump($5),lab_num);
        gen_snlab("true", lab_num);
      }
   	_RPAREN { cprint(")\n<br/>"); } statement
      {
        code("<br/>%s\n\t\t\tJMP \t@exit%d", tab, lab_num);
        gen_snlab("false", lab_num);
	rprint("<code title=\"%s\"> if_part<br/> </code>",if_part_c);
      }
  ;

rel_exp
  :   { 
	code("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
	cprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0);
	rprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
	c++; if(c>=60) c=0;
      } 
	num_exp _RELOP 
      { 
	if($3==LT) cprint("&lt;"); 
	else if($3==GT) cprint("&gt;"); 
	else if($3==LE) cprint("&lt;="); 
	else if($3==GE) cprint("&gt;="); 
	else if($3==EQ) cprint("=="); 
	else cprint("!="); 
      } 
	num_exp
      {
        if(!check_types($2, $5))
          err("invalid operands to relational operator");
        $$ = $3 + (get_type($2) - 1) * RELOP_NUMBER;
        gen_cmp($2, $5);

	code("</code>");
	cprint("</code>");
	rprint("<code title=\"%s\"> rel_exp </code>",rel_exp_c);
	rprint("</code><br/>");	
      }
  ;

return_statement
  :   { 
	code("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0); 
	cprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,ind);
	rprint("<code %s%i,%i,%i)%s%ipx;\">",style,r[c],g[c],b[c],hindent,0);
	ind+=ISTEP; c++; if(c>=60) c=0;
      } 
	_RETURN { cprint("return "); } num_exp _SEMICOLON
      { 
        cprint(";\n<br/>");

        if(!check_types(fun_idx, $4))
          err("incompatible types in return");
        gen_mov($4, FUN_REG);

        code("<br/>%s\n\t\t\tJMP \t@%s_exit", tab, get_name(fun_idx));   
	code("</code>");
	cprint("</code>");
	rprint("<code title=\"%s\"> return_statement </code>",return_statement_c);
	rprint("</code><br/>");
	ind-=ISTEP;
      }
  ;

%%

int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s\n", yylineno, s);
  error_count++;
  return 0;
}

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  warning_count++;
}

// Proverava tipove 2 elementa u tabeli simbola.
bool check_types(int first_index, int second_index) {
   unsigned t1 = get_type(first_index);
   unsigned t2 = get_type(second_index);
   if(t1 == t2 && t1 != NO_TYPE)
      return TRUE;
   else
      return FALSE;
}

int main() {
  int synerr;
  init_symtab();
  output = fopen("output.html", "w+");
  colormc = fopen("color_mc.html", "w+");
  rout = fopen("rules.html", "w+");
  code("<!DOCTYPE html>\n<html>\n<head>\n\t<meta charset=\"UTF-8\">\n\t<title>Assembly\n</title>\n</head>\n<body>\n");
  rprint("<!DOCTYPE html>\n<html>\n<head>\n\t<meta charset=\"UTF-8\">\n\t<title>Rules\n</title>\n</head>\n<body>\n");
  cprint("<!DOCTYPE html>\n<html>\n<head>\n\t<meta charset=\"UTF-8\">\n\t<title>Minic\n</title>\n</head>\n<body>\n");

  synerr = yyparse();
  
  clear_symtab();

  code("\n</body>\n</html>");
  rprint("\n</body>\n</html>");
  cprint("\n</body>\n</html>");
  fclose(output);
  fclose(colormc);  
  fclose(rout);  

  if(warning_count)
    printf("\n%d warning(s).\n", warning_count);

  if(error_count) {
    remove("output.html");
    printf("\n%d error(s).\n", error_count);
  }

  if (synerr)
    return -1;
  else
    return error_count;
}

