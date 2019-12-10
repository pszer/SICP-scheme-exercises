(define (average a b) (/ (+ a b) 2))

(define tolerance 0.00001)

(define (fixed-point f first-guess)
	(define (close-enough? v1 v2)
		(< (abs (- v1 v2)) tolerance))
	(define (try guess)
		(let ((next (f guess)))
			;(display next) (newline)
			(if (close-enough? guess next)
			     next
			     (try next))))
	(try first-guess))

(define (damp-fixed-point f first-guess)
	(fixed-point (lambda (x) (average x (f x))) first-guess))

(define dx 0.00001)
(define (deriv g)
	(lambda (x) (/ (- (g (+ x dx)) (g x)) dx)))
(define (newtons-transform g)
	(lambda (x) (- x (/ (g x) ((deriv g) x)))))
(define (newtons-method g guess)
	(fixed-point (newtons-transform g) guess))

(define (cubic a b c)
	(define (cube   x) (* x x x))
	(define (square x) (* x x))
	(lambda (x) (+ (cube x) (* a (square x)) (* b x) c)))
(define (solve-cubic a b c start)
	(newtons-method (cubic a b c) start))
