;;; f(n) = | n   if   n < 3,
;;;        | f(n-1) + 2f(n-2) + 3f(n-3)  if   n >= 3

(define (f-recursive n)
	(if (< n 3)
		n
		(+ (     f-recursive (- n 1))
		   (* 2 (f-recursive (- n 2)))
		   (* 3 (f-recursive (- n 3))))))

(define (f-iterative n)
	(define (iter a b c n)
		(if (< n 3)
		    a
		    (iter (+ c c c b b a) a b (- n 1))))
	(if (> n 2) (iter 2 1 0 n) n))

;;; recursive choose function
(define (choose n m)
	(cond ((or (= m n) (= m 0)) 1)
	      ((or (> m n) (< m 0)) 0)
	      (else (+ (choose (- n 1) (- m 1)) (choose (- n 1) m)))))
