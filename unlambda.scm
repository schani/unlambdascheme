(define *current-char* '())
(define *input-string* "kurdenb")

(define (read-char?)
    (if (= (string-length *input-string*) 0)
	#f
	(begin
	 (set! *current-char* (string-ref *input-string* 0))
	 (set! *input-string* (substring *input-string* 1 (string-length *input-string*)))
	 #t)))

(define (read-char=? c)
    (if (char=? *current-char* c)
	#t
	#f))
