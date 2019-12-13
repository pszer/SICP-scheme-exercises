;(define (make-mobile left right)
;	(list left right))
;(define (make-branch length structure)
;	(list length structure))
;(define (left-branch  mobile)  (car  mobile))
;(define (right-branch mobile)  (cadr mobile))
;(define (branch-length    branch) (car  branch))
;(define (branch-structure branch) (cadr branch))

(define (make-mobile left right)
	(cons left right))
(define (make-branch length structure)
	(cons length structure))
(define (left-branch  mobile)  (car mobile))
(define (right-branch mobile)  (cdr mobile))
(define (branch-length    branch) (car  branch))
(define (branch-structure branch) (cdr branch))

(define (total-weight mobile)
	(if (not (pair? mobile))
		mobile
		(+ (total-weight (branch-structure (left-branch mobile )))
		   (total-weight (branch-structure (right-branch mobile))))))

(define (balanced? mobile)
	(if (not (pair? mobile))
		#t
		(let ((left-torque  (* (branch-length (left-branch mobile))
		                       (total-weight  (branch-structure
		                                      (left-branch mobile)))))
		      (right-torque (* (branch-length (right-branch mobile))
		                       (total-weight  (branch-structure
			                                  (right-branch mobile))))))
			(and (= left-torque right-torque)
			     (balanced? (branch-structure (left-branch  mobile)))
			     (balanced? (branch-structure (right-branch mobile)))))))

#|
(define mob (make-mobile
                (make-branch 10 100)
                (make-branch 20 (make-mobile
                                    (make-branch 5 25)
                                    (make-branch 5 25)))))|#

(define mob (make-mobile
                (make-branch 10 100)
                (make-branch 20 (make-mobile
                                    (make-branch 5 25)
                                    (make-branch 5 25)))))


