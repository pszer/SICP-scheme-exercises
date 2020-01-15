; 2.3.4

(define (make-leaf symbol weight) (list 'leaf symbol weight))
(define (leaf? object) (eq? (car object) 'leaf))
(define (symbol-leaf x) (cadr x))
(define (weight-leaf x) (caddr x))

(define (make-code-tree left right)
	(list left
	      right
	      (append (symbols left) (symbols right))
	      (+ (weight left) (weight right))))

(define (left-branch  tree) (car tree ))
(define (right-branch tree) (cadr tree))
(define (symbols tree)
	(if (leaf? tree)
		(list (symbol-leaf tree))
		(caddr tree)))
(define (weight tree)
	(if (leaf? tree)
		(weight-leaf tree)
		(cadddr tree)))

(define (decode bits tree)
	(define (decode-1 bits current-branch)
		(if (null? bits)
			'()
			(let ((next-branch
			       (choose-branch (car bits) current-branch)))
				(if (leaf? next-branch)
					(cons (symbol-leaf next-branch)
					      (decode-1 (cdr bits) tree))
					(decode-1 (cdr bits) next-branch)))))
	(decode-1 bits tree))

(define (choose-branch bit branch)
	(cond ((= bit 0) (left-branch branch))
	      ((= bit 1) (right-branch branch))
		  (else (error "bad bit: CHOOSE BRANCH" bit))))

(define (adjoin-set x set)
	(cond ((null? set) (list x))
	      ((< (weight x) (weight (car set))) (cons x set))
		  (else (cons (car set)
		        (adjoin-set x (cdr set))))))

(define (is-element-of-set? x set)
	(cond ((null? set) #f)
	      ((eq? (symbols (car set)) x) #t)
		  (else (is-element-of-set? x (cdr set)))))

(define (make-leaf-set pairs)
	(if (null? pairs)
		'()
		(let ((pair (car pairs)))
			(adjoin-set (make-leaf (car pair)  ; symbol
			                       (cadr pair)) ; frequence
			            (make-leaf-set (cdr pairs))))))

(define (encode message tree)
	(if (null? message)
		'()
		(append (encode-symbol (car message) tree)
		        (encode (cdr message) tree))))

(define (encode-symbol symbol tree)
	(define (is-element? node)
		(if (leaf? node)
			(eq? symbol (symbol-leaf node))
			(is-element-of-set? symbol node)))
	(define encode-symbol-error (error "bad symbol: ENCODE-SYMBOL"))
	(define (enc-1 tree result)
		(cond ((null? tree) encode-symbol-error)
			  ((is-element? (symbols tree))
				(if (leaf? tree)
					result
					(if (is-element? (symbols (left-branch tree)))
						(enc-1 (left-branch tree)
						       (cons 0 result)
							   (cons 1 result)))))
			  (else encode-symbol-error)))
	(reverse (enc-1 tree '())))

(define sample-tree
	(make-code-tree
		(make-leaf 'A 4)
		(make-code-tree
		 (make-leaf 'B 2)
		 (make-code-tree
		  (make-leaf 'D 1)
		  (make-leaf 'C 1)))))
