(load "seq-ops.scm")

(define (queens board-size)
	(define empty-board '(()))
	(define (adjoin-position row col rest)
		(append rest (list (cons col row))))
	(define (safe? k pos)
		(let ((row (cdr (list-ref pos k))))
			(define (iter j)
				(if (= j k)
					#t
					(let ((row2 (cdr (list-ref pos j))))
					 (if (or (= row2 row) (= (abs (- row2 row)) (- k j)))
					     #f
					     (iter (+ j 1))))))
			(iter 1)))
	(define (queen-cols k)
		(if (= k 0)
			(list empty-board)
			(filter
				(lambda (positions) (safe? k positions))
				(flatmap
					(lambda (rest-of-queens)
						(map (lambda (new-row)
						       (adjoin-position
							   new-row k rest-of-queens))
						     (enumerate-interval 1 board-size)))
				    (queen-cols (- k 1))))))
	(map cdr (queen-cols board-size)))

(define (display-solution size pos)
	(define (disp x y)
		(cond ((> x size)
		       (begin (newline) (disp 1 (+ y 1))))
			  ((<= y size)
		       (begin
			        (if (null? (filter
			                   (lambda (p) (and (= (car p) x) (= (cdr p) y)))
			                   pos))
					(display ".")
					(display "@"))
			    (disp (+ x 1) y)))))
	(newline)
	(disp 1 1)
	(for-each (lambda (x) (display "-")) (enumerate-interval 1 size)))
