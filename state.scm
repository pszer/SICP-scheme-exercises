(define (make-accumulator n)
	(let ((total n))
		(lambda (x)
			(begin (set! total (+ total x))
			       total))))

(define (make-monitored func)
	(let ((counter 0))
		(define (dispatch x)
			(if (eq? x 'how-many-calls?)
				counter
			    (begin (set! counter (+ counter 1))
				       (func x))))
		dispatch))

(define (call-the-cops x) "oooo lord they coming")

(define (make-account balance pass)
	(let ((bad-pass-count 0))
		(define (is-pass? s) (eq? s pass))
		(define (bad-pass x) "Bad password")
		(define (withdraw amount)
			(if (< balance amount)
				"Insufficient funds"
				(begin (set! balance (- balance amount))
					   balance)))
		(define (deposit amount)
			(set! balance (+ balance amount))
			balance)
		(define (dispatch given-pass m)
			(if (is-pass? given-pass)
				(begin
					(set! bad-pass-count 0)
					(cond ((eq? m 'test-pass) #t)
					      ((eq? m 'withdraw) withdraw)
						  ((eq? m 'deposit ) deposit)
						  (else (error "Unknown request: MAKE-ACCOUNT" m))))
				(if (= 6 bad-pass-count)
					call-the-cops
					(begin (set! bad-pass-count (+ 1 bad-pass-count))
					       bad-pass))))
		dispatch))

(define (make-joint acc pass joint-pass)
	(define (joint-acc p m)
		(if (eq? p joint-pass)
			(acc pass m)
			(error "bad password")))
	(if (eq? (acc pass 'test-pass) #t)
		joint-acc
		(error "bad password")))

(define peter-acc (make-account 1000000 'foo))
(define paul-acc (make-joint peter-acc 'foo 'wicked))
