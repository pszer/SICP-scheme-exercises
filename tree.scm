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


(define (entry tree) (car tree))
(define (left-branch tree) (cadr tree))
(define (left-branch tree) (caddr tree))
(define (make-tree entry left right)
	(list entry left right))

(define test-tree (make-tree 4
                             (make-tree 2
                                        (make-tree 1 '() '())
                                        (make-tree 3 '() '()))
                             (make-tree 6
                                        (make-tree 5 '() '())
                                        (make-tree 7 '() '()))))

;;; 2.63
(define (tree->list tree)
	(if (null? tree)
		'()
		(append (tree->list (left-branch tree))
		        (cons (entry tree)
		              (tree->list
		                   (right-branch tree))))))

(define (tree->list-2 tree)
	(define (copy-to-list tree result-list)
		(if (null? tree)
			result-list
			(copy-to-list (left-branch tree)
			              (cons (entry tree)
			                    (copy-to-list
			                       (right-branch tree)
			                       result-list)))))
	(copy-to-list tree '()))

;;; 2.64
; a) the n/2 th element is chosen as the center of the partial tree,
;    partial-tree then balances all the elements left of the center,
;    and then balances all the elements right of the center.
;
;   (list->tree (list 1 3 5 7 9 11))
;   becomes
;                 5
;               /   \
;              3     9
;             /    /   \
;            1    7    11
;
; b) O(n)

(define (list->tree elements)
  (car (partial-tree elements (length elements))))

(define (partial-tree elts n)
  (if (= n 0)
      (cons '() elts)
      (let ((left-size (quotient (- n 1) 2)))
        (let ((left-result (partial-tree elts left-size)))
          (let ((left-tree (car left-result))
                (non-left-elts (cdr left-result))
                (right-size (- n (+ left-size 1))))
            (let ((this-entry (car non-left-elts))
                  (right-result (partial-tree
                                  (cdr non-left-elts)
                                  right-size)))
              (let ((right-tree (car right-result))
                    (remaining-elts (cdr right-result)))
                (cons (make-tree
                        this-entry left-tree right-tree)
                      remaining-elts))))))))

;;; 2.66
; lookup for a binary tree database
(define (lookup given-key set-of-records)
	(if (null? set-of-records)
		#f
		(let ((median-key (key (car set-of-records))))
			(cond ((= given-key median-key) (car set-of-records))
			      ((< given-key median-key) (cadr set-of-records)) 
			      ((> given-key median-key) (caddr set-of-records))))))
