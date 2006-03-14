(use kahua.elem)

(define-plugin "async"
  (version "0.1")
  (export a/cont/async: a/cont/async/
          form/cont/async: form/cont/async/
          js/
          js/sortable
          js/show
          js/hide
          )
  (depend #f))

(define (flatten ls)
  (define (iter acc ls)
    (if (null? ls) 
	(reverse acc)
	(let ((hd (car ls))
	      (tl  (cdr ls)))
	  (cond ((string? hd) (iter (cons hd acc) tl))
		((null? hd) (iter acc tl))
		((eq? 'node-set (car hd)) 
		 (iter (append (reverse (cdr hd)) acc) tl))
		(else (iter (cons hd acc) tl))))))
  (iter '() ls))

(define (a/cont/async: . arg) `(a/cont/async ,@(flatten arg)))
(define (form/cont/async: . arg) `(form/cont/async ,@(flatten arg)))
(define (a/cont/async/ . args)
  (update (cut cons `(a/cont/async ,@(exec '() (node-set args))) <>)))
(define (form/cont/async/ . args)
  (update (cut cons `(form/cont/async ,@(exec '() (node-set args))) <>)))


(define (js/ . body)
  (script/ (@/ (type "text/javascript"))
           "Event.observe(window, 'load', function() {"
           (node-set body)
           "});"))

(define (keywords->options keywords)
  (if (and (not (null? keywords))
           (even? (length keywords)))
      (list
       (format "{~a}"
              (string-join
               (let loop ((keywords keywords)
                          (options '()))
                 (if (null? keywords)
                     (reverse options)
                   (loop (cddr keywords)
                         (cons (format "~a: ~a"
                                       (car keywords)
                                       (x->js-object (cadr keywords)))
                               options)))) ", ")))
    '()))

(define (x->js-object x)
  (cond ((string? x) (format "'~a'" x))
        ((number? x) (number->string x))
        ((boolean? x) (if x "true" "false"))
        ((symbol? x) (symbol->string x))
        ((pair? x) (format "[~a]"
                           (string-join
                            (map x->js-object x)
                            ", ")))))

(define-syntax define-js
  (syntax-rules ()
    ((_ (name arg ...) js-name)
     (define (name arg ... . opt)
       (string-append
        js-name "("
        (string-join
         (list*
          (x->js-object arg) ...
          (keywords->options opt))
         ", "
         )
        ");")))))


(define-js (js/sortable elem)
  "Sortable.create")

(define-js (js/show elem)
  "Element.show")

(define-js (js/hide elem)
  "Element.hide")


#|
(a/cont/sync:
 (@@: (cont ¡Ä)
      (id "worker-table"))
 "Refresh")

->

<a href='¡Ä'
   onClick='; return async_get(event, "worker-table","¡Ä")'>
  Refresh
</a>
|#

(select-module kahua.server)
(define-element a/cont/async (attrs auxs contents context cont)

  (define (nodes path)
    (let ((async_id (car (assq-ref auxs 'id))))
      (cont `((a (@ ,@(cons `(href ,path)
                          (remove (lambda (x)
                                    (eq? 'href (car x))) attrs))
                  (onClick ,(format "~a; return async_get(event, ~s,~s);"
                                    (car (or (assq-ref auxs 'pre)
                                             '("")))
                                    async_id
                                    path)))
                 ,@contents)) context)))

  (cond ((assq-ref auxs 'cont) => (compose nodes (local-cont auxs))
         )
        ((assq-ref auxs 'remote-cont) => remote-cont)
        (else (nodes (kahua-self-uri (compose nodes (remote-cont auxs))
                                     )))))

(define-element form/cont/async (attrs auxs contents context cont)

  (define (build-argstr&hiddens cont-args)
    (receive (pargs kargs) (extract-cont-args cont-args 'form/cont)
      (cons
       (string-join (map uri-encode-string pargs) "/" 'prefix)
       (filter-map (lambda (karg)
                     (and (not (null? (cdr karg)))
                          `(input (@ (type "hidden") (name ,(car karg))
                                     (value ,(cdr karg))))))
                   kargs))))

  (let* ((clause (assq-ref auxs 'cont))
         (id     (if clause (session-cont-register (car clause)) ""))
         (argstr (if clause (build-argstr&hiddens (cdr clause)) '("")))
         (async_id (car (assq-ref auxs 'id)))
         )
    (cont
     `((form (@ ,@(append `((method "POST") 
                            (action ,(kahua-self-uri 
                                      (string-append id (car argstr)))))
                          (remove (lambda (x)
                                    (or (eq? 'method (car x))
                                        (eq? 'action (car x)))) attrs))
                (onsubmit ,(format "~a; return async_post(event, ~s);"
                                   (car (or (assq-ref auxs 'pre)
                                            '("")))
                                   async_id))
                ;; (onmouseover ,(format "highlight(~s)" async_id))
;;                 (onmouseout ,(format "unhighlight(~s)" async_id))
                )
             ,@(cdr argstr)
             ,@contents))
     context)))



