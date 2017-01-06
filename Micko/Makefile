# 1. kompajliranje programa
#       make
# 2. brisanje automatski generisanih fajlova
#       make clean
# 3. pokretanje svih testova
#       make test
# 4. pokretanje samo nekih testova
#       make test TEST=test-ok1.mc
#       make test TEST="test-ok1.mc test-ok2.mc"

# Nazivi test fajlova treba da slede sledeću konvenciju:
#   Početak naziva      Značenje
#     test-sanity       korektan miniC program bez novih konstrukcija (provera originalne gramatike)
#     test-ok           korektan miniC program sa novim konstrukcijama
#     test-semerr       nekorektan miniC program sa (jednom) semantičkom greškom
#     test-synerr       nekorektan miniC program sa (jednom) sintaksnom greškom
# Ukoliko se u test fajlu nalazi red koji počinje sa //OPIS:, ta linija će biti ispisana pre samog testiranja.

# bash je potreban da bi radila redirekcija stderr i stdout, kao i zbog PIPESTATUS promenljive
SHELL = /bin/bash
# naziv kompajlera i osnovnih source fajlova
SRC = micko
# fajlovi od kojih se sastoji kompajler
COMPILER_BUILD = lex.yy.c $(SRC).tab.c symtab.c codegen.c
# fajlovi od kojih zavisi ponovno prevođenje
COMPILER_DEPENDS = $(COMPILER_BUILD) defs.h symtab.h codegen.h
# fajlvi koje treba pobrisati da bi ostao samo izvorni kod
COMPILER_CLEAN = lex.yy.c $(SRC).tab.c $(SRC).tab.h $(SRC).output $(SRC) *.?~ *.mc~ .make.out? *.asm Makefile~
# ako treba sprovesti samo neke testove, ovu promenljivu treba postaviti na naziv testa
TEST = ""

# pravila koja ne generišu nove fajlove
.PHONY: clean test all .make.out1

# potrebno da bi se pre ponovnog prevođenja obrisao .make.out1 fajl
all: .make.out1 $(SRC)

# osnovno pravilo za prevođenje kompajlera
# .make.out1 služi za privremeno smeštanje svih ispisa prilikom prevođenja gramatike
# .make.out2 sadrži ispis poslednjeg uspešnog prevođenja gramatike
$(SRC): $(COMPILER_DEPENDS)
	@echo -e "\e[01;32mGCC...\e[00m"
	@-rm -f $(SRC) .make.out2 2>/dev/null
	@gcc -o $@ $(COMPILER_BUILD) 2>&1 | tee -a .make.out1; pstat=$${PIPESTATUS[0]}; \
	mv .make.out1 .make.out2 2>/dev/null; \
	out=`grep -Ei "conflict|warning|error" .make.out2 2>/dev/null`; \
	if [ "$$out" != "" ]; then \
		echo -e "\e[01;31m\n------ There are errors/warnings in grammar! ------\n\e[00m" ; \
		exit 1; \
	fi; \
	exit $$pstat

lex.yy.c: $(SRC).l $(SRC).tab.c
	@echo -e "\e[01;32mFLEX...\e[00m"
	@flex $< 2>&1 | tee -a .make.out1; exit $${PIPESTATUS[0]}

$(SRC).tab.c: $(SRC).y
	@echo -e "\e[01;32mBISON...\e[00m"
	@bison -d -v $< 2>&1 | tee -a .make.out1; exit $${PIPESTATUS[0]}

clean:
	@echo -e "\e[01;32mCLEAN...\e[00m"
	@rm -f $(COMPILER_CLEAN)

archive: clean
	@echo -e "\e[01;32mCreating archive ../$(SRC).tar.gz\e[00m"
	@tar --exclude=*.gz -czf ../$(SRC).tar.gz ../$(SRC)

.make.out1:
	@-rm -f .make.out1
	@touch .make.out1

# testiranje kompajlera, izvršava se samo ako nema grešaka u gramatici
# - u petlji će se kompajleru proslediti svi test*.c fajlovi
# - ako u test fajlu postoji linija sa tekstom "//OPIS:", ispisaće se na ekranu
# - ukoliko prilikom poziva kompajlera nije bilo grešaka, i ako postoji
#   generisanje koda, ispisaće se i asemblerski izlaz
test: $(SRC)
	@out=`grep -Ei "conflict|warning|error" .make.out2 2>/dev/null`; \
	if [ "$$out" != "" ]; then \
		echo -e "\e[01;31m\n------ There are errors/warnings in grammar! ------\n\e[00m" ; \
		exit 1; \
	fi; \
	if [ "$$TEST" != "" ]; then all_tests=$$TEST; \
	else all_tests=test*.mc; fi; \
	for test in $$all_tests; do \
		if [ $${test:5:6} == "synerr" ]; then echo -e "\e[01;35m"; \
		elif [ $${test:5:6} == "semerr" ]; then echo -e "\e[01;34m"; \
		else echo -e "\e[01;32m"; fi; \
		echo -e "\n\n------------------------\nTesting: $$test"; \
		grep "//OPIS:" $$test; \
		echo -e "------------------------\e[00m"; \
		./$(SRC) < "$$test"; \
		if [ $$? -ne 0 ]; then \
			echo -e "\e[01;31m\n------ Errors during testing of '$$test'! ------\n\e[00m" ; \
		else \
			outname=$$(basename $$test); \
			outname=$${outname%.*}; \
			mv output.asm "$${outname}.asm"; \
			echo -e "\e[01;32m\noutput.asm\e[00m saved as \e[01;32m$${outname}.asm\n\e[00m"; \
			if [ "$${outname:5:6}" == "sanity" ]; then \
				diff -w "$${outname}.asm" "$${outname}.asm.ok" > /dev/null; \
				X=$$?; \
				if [ $$X -ne 0 ]; then \
					echo -e "\e[01;31m\n------ Error: code generation for unmodified miniC is changed! ------"; \
					echo -e "Run\e[00m fldiff $${outname}.asm $${outname}.asm.ok"; \
				fi; \
			fi; \
		fi; \
	done; \
	echo

