(define (cont-frac-recur n d k)
	(define (recur i)
		(if (> i k)
		    0
		    (/ (n i)
		       (+ (d i) (recur (+ 1 i))))))
	(recur 1))

(define (cont-frac n d k)
	(define (dec n) (- n 1))
	(define (iter denom i)
		(if (= i 0)
		    denom
		    (iter (/ (n i) (+ (d i) denom)) (dec i))))
	(iter 0 k))

(define (tan-frac x) 
	(define (n i) (if (= i 1) x (- (* x x))))
	(define (d i) (- (* 2 i) 1))
	(cont-frac n d 100))


