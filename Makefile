all : unlcomp interpreter.unl.gz

unlcomp : translate.scm
	bigloo -Obench -o unlcomp $<

interpreter.unl.gz : interpreter.scm unlcomp
	./unlcomp -c interpreter.scm | ./peephole.pl | gzip -c - >interpreter.unl.gz

clean :
	rm -f *~ unlcomp interpreter.unl.gz *.o

dist :
	rm -rf unlambdascheme
	mkdir unlambdascheme
	mkdir unlambdascheme/examples
	cp README COPYING Makefile compile interpreter.scm peephole.pl translate.scm unlambdascheme/
	cp examples/binary-adder.scm examples/fibunl.scm unlambdascheme/examples/
	tar -zcvf unlambdascheme.tar.gz unlambdascheme
	rm -rf unlambdascheme
