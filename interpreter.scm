(defrecmacro (get env pos)
    (if (null? pos)
	env
	((car pos) (get (get env (cdr pos)) (cdr pos)))))

(defrecmacro (eval env expr)
    (if (car (car expr))	;type0
	(if (cdr (car expr)) ;type1
	    ;; lambda
	    (cons env (cdr expr))
	    ;; apply
	    (let ((fun (eval env (car (cdr expr)))))
	      (eval (cons (eval env (cdr (cdr expr)))
			  (car fun))
		    (cdr fun))))
	(if (cdr (car expr)) ;type1
	    ;; get
	    (car (get env (cdr expr)))
	    ;; native
	    (cons () ((cdr expr) (cons (cons #t #t) (cons (cons #f #t) ())))))))

(eval ())
