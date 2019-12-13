(define (smallest-divisor n)
	(define (divides? a b) (= (remainder b a) 0))
	(define (next n)
		(if (= 2 n) 3 (+ 2 n)))
	(define (find-divisor n test)
		(cond ((> (* test test) n) n)
		      ((divides? test n) test)
		      (else (find-divisor n (next test)))))
	(find-divisor n 2))
(define (prime? n) (= n (smallest-divisor n)))

;;; prints three smallest primes larger than 'n'
(define (search-for-primes n)
	(define (search-n n)
		(if (prime? n)
			n
			(search-n (+ n 2))))
	;;; set n to be the closest odd number
	;;; i.e 1000->1001, 555->555
	(set! n (+ n 1 (- (remainder n 2))))
	(set! n (search-n n))       (print n)
	(set! n (search-n (+ n 2))) (print n)
	(set! n (search-n (+ n 2))) (print n))

#|
(define nontrivial-root #f)
(define (square n) (* n n))
(define (expmod base exp m)
	(cond ((= exp 0) 1)
	      ((even? exp) ( let
		((sq (remainder (expmod base (/ exp 2))) m))
		(set! nontrivial-root (and (= (remainder (square sq) m) 1) (> sq 1) (< sq (- m 1))))
		 (remainder (square sq))))
	      (else
		(set! nontrivial-root #f)
		(remainder (* base (expmod base (- exp 1) m)) m))))

(define (fast-prime? n times)
	(define (fermat-test n)
		(define (try-it a)
			(= (expmod a (- n 1) n) 1))
		(and (try-it (+ 1 (random (- n 1)))) (not nontrivial-root)))
	(cond ((= times 0) #t)
	      ((fermat-test n) (fast-prime? n (- times 1)))
	      (else #f)))

(define (full-fermat-test n)
	(define (fermat-test k)
		(and (= (expmod k n n) k) (not nontrivial-root)))
	(define (iter k)
		(cond ((= k 0) #t)
		      ((fermat-test k) (iter (- k 1)))
		      (else #f)))
	(iter (- n 1)))
|#


