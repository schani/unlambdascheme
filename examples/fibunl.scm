(letrec ((append (lambda (x y)
		   (if (null? x)
		       y
		       (cons (car x) (append (cdr x) y)))))
	 (fib (lambda (n)
		(if (null? n)
		    n
		    (if (null? (cdr n))
			n
			(append (fib (cdr (cdr n)))
				(fib (cdr n)))))))
	 (output (lambda (n)
		   (if (null? n)
		       (write-char #\newline)
		       (begin
			(write-char #\*)
			(output (cdr n)))))))
	(output (fib (cons () (cons () (cons () (cons () (cons () (cons () ())))))))))
