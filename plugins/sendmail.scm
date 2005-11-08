;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: sendmail.scm,v 1.2 2005/11/08 12:35:37 cut-sea Exp $

(use gauche.process)
(use gauche.charconv)

(define-plugin "sendmail"
  (version "0.1")
  (export sendmail)
  (depend #f))

(define-export (sendmail to from subject body)
  (call-with-output-process
   "/usr/sbin/sendmail -t -oi"
   (lambda (p)
     (display (format "To: ~a\n" to) p)
     (display (format "From: ~a\n" from) p)
     (display (format "Subject: ~a\n" subject) p)
     (display "Content-Transfer-Encoding: 7bit\n" p)
     (display "Content-Type: text/plain; charset=ISO-2022-JP\n" p)
     (display "\n\n" p)
     (display (ces-convert body "eucjp" "iso2022jp") p)
     )))
