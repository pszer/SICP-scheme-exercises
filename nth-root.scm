(load "compose.scm")
(load "fixed-point.scm")

(define (damp f) (lambda (x) (average x (f x))))
(define (nth-damp-fixed-point f first-guess n)
	(let ((nth-damped ((repeated damp n) f)))
	      (fixed-point nth-damped first-guess)))

(define logB (lambda (x B) (/ (log x) (log B))))

(define (nth-root x n)
	(let ((damps (floor (logB n 2))))
	(nth-damp-fixed-point
		(lambda (y) (/ x (expt y (- n 1)))) 1.0 damps)))
