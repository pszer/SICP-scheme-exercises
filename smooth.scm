;;; 'smooths' function

;;; for n-th repeated smoothing
(load "compose.scm")

(define (smooth f)
	(define dx 0.00001)
	(define (average a b c) (/ (+ a b c) 3))
	(lambda (x) (average (f (- x dx)) (f x) (f (+ x dx)))))

(define (n-smooth f n)
	(repeated (smooth f) n))
