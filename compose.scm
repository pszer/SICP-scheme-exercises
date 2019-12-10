(define (repeated f n)
	(define (iter composition i)
		(if (= i n)
		    composition
		    (iter (compose composition f) (+ i 1))))
	(iter f 1))
