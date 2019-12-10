(define (iterative-improve good? improve)
	(lambda (guess)
		(if (good? guess)
		     guess
		     ((iterative-improve good? improve) (improve guess)))))

(define tolerance 0.00001)
(define (fixed-point func first-guess)
	(define (good? guess)
		(< (abs (- (func guess) guess)) tolerance))
	((iterative-improve good? func) first-guess))

(define (sqrt x)
	(define (average a b) (/ (+ a b) 2))
	(fixed-point (lambda (y) (average y (/ x y))) 1.0))
