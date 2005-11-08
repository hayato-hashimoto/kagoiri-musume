;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: parts.scm,v 1.5 2005/11/08 12:35:37 cut-sea Exp $

(define *head*
  `(head
    (title ?_) (meta ?@) (link ?@) (script ?@)))

(define *header*
  '(div ?@
        (h1 ?@ ?_)
        (a ?@ "トップ")
        (a ?@ "システム管理")
        (a ?@ "ユニット一覧")
        (a ?@ "Login")))

(define *footer*
  '(div (@ (id "bottom-pane"))
        (p ?_)))

(define (*header-logedin* user)
  `(div ?@
        (h1 ?@ ?_)
        (a ?@ "トップ")
        (a ?@ "システム管理")
        (a ?@ "ユニット一覧")
        (a ?@ "パスワード変更")
        (span " Now login:" (a ?@ ,user))
        (a (@ (href ?&)) "Logout")
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
  (cons 'header
        (map (lambda (item)
               (cons (string->symbol (car item)) (cdr item)))
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
