(define (make-interval a b) (cons a b))
(define (lower-bound int) (car int))
(define (upper-bound int) (cdr int))

(define (make-center-width c w)
	(make-interval (- c w) (+ c w)))
(define (make-center-percent c p)
	(define (percent-ratio perc) (/ perc 100.0))
	(make-center-width c (* c (percent-ratio p))))

(define (percent int)
	(* 100.0 (/ (width int) (center int))))
(define (center int)
	(/ (+ (lower-bound int) (upper-bound int)) 2))
(define (width int)
	(/ (- (upper-bound int) (lower-bound int)) 2))

(define (print-interval int)
	(display "[") (display (lower-bound int))
	(display ",") (display (upper-bound int))
	(display "]") (newline))

(define (add-interval x y)
	(make-interval (+ (lower-bound x) (lower-bound y))
	               (+ (upper-bound x) (upper-bound y))))
(define (sub-interval x y)
	(make-interval (- (lower-bound x) (upper-bound y))
	               (- (upper-bound x) (lower-bound y))))
(define (mul-interval x y)
	(let ((p1 (* (lower-bound x) (lower-bound y)))
	      (p2 (* (lower-bound x) (upper-bound y)))
	      (p3 (* (upper-bound x) (lower-bound y)))
	      (p4 (* (upper-bound x) (upper-bound y))))
	(make-interval (min p1 p2 p3 p4)
	               (max p1 p2 p3 p4))))
(define (div-interval x y)
	(if (and (<= (lower-bound y) 0) (>= (upper-bound y) 0))
		(error "division by interval that spans 0" y)
		(mul-interval
			x
			(make-interval (/ 1.0 (upper-bound y))
			               (/ 1.0 (lower-bound y))))))

(define (par1 r1 r2)
	(div-interval (mul-interval r1 r2) (add-interval r1 r2)))
(define (par2 r1 r2)
	(let ((one (make-interval 1 1)))
		(div-interval
			one (add-interval (div-interval one r1) (div-interval one r2)))))

;;; 2.16
;;; Equivalent algebraic expressions may lead to different answers because they
;;; lead to different degrees of freedom
;;; for example
;;;
;;; par 1: (R1*R2)/(R1+R2)
;;; par 2: 1/(1/R1 + 1/R2)
;;;
;;; in par2, the interval calculated is in fact the minimum and maximum
;;; of that expression for the intervals of R1 and R2.
;;;
;;; in par1, there are two instances of each interval R1 and R2. they are
;;; both intervals but the REAL precise value of R1 and R2 should exist, therefore
;;; both R1s and R2s instances should be treated as having the same exact value
;;; when calculating the interval, but this is not the case. each interval is its
;;; own interval data structure with no memory of what other intervals are the same
;;; 'instance' of it, so they each give a degree of freedom in the interval of the
;;; final expression.
;;;
;;; a proper interval-arithmetic package is possible, it can be thought of as having
;;; a slider for each different interval variable, and testing their values at a load
;;; of different positions of their sliders and finding the minimum and maxiumum of the
;;; interval expression. by testing enough points a highly accurate answer should be possible.
