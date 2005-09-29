(with-module kahua.server
;;===========================================================
;; CSS tree interpreter - for generates CSS
;;
;; (define-entry (test.css)
;;   `((css
;;      (:class status-completed
;;       (background-color "rgb(231,231,231)"))
;;
;;      (:class status-open
;;       (background-color "rgb(255, 225, 225)")))))
;;
;; (head/ (link/ (@/ (rel "stylesheet") (type "text/css")
;; 		     (href (kahua-static-document-url
;; 			    "kagoiri-musume/kagoiri-musume.css")))))

(define (format-selector selector keyword name)
  (list selector
        (if (eq? :id keyword) "#" ".")
        name))

(define (format-style style)
  (receive (selector declarations)
      (let loop ((style style)
                 (selector '("")))
        (if (null? style)
            (values selector style)
          (let1 item (car style)
            (cond ((pair? item)
                   (values selector style))
                  ((keyword? item)
                   (loop (cddr style)
                         (cons
                          (format-selector (car selector)
                                           item
                                           (cadr style))
                          (cdr selector))))
                  (else
                   (loop (cdr style)
                         (cons item selector)))))))
    (list (intersperse " " (reverse selector))
          "{\n"
          (format-declarations declarations)
          "}\n\n")))

(define (format-declarations decs)
  (map (lambda (dec)
         (list (car dec) ":" (intersperse " " (cdr dec))";\n"))
       decs))

(define (interp-css nodes context cont)
  (let1 headers (assoc-ref-car context "extra-headers" '())
    (cont
     (map (lambda (style)
            (format-style style))
          (cdr nodes))
     (if (assoc "content-type" headers)
         context
       (cons `("extra-headers"
               ,(kahua-merge-headers
                 headers '(("Content-Type" "text/css"))))
             context)))))

(add-interp! 'css interp-css))
