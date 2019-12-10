(define (factorial n)
	(define (fact-iter prod count)
		(if (> count n)
			prod
			(fact-iter (* prod count) (+ count 1))))
	(fact-iter 1 1))
