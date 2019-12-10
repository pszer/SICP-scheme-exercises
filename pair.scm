;;; 2^a3^b mad ting pair

;;;(define (logB x B) (/ (log x) (log B)))
(define (cons a b) (* (expt 2 a) (expt 3 b)))
(define (car p)
	(define (iter k i)
		(if (= (remainder k 2) 1)
		    i
		    (iter (/ k 2) (+ i 1))))
	(iter p 0))
(define (cdr p)
	(define (iter k i)
		(if (> (remainder k 3) 0)
		    i
		    (iter (/ k 3) (+ i 1))))
	(iter p 0))

