# Makefile
all: assem
assem: assem.o
	gcc -o $@  $+
assem.o : assem.s
	as -g -mfpu=vfpv2 -o $@ $<
clean:
	rm -vf assem *.o