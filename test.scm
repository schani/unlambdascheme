(begin
 (write-char #\b)
 (write-char #\l)
 (write-char #\a))

(if (read-char?)
    (write-char #\+)
    (write-char #\-))

(begin
 (read-char?)
 (if (read-char=? #\x)
     (write-char #\+)
     (write-char #\-)))


(lambda (x)
  (lambda (y)
    (lambda (z)
      (lambda (a)
	(lambda (b)
	  (lambda (c)
	    (lambda (d)
	      (lambda (e)
		x))))))))

((lambda (x)
   x)
 (lambda (x)
   x))


(lambda (i1 i2)
  (let add ((i1 i1) (i2 i2) (c #f))
       (cond ((and (null? i1) (null? i2))
	      (if c
		  (cons c ())
		  ()))
	     ((null? i1)
	      (if c
		  (add (cons c ()) i2 #f)
		  i2))
	     ((null? i2)
	      (add i2 i1 c))
	     (else
	      (let ((d1 (car i1))
		    (r1 (cdr i1))
		    (d2 (car i2))
		    (r2 (cdr i2)))
		(cond ((and (not d1) (not d2) (not c))
		       (cons #f (add r1 r2 #f)))
		      ((or (and d1 (not d2) (not c))
			   (and (not d1) d2 (not c))
			   (and (not d1) (not d2) c))
		       (cons #t (add r1 r2 #f)))
		      ((or (and d1 d2 (not c))
			   (and d1 (not d2) c)
			   (and (not d1) d2 c))
		       (cons #f (add r1 r2 #t)))
		      (else
		       (cons #t (add r1 r2 #t)))))))))


(poor-and #t (poor-and #t (poor-and #t (poor-and #t #t))))

;((lambda (a b)
;   (a (b)))
; (lambda (x)
;   (write-char #\newline))
; (lambda ()
;   (write-char #\d)))

;(letrec ((print (lambda (l)
;		  (if (null? l)
;		      (write-char #\newline)
;		      (begin
;		       (write-char #\*)
;		       (print (cdr l)))))))
;	(print (cons #f (cons #f (cons #f ())))))

;(if (**read-char** **i**)
;    (write-char #\+)
;    (write-char #\-))


;(letrec ((loop (lambda ()
;		 (if (read-char?)
;		     (begin
;		      (write-char #\*)
;		      (loop))
;		     #f))))
;	(loop))

;(begin
; (write-char #\d)
; (write-char #\newline))

;(lambda ()
;  (lambda (x)
;    x))

;(if #f
;    (write-char #\+)
;    (write-char #\-))


(letrec ((read (lambda ()
		 (if (and (read-char?) (read-char=? #\x))
		     (begin
		      (write-char #\*)
		      (read))
		     (write-char #\newline)))))
	(read))
