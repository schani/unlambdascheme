(defrecmacro (whole-add i1 i2 c)
    (cond ((and (null? i1) (null? i2))
	   (if c
	       (cons c ())
	       ()))
	  ((null? i1)
	   (if c
	       (whole-add (cons c ()) i2 #f)
	       i2))
	  ((null? i2)
	   (whole-add i2 i1 c))
	  (else
	   (if (car i1)
	       (if (car i2)
		   (if c
		       (cons #t (whole-add (cdr i1) (cdr i2) #t)) ;d1 d2 c
		       (cons #f (whole-add (cdr i1) (cdr i2) #t))) ;d1 d2 !c
		   (if c
		       (cons #f (whole-add (cdr i1) (cdr i2) #t)) ;d1 !d2 c
		       (cons #t (whole-add (cdr i1) (cdr i2) #f)))) ;d1 !d2 !c
	       (if (car i2)
		   (if c
		       (cons #f (whole-add (cdr i1) (cdr i2) #t)) ;!d1 d2 c
		       (cons #t (whole-add (cdr i1) (cdr i2) #f))) ;!d1 d2 !c
		   (if c
		       (cons #t (whole-add (cdr i1) (cdr i2) #f)) ;!d1 !d2 c
		       (cons #f (whole-add (cdr i1) (cdr i2) #f)))))))) ;!d1 !d2 !c

(defrecmacro (read-binary so-far)
    (if (read-char?)
	(cond ((read-char=? #\0)
	       (read-binary (cons #f so-far)))
	      ((read-char=? #\1)
	       (read-binary (cons #t so-far)))
	      (else
	       so-far))
	so-far))

(defrecmacro (write-binary i)
    (if (null? i)
	#f
	(begin
	 (write-binary (cdr i))
	 (if (car i)
	     (write-char #\1)
	     (write-char #\0)))))

(write-binary (whole-add (read-binary ()) (read-binary ()) #f))
