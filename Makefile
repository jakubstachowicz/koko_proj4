#
CC=gcc
LEX=flex

% : %.tab.o %.o 
	$(CC) $< $*.o $(LDFLAGS) -o $@

%.tab.c %.tab.h: %.y
	bison -d $<

%.c: %.l %.tab.h
	$(LEX) -t $< > $@

p: p.y p.l

clean:
	rm -f p p.c p.tab.c p.tab.h *.o
