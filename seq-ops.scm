(define (filter predicate sequence)
	(define (iter result seq)
		(cond ((null? seq) result)
			  ((predicate (car seq))
				  (iter (cons (car seq) result) (cdr seq)))
			  (else (iter result (cdr seq)))))
	(reverse (iter '() sequence)))

(define (accumulate op init sequence)
	(if (null? sequence)
		init
		(op (car sequence) (accumulate op init (cdr sequence)))))

;(define fold-right accumulate)
;(define (fold-left op initial sequence)
;	(define (iter result rest)
;		(if (null? rest)
;			result
;			(iter (op result (car rest)) (cdr rest))))
;	(iter initial sequence))

;(define (right-reverse seq)
;	(fold-right (lambda (x y) (append y (list x))) '() seq))
;(define (left-reverse seq)
;	(fold-left (lambda (x y) (append (list y) x)) '() seq))

(define (accumulate-n op init seqs)
	(define (car-seqs s)
		(if (null? s) '()
			(cons (caar s) (car-seqs (cdr s)))))
	(define (cdr-seqs s)
		(if (null? s) '()
			(cons (cdar s) (cdr-seqs (cdr s)))))
	(if (null? (car seqs))
		'()
		(cons (accumulate   op init (car-seqs seqs))
		      (accumulate-n op init (cdr-seqs seqs)))))

(define (flatmap proc seq)
	(accumulate append '() (map proc seq)))

(define (unique-pairs n)
	(flatmap
		(lambda (i)
			(map (lambda (j) (list j i))
			     (enumerate-interval 1 (- i 1))))
	    (enumerate-interval 1 n)))

(define (unique-triples n)
	(flatmap
		(lambda (i)
			(map (lambda (j) (append (list j) i))
			     (enumerate-interval 1 (- (car i) 1))))
	    (unique-pairs n)))

(define (triple-sum n s)
	(define (triple-sum-is-s? trip)
		(= (+ (car trip) (cadr trip) (caddr trip)) s))
	(filter triple-sum-is-s? (unique-triples n)))

(load "prime.scm")
#|(define (prime-sum-pairs n)
	(define (prime-sum? pair)
		(prime? (+ (car pair) (cadr pair))))
	(define (make-pair-sum pair)
		(list (car pair) (cadr pair) (+ (car pair) (cadr pair))))
	(map make-pair-sum
		(filter prime-sum?
			(flatmap (lambda (i)
			              (map (lambda (j) (list i j))
			                    (enumerate-interval 1 (- i 1))))
		     (enumerate-interval 1 n)))))|#

(define (prime-sum-pairs n)
	(define (prime-sum? pair)
		(prime? (+ (car pair) (cadr pair))))
	(define (make-pair-sum pair)
		(list (car pair) (cadr pair) (+ (car pair) (cadr pair))))
	(map make-pair-sum
		(filter prime-sum? (unique-pairs n))))

(define (permutations s)
	(define (remove item set)
		(filter (lambda (x) (not (= x item))) set))
	(if (null? s) ; empty set?
		(list '())
		(flatmap (lambda (x)
		             (map (lambda (p) (cons x p))       ; add 'x' into permutations of 's-x'
		                  (permutations (remove x s))))
		          s)))

(define (enumerate-interval low high)
	(define (iter count result)
		(if (< count low)
			result
			(iter (- count 1) (cons count result))))
	(iter high '()))

(define (enumerate-tree tree)
	(cond ((null? tree) '())
	      ((not (pair? tree)) (list tree))
	      (else (append (enumerate-tree (car tree))
	                    (enumerate-tree (cdr tree))))))

(define (seq-map p sequence)
	(accumulate (lambda (x y) (cons (p x) y)) '() sequence))

(define (seq-append seq1 seq2)
	(accumulate cons seq2 seq1))

(define (seq-length sequence)
	(accumulate (lambda (x y) (+ y 1)) 0 sequence))

(define (horner-eval x coefficient-sequence)
	(accumulate
		(lambda (this-coeff higher-terms) (+ (* x higher-terms) this-coeff)) 0 coefficient-sequence))

(define (count-leaves t)
	(accumulate (lambda (x y) (+ y 1)) 0 (enumerate-tree t)))
