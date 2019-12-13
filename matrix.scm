(load "seq-ops.scm")

;;; vector is a list of numbers
;;; matrix is a list of equal length lists
;;;
;;;           | 1 2 3 4 |
;;;           | 4 5 6 6 |
;;;           | 6 7 8 9 |
;;;               is
;;; ((1 2 3 4) (4 5 6 6) (6 7 8 9))

(define (dot-product v w)
	(accumulate + 0 (map * v w)))

(define (matrix-*-vector m v)
	(map (lambda (r) (dot-product r v)) m))

(define (matrix-*-matrix m n)
	(let ((cols (transpose n)))
		(map (lambda (row) (matrix-*-vector cols row)) m)))

(define (transpose mat)
	(accumulate-n cons '() mat))
