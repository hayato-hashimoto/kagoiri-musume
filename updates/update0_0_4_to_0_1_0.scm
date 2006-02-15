;; 0.0.4 -> 0.1.0
;;

(map (lambda (unit)
       (if (null? (slot-ref unit 'musumes))
	   (slot-set! unit 'musumes
		      (sort (filter (lambda (m) (eq? unit (unit-of m)))
				    (make-kahua-collection <musume>))
			    (lambda (m1 m2)
			      (> (mno-of m1) (mno-of m2)))))))
     (make-kahua-collection <unit>))

(map musumes-of (make-kahua-collection <unit>))

