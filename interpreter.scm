;(define (apply fun arg)
;    (let ((env (poor-car fun))
;	  (body (poor-cdr fun)))
;      (eval (poor-cdr fun) (poor-cons arg (poor-car fun))))

;(define poor-cons (lambda (a) (lambda (b) (cons a b))))
;(define poor-car car)
;(define poor-cdr cdr)
;(define (*write-char* c) (lambda (x) (write-char c) x))

;(

(lambda (code)
  (letrec ((get (lambda (env pos)
		  (if (null? pos)
		      env
		      ((car pos) (get (get env (cdr pos)) (cdr pos))))))
	   (eval (lambda (expr env)
;		   (let ((data (poor-cdr expr)))
		     (if (poor-car (poor-car expr))	;type0
			 (if (poor-cdr (poor-car expr)) ;type1
			     ;; lambda
			     ((poor-cons env) (poor-cdr expr))
			     ;; apply
			     (let ((fun (eval (poor-car (poor-cdr expr)) env)))
			       (eval (poor-cdr fun) ((poor-cons (eval (poor-cdr (poor-cdr expr)) env)) (poor-car fun)))))
					;	      (apply (eval (poor-car data)) (eval (poor-cdr data))))
			 (if (poor-cdr (poor-car expr)) ;type1
			     ;; get
			     (poor-car (get env (poor-cdr expr)))
			     ;; native
			     ((poor-cons ()) ((poor-cdr expr) ((poor-cons ((poor-cons #t) #t)) ((poor-cons ((poor-cons #f) #t)) ())))))))))
	  (eval code ())))

;((poor-cons ((poor-cons #t) #f)) ((poor-cons ((poor-cons ((poor-cons #t) #t)) ((poor-cons ((poor-cons #t) #f)) ((poor-cons ((poor-cons ((poor-cons #f) #f)) (*write-char* #\newline))) ((poor-cons ((poor-cons #t) #t)) ((poor-cons ((poor-cons #f) #t)) ())))))) ((poor-cons ((poor-cons #t) #f)) ((poor-cons ((poor-cons ((poor-cons #f) #f)) (*write-char* #\d))) ((poor-cons ((poor-cons #t) #t)) ((poor-cons ((poor-cons #f) #t)) ())))))))





