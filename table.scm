;;; 

(define (make-table)
	(let ((local-table (list '*table*)))
		(define (get key)
			(assoc key (cdr local-table)))
		(define (lookup key)
			(let ((found (get key)))
				(if found
					(cdr found)
					#f)))
		(define (insert! key value)
			(let ((existing-pair (get key)))
				(if existing-pair
					(set-cdr! existing-pair ; overwrite
					          value)
					(set-cdr! local-table   ; make new entry
					          (cons (cons key value) (cdr local-table))))))
		(define (dispatch m)
			(case m
			      ((lookup)  lookup)
			      ((insert!) insert!)))
		dispatch))

(define (make-ordered-table)
	(let ((local-table (list '*ordered-table')))
		(define (make-entry key value left right)
			(cons (cons key value) (cons left right)))
		(define (make-leaf key value)
			(cons (cons key value) (cons '() '())))
		(define (key-entry entry)   (caar entry))
		(define (value-entry entry) (cdar entry))
		(define (left-entry entry)  (cadr entry))
		(define (right-entry entry) (cddr entry))
		(define (set-value-entry! entry val) (set-cdr! (car entry) val))
		(define (set-left-entry!  entry val) (set-car! (cdr entry) val))
		(define (set-right-entry! entry val) (set-cdr! (cdr entry) val))
		(define (get key)
			(define (search tree)
				(if (null? tree)
					#f
				    (let ((ent-val (value-entry tree))
					      (ent-key (key-entry tree)))
						(cond ((= key ent-key) tree)
						      ((< key ent-key)
								(search (left-entry tree)))
						      ((> key ent-key)
								(search (right-entry tree)))))))
			(search (cdr local-table)))
		(define (lookup key)
			(let ((found (get key)))
				(if found
					(value-entry found)
					#f)))
		(define (insert! key value)
			(define (iter tree)
				(let ((ent-key (key-entry tree)))
					(cond ((= key ent-key)
					        (set-value-entry! tree value)) ; overwrite
					      ((< key ent-key)
					        (let ((left-branch (left-entry tree)))
					          (if (null? left-branch)
						          (set-left-entry! tree (make-leaf key value))
					              (iter left-branch))))
					      ((> key ent-key)
					        (let ((right-branch (right-entry tree)))
					          (if (null? right-branch)
						          (set-right-entry! tree (make-leaf key value))
					              (iter right-branch)))))))
			(if (null? (cdr local-table))
				(set-cdr! local-table (make-leaf key value))
				(iter (cdr local-table))))
		(define (dispatch m)
			(case m
			      ((lookup)  lookup)
			      ((insert!) insert!)))
		dispatch))

(define (lookup-table table key) ((table 'lookup) key))
(define (insert-table! table key value) ((table 'insert!) key value))