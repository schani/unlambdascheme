(define true
    (lambda (t f)
      t))

(define false
    (lambda (t f)
      f))

(define if
    (lambda (c t e)
      (c t e)))

(define cons
    (lambda (a b)
      (lambda (f)
	(f a b false))))

(define nil
    (lambda (f)
      (f nil nil true)))

(define car
    (lambda (c)
      (c (lambda (a b p)
	   a))))

(define cdr
    (lambda (c)
      (c (lambda (a b p)
	   b))))

(define null?
    (lambda (c)
      (c (lambda (a b p)
	   p))))



(letrec ((a (lambda (x)
	      (b x)))
	 (b (lambda (x)
	      (a x))))
	(a 1))


((lambda (a b)
   (a 1 a b))
 (lambda (x a b)
   (b x a b))
 (lambda (x a b)
   (a x a b)))




((lambda (a b)
   ((lambda (x)
      (a x a b))
    1))
 (lambda (x a b)
   ((lambda (x)
      (b x a b))
    x))
 (lambda (x a b)
   ((lambda (x)
      (a x a b))
    x)))
