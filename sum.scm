#|(define (sum term a next b)
	(define (sum-iter total r)
		(if (> r b)
		   total
		   (sum-iter (+ total (term r)) (next r))))
	(sum-iter 0 a))

(define (prod term a next b)
	(define (prod-iter total r)
		(if (> r b)
		   total
		   (prod-iter (* total (term r)) (next r))))
	(if (> a b)
		0
		(prod-iter 1 a)))
|#


(define (filtered-accumulate combiner null-value filter term a next b)
	(define (iter total r)
		(cond ((> r b) total)
		      ((filter r) (iter (combiner total (term r)) (next r)))
		      (else (iter total (next r)))))
	(iter null-value a))

#|(define (accumulate combiner null-value term a next b)
	(define (iter total r)
		(if (> r b)
		     total
		     (iter (combiner total (term r)) (next r))))
	(iter null-value a))|#

(define (accumulate combiner null-value term a next b)
	(filtered-accumulate combiner null-value (lambda (x) #t) term a next b ))

(define (sum term a next b)
	(accumulate + 0 term a next b))
(define (prod term a next b)
	(accumulate * 1 term a next b))

(define (factorial n)
	(define (inc n) (+ n 1))
	(if (= n 0)
		1
		(prod identity 1 inc n)))

(define (integral f a b dx)
	(define (add-dx x) (+ x dx))
	(* (sum f (+ a (/ dx 2.0)) add-dx b) dx))

(define (simpson-integral f a b n)
	(let ((h (/ (- b a) n)))
	(define (term mult)
		(lambda (x) (* (f (+ a (* x h))) mult)))
	(define (inc2 n)
		(+ n 2))
	(* (+ (f a) (f b) (sum (term 4) 1 inc2 (- n 1)) (sum (term 2) 2 inc2 (- n 2)))
	   (/ h 3))))



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

(define (inc n) (+ n 1))

(define (prime-square-sum a b)
	(define (square n) (* n n))
	(filtered-accumulate + 0 prime? square a inc b))

(define (coprime-sum n)
	(define (coprime? r) (= 1 (gcd r n)))
	(filtered-accumulate + 0 coprime? identity 1 inc n))
