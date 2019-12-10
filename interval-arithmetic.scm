;;; a proper interval arithmetic package that can
;;; calculate intervals for any algebraic expression
;;; of intervals

;;; interval constructor and selectors and other
;;; misc procedures
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
(define (span int)
	(- (upper-bound int) (lower-bound int)))

(define (print-interval int)
	(display "[") (display (lower-bound int))
	(display ",") (display (upper-bound int))
	(display "]") (newline))

;;; expr is a lambda function which takes in
;;; an argument for every interval e.g
;;; (lambda (R1 R2 R3) (/ (* R1 R2) (+ R1 R2 R3)))
;;; int-list is a list of intervals
(define (calculate-interval expr int-list)
	(define int-count (length int-list))
	(define first-calc #t)
	(define max-found 0)
	(define min-found 0)
	(define steps 20) ; steps for each interval

	; list init functions
	(define (map-start n) (lower-bound (list-ref int-list n)))
	(define (map-step  n) (/     (span (list-ref int-list n)) steps))
	(define (map-end   n) (upper-bound (list-ref int-list n)))

	; helper lists
	(define start-list (make-initialized-list int-count map-start))
	(define step-list  (make-initialized-list int-count map-step))
	(define end-list   (make-initialized-list int-count map-end))

	; gets a list of interval values, replaces max-found min-found
	; if new minimum/maximum found
	(define (calc-interval vals)
		(let ((num (apply expr vals)))
			(if first-calc
				(begin
					(set! max-found num)
					(set! min-found num)
					(set! first-calc #f))
				(begin
					(set! max-found (max num max-found))
					(set! min-found (min num min-found))))))

	(define (iter vals k)
		;;; if k is smaller than int-count, continue iteration
		(if (= k int-count)
			(calc-interval vals)
		(begin
			(iter (list-copy vals) (+ k 1))
			;;; this loops through values start->end for interval index k
			(if (< (list-ref vals k) (list-ref end-list k))
				(begin
					(list-set! vals k (+ (list-ref vals k) (list-ref step-list k)))
					(iter vals k))))))

	(iter start-list 0)
	(make-interval min-found max-found))

(define (par1 r1 r2)
	(calculate-interval (lambda (a b) (/ (* a b) (+ a b))) (list r1 r2)))
(define (par2 r1 r2)
	(calculate-interval (lambda (a b) (/ 1 (+ (/ 1 a) (/ 1 b)))) (list r1 r2)))

(print-interval (calculate-interval (lambda (a b c d e f) (* a b c d e f))
(list (make-interval 10 15) (make-interval 10 15) (make-interval 10 15) (make-interval 10 15) (make-interval 10 15) (make-interval 10 15))))
