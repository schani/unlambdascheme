all : unlcomp interpreter.unl.gz

unlcomp : translate.scm
	bigloo -Obench -o unlcomp $<

interpreter.unl.gz : interpreter.scm unlcomp
	./unlcomp -c interpreter.scm | ./peephole.pl | gzip -c - >interpreter.unl.gz

clean :
	rm -f *~ unlcomp interpreter.unl.gz *.o
