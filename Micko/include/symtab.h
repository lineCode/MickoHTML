
#ifndef SYMTAB_H
#define SYMTAB_H

// Element tabele simbola
typedef struct sym_entry {
   char *name;             // ime simbola
   unsigned kind;          // vrsta simbola
   unsigned type;          // tip vrednosti simbola
   int attr;               // dodatni attribut simbola
   unsigned ptyp;          // tip parametra funkcije
} SYMBOL_ENTRY;

// Vraca indeks prvog sledeceg praznog elementa.
int get_next_empty_element(void);

// Vraca indeks poslednjeg zauzetog elementa.
int get_last_element(void);

// Ubacuje simbol 
// i vraca indeks ubacenog elementa u tabeli simbola ili -1.
int insert_sym(char *name, unsigned kind, unsigned type, int attr);

// Proverava da li se simbol vec nalazi u tabeli simbola, 
// ako se ne nalazi ubacuje ga, ako se nalazi ispisuje gresku.
// Vraca indeks elementa u tabeli simbola.
int insert_symbol(char *name, unsigned kind, unsigned type, int attr);

// Ubacuje konstantu u tabelu simbola (ako vec ne postoji).
int insert_literal(char *str, unsigned type);

// Vraca indeks pronadjenog simbola ili vraca -1.
int lookup_symbol(char *name, unsigned kind);

// Vraca indeks pronadjene konstante ili vraca -1.
int lookup_literal(char *name, unsigned type);

// set i get metode za polja elementa tabele simbola
char*    get_name(int index);
unsigned get_kind(int index);
unsigned get_type(int index);
void     set_attr(int index, int attr);
unsigned get_attr(int index);
void     set_reg_type(int reg_index, unsigned type);
void     set_ptyp(int index, unsigned type);
unsigned get_ptyp(int index);

// Brise elemente tabele od zadatog indeksa
void clear_symbols(unsigned begin_index);

// Brise sve elemente tabele simbola.
void clear_symtab(void);

// Ispisuje sve elemente tabele simbola.
void print_symtab(void);
unsigned logarithm2(unsigned value);

// Inicijalizacija tabele simbola.
void init_symtab(void);

#endif
