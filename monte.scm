(define (random-in-range low high)
	(let ((range (- high low)))
		(+ low (random range))))

(define (random-real-range low high)
	(define cuts 2000000000)
	(if (> low high)
		(random-real-range high low)
		(let ((range (- high low))
			  (foo (random cuts)))
		(+ low (* range (/ foo cuts))))))

(define (monte-carlo trials experiment)
	(define (iter trials-remaining trials-passed)
		(cond
			((= trials-remaining 0)
			 (/ trials-passed trials))
			((experiment)
			 (iter (- trials-remaining 1)
			       (+ trials-passed 1)))
			(else (iter (- trials-remaining 1)
			            trials-passed))))
	(iter trials 0))

;;; (TEST? x y)
(define (monte-integral test? x1 y1 x2 y2)
	(* (area x1 y1 x2 y2)
	   (monte-carlo 1000
					(lambda ()
					   (let ((test-x (random-real-range x1 x2))
							 (test-y (random-real-range y1 y2)))
							(test? test-x test-y))))))

(define (dist x y)
	(define (square n) (* n n))
	(sqrt (+ (square x) (square y))))
(define (unit-circle? x y)
	(<= (dist x y) 1.0))
(define (area x1 y1 x2 y2)
	(let ((dx (- x1 x2))
	      (dy (- y1 y2)))
		(abs (* dx dy))))