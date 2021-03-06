(define (calc-deriv exp var point)
	(define (substitute l)
		(cond
			((eq? var l) point)
			((pair? l) (cons (substitute (car l)) (substitute (cdr l))))
			(else l)))
	(let ((d (substitute (deriv exp var))))
		(display d)
		(eval d user-initial-environment)))

(define (deriv exp var)
	(define (variable? x) (symbol? x))
	(define (same-variable? v1 v2)
		(and (variable? v1) (variable? v2) (eq? v1 v2)))

	(define (=number? exp num) (and (number? exp) (= exp num)))
	(define (make-sum     a1 a2)
		(cond
			((=number? a1 0) a2)
			((=number? a2 0) a1)
			((and (number? a1) (number? a2))
				(+ a1 a2))
			(else (list '+ a1 a2))))
	(define (make-product m1 m2)
		(cond
			((or (=number? m1 0) (=number? m2 0)) 0)
			((=number? m1 1) m2)
			((=number? m2 1) m1)
			((and (number? m1) (number? m2))
				(* m1 m2))
			(else (list '* m1 m2))))
	(define (make-exponent b e)
		(cond
			((=number? e 1) b)
			((=number? e 0) 1)
			((=number? b 0) 0)
			((=number? b 1) 1)
			(else (list 'expt b e))))

	(define (sum?      x) (and (pair? x) (eq? (car x) '+)))
	(define (product?  x) (and (pair? x) (eq? (car x) '*)))
	(define (exponent? x) (and (pair? x) (eq? (car x) 'expt)))

	(define (addend s) (cadr  s))
	(define (augend s)
		(let ((rest (cddr s)))
			(if (null? (cdr rest))
				(car rest)
				(cons '+ rest))))

	(define (multiplier   p) (cadr  p))
	(define (multiplicand p)
		(let ((rest (cddr p)))
			(if (null? (cdr rest))
				(car rest)
				(cons '* rest))))

	(define (exp-base  e) (cadr  e))
	(define (exp-power e) (caddr e))
	(cond
		((number? exp) 0)
		((variable? exp) (if (same-variable? exp var) 1 0))
		((sum? exp) (make-sum (deriv (addend exp) var)
		                      (deriv (augend exp) var)))
		((product? exp)
		 (make-sum
			(make-product (multiplier exp)
			              (deriv (multiplicand exp) var))
			(make-product (deriv (multiplier exp) var)
			              (multiplicand exp))))
		((exponent? exp)
			(make-product (exp-power exp)
			              (make-exponent (exp-base exp) (- (exp-power exp) 1))))
		(else
			(error "unknown expression type: DERIV" exp))))
