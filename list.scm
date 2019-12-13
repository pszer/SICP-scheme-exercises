(define (last-pair l)
	(if (null? (cdr l))
		l
		(last-pair (cdr l))))

(define (reverse-list l)
	(define (rev result left)
		(if (null? left)
			result
			(rev (cons (car left) result) (cdr left))))
	(rev '() l))

(define (count-change amount coins)
	(define (no-more? coins) (null? coins))
	(define (first-denomination coins) (car coins))
	(define (except-first-denomination coins) (cdr coins))
	(define (cc amount coin-values)
		(cond 	((= amount 0) 1)
			((or (< amount 0) (no-more? coin-values)) 0)
			(else
				(+ (cc amount
					   (except-first-denomination coin-values))
				   (cc (- amount
				 	   (first-denomination coin-values))
					   coin-values)))))
	(cc amount coins))

(define (same-parity . z)
	(define (iter n result parity)
		(cond ((null? n)
		          result)
		      ((= parity (remainder (car n) 2))
		          (iter (cdr n) (append result (list (car n))) parity))
		      (else
		          (iter (cdr n) result parity))))
	(iter z '() (remainder (car z) 2)))

#|(define (For-each proc l)
	(if (null? l)
		'()
		(begin
			(proc (car l))
			(For-each proc (cdr l)))))|#

(define (count-leaves x)
	(cond ((null? x) 0)
	      ((not (pair? x)) 1)
	      (else (+ (count-leaves (car x))
	               (count-leaves (cdr x))))))

; 2.25
;(define l1 (list 1 3 (list 5 7) 9))
;(define l2 (list (list 7)))
;(define l3 '(1 (2 (3 (4 (5 (6 7)))))))

(define (deep-reverse l)
	(define (rev result left)
		(cond ((null? left) result)
		      ((not (pair? left)) left)
		      (else (rev (cons (rev '() (car left)) result) (cdr left)))))
	(rev '() l))

(define (fringe x)
	(cond ((null? x) '())
	      ((not (pair? x)) (list x))
	      (else (append (fringe (car x))
	                    (fringe (cdr x))))))
