;;; text compressor
;;;
;;; (compress string) -> pair (dictionary , word indices list)
;;; (decompress data) -> string

(define (make-table)
	(list 'table))
(define (assoc table key)
	(define (iter rest)
		(cond ((null? rest) #f)
		      ((equal? (caar rest) key) (car rest))
		      (else (iter (cdr rest)))))
	(iter (cdr table)))
(define (find-value table val)
	(define (iter rest)
		(cond ((null? rest) #f)
		      ((equal? (cdar rest) val) (car rest))
		      (else (iter (cdr rest)))))
	(iter (cdr table)))
(define (lookup table key)
	(let ((found (assoc table key)))
		(if found
			(value found)
			#f)))
(define (make-entry key val)
	(cons key val))
(define (key entry)
	(car entry))
(define (value entry)
	(cdr entry))
(define (set-value! entry value)
	(set-cdr! entry value))
(define (insert-table! table entry)
	(let ((entry-key (key entry))
	      (entry-value (value entry)))
		(let ((found (assoc table entry-key)))
		(if (not found)
			(set-cdr! table (cons entry (cdr table)))
		    (set-value! found entry-value)))))

;;; returns table dictionary / index pairs
(define (compress str)
	(let ((dict (make-table)))
		(define (iter strings count result)
			(if (null? strings)
				(reverse result)
				(let ((found (find-value dict (car strings))))
					(cond ((not found)
						(insert-table! dict (make-entry count (car strings)))
						(iter (cdr strings) (+ count 1) (cons count result)))
					      (else (iter (cdr strings) count (cons (key found) result)))))))
		(cons dict (iter (split str) 0 '()))))

(define (decompress data)
	(let ((dict (car data))
	      (strs (cdr data)))
		(define (iter rest result)
			(if (null? rest)
				result
				(iter (cdr rest)
				      (string-append result
				                     (lookup dict (car rest))
				                     (if (null? (cdr rest)) "" " ")))))
	(iter strs "")))

;;; splits string into list (delimited by SPACE)
(define (split str)
	(let ((len (string-length str)))
	(define (iter pos last-pos result)
		(cond ((= pos len)
		        (cons (substring str last-pos len) result))
		      ((equal? #\space (string-ref str pos))
		        (iter (+ pos 1)
		              (+ pos 1) 
		              (cons (substring str last-pos pos) result)))
		      (else (iter (+ pos 1) last-pos result))))
	(reverse (iter 0 0 '()))))
