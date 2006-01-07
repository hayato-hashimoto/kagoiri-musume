;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: parts.scm,v 1.8 2006/01/07 08:05:15 cut-sea Exp $
(use srfi-13)  ;; for string-scan

(define *head*
  `(head
    (title ?_) (meta ?@) (link ?@) (script ?@)))

(define *header*
  '(div ?@
        (h1 ?@ ?_)
        (a ?@ "システム管理")
        (a ?@ "ユニット一覧")
        (a ?@ "Login")))

(define *footer*
  '(div (@ (id "bottom-pane"))
        (p ?_)))

(define (*header-logedin* user)
  `(div ?@
        (h1 ?@ ?_)
        (a ?@ "システム管理")
        (a ?@ "ユニット一覧")
        (a ?@ "パスワード変更")
        (span " Now login:" (a ?@ ,user))
        (a (@ (href ?&) ?*) "Logout")
        (form ?@ "検索:" (input ?@))))

(define-syntax *make-body*
  (syntax-rules ()
    ((_ b1 ...)
     `(div (@ (id "body"))
           b1 ...))))


;; check 'http header' and save 'continuation session id' to worker.
;;
;; (test* "kagoiri-musume add new normal fan"
;;        (header '((!contain ("Status" "302 Moved")
;;                            ("Location" ?&))))
;;        (call-worker/gsid
;;         w
;;         '()
;;         '(("login-name" "shibata") ("passwd" "sh1b4t4"))
;;         header->sxml)
;;        (make-match&pick w))


;; '((!contain ("Status" "302 Moved") ("Location" ?&)))
;; =>  '(header (!contain (Status "302 Moved") (Location ?&)))
(define (header headers)
  (define (iter item)
    (cond ((not (pair? item))
           item)
          ((string? (car item))
           (cons (string->symbol (car item))
                 (map iter (cdr item))))
          (else
           (map iter item))))
  `(header ,@(iter headers)))

;; '(("Status" "302 Moved") ("Location" "http://localho.."))
;; => '(header (Status "302 Moved") (Location "http://localho.."))
(define (header->sxml h b)
  (define (url-fragment-cutoff pair)
    (cond ((and (eq? (car pair) 'Location)
	     (string-scan (cadr pair) #\# 'before))
	   => (lambda (url)
		(list (car pair) url)))
	  (else pair)))
    (cons 'header
        (map (lambda (item)
               (url-fragment-cutoff
		(cons (string->symbol (car item))
		      (cdr item))))
             h)))

(define (test/send&pick label w send-data)
  (test* label
         (header '((!contain ("Status" "302 Moved")
                             ("Location" ?&))))
	(call-worker/gsid
	 w
	 '()
         send-data
         header->sxml)
        (make-match&pick w)))
