(define (tree-map proc tree)
	(map (lambda (sub-tree)
	        (if (pair? sub-tree)
	            (tree-map proc sub-tree)
	            (proc sub-tree)))
	tree))

(define (square-tree tree)
	(define (square n) (* n n))
	(tree-map square tree))

; 1. Subset of the empty set is just the empty set
;
; 2. Let 'S' be a set, and 'z' is an element of 'S'
;
; The union of the subsets of the set 'S-z' and
; the subsets of 'S-z' +'z' for each subset is
; the entire set of subsets of 'S'.
; So if you know all the subsets of 'S-z', you
; automatically know all the subets of 'S'.
;
; We know what the subsets of the empty set is,
; so we know what the subsets of a set with 1
; element is (A={1}, S(A-1) = {{}}). If we know
; the subsets of a set size 1, we know the subsets
; of a set size 2, we can repeat this process
; by induction to figure out the subsets of any
; sized set.
;
(define (subsets s)
	(if (null? s)
		(list '())
		(let ((rest (subsets (cdr s))))
			(append rest (map
		                 (lambda (set) (append (list (car s)) set))
		                 rest)))))
