(letrec ((r (lambda ()
	      (if (read-char?)
		  (begin
		   (write-char #\*)
		   (r))
		  ()))))
	(r))
