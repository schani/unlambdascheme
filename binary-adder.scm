(defmacro whole-add
    ((lambda (x) (x x))
     (lambda (self i1 i2 c)
       (cond ((and (null? i1) (null? i2))
	      (if c
		  (cons c ())
		  ()))
	     ((null? i1)
	      (if c
		  (self self (cons c ()) i2 #f)
		  i2))
	     ((null? i2)
	      (self self i2 i1 c))
	     (else
	      (if (car i1)
		  (if (car i2)
		      (if c
			  (cons #t (self self (cdr i1) (cdr i2) #t)) ;d1 d2 c
			  (cons #f (self self (cdr i1) (cdr i2) #t))) ;d1 d2 !c
		      (if c
			  (cons #f (self self (cdr i1) (cdr i2) #t)) ;d1 !d2 c
			  (cons #t (self self (cdr i1) (cdr i2) #f)))) ;d1 !d2 !c
		  (if (car i2)
		      (if c
			  (cons #f (self self (cdr i1) (cdr i2) #t)) ;!d1 d2 c
			  (cons #t (self self (cdr i1) (cdr i2) #f))) ;!d1 d2 !c
		      (if c
			  (cons #t (self self (cdr i1) (cdr i2) #f)) ;!d1 !d2 c
			  (cons #f (self self (cdr i1) (cdr i2) #f)))))))))) ;!d1 !d2 !c

(defmacro read-binary
    ((lambda (x) (x x))
     (lambda (self so-far)
       (if (read-char?)
	   (cond ((read-char=? #\0)
		  (self self (cons #f so-far)))
		 ((read-char=? #\1)
		  (self self (cons #t so-far)))
		 (else
		  so-far))
	   so-far))))

(defmacro write-binary
    ((lambda (x) (x x))
     (lambda (self i)
       (if (null? i)
	   #f
	   (begin
	    (self self (cdr i))
	    (if (car i)
		(write-char #\1)
		(write-char #\0)))))))

(write-binary (read-binary ()))

(write-binary (whole-add (read-binary ()) (read-binary ()) #f))
