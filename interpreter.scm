(defmacro get
    ((lambda (x) (x x))
     (lambda (self env pos)
       (if (null? pos)
	   env
	   ((car pos) (self self (self self env (cdr pos)) (cdr pos)))))))

(defmacro eval
    ((lambda (x) (x x))
     (lambda (self env expr)
       (if (car (car expr))	;type0
	   (if (cdr (car expr)) ;type1
	       ;; lambda
	       ((cons env) (cdr expr))
	       ;; apply
	       (let ((fun (self self env (car (cdr expr)))))
		 (self self ((cons (self self env (cdr (cdr expr)))) (car fun)) (cdr fun))))
					;	      (apply (eval (car data)) (eval (cdr data))))
	   (if (cdr (car expr)) ;type1
	       ;; get
	       (car (get env (cdr expr)))
	       ;; native
	       ((cons ()) ((cdr expr) ((cons ((cons #t) #t)) ((cons ((cons #f) #t)) ())))))))))

(eval ())
