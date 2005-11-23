;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: sendmail-with-headers.scm,v 1.2 2005/11/23 04:39:44 shibata Exp $

(use gauche.process)
(use gauche.charconv)
(use srfi-13)
(use rfc.base64)

(define-plugin "sendmail/headers"
  (version "0.1")
  (export sendmail/headers)
  (depend #f))

(define (encode-subject subject)
  (string-append
   "=?ISO-2022-JP?B?"
   (string-join
    (string-split
     (base64-encode-string
      (ces-convert subject "*JP" "iso2022jp")) #\newline) "")
   "?="))

(define (keyword->field key)
  (string-join
   (map string-titlecase
        (string-split (keyword->string key)
                      #\-)) "-"))

(define-export (sendmail/headers body . headers)
  (call-with-output-process
   "/usr/sbin/sendmail -t -oi"
   (lambda (p)

     (define (print-head field value)
       (when value
         (display (format "~a: ~a\n" field value) p)))

     (print-head "Subject"
                 (encode-subject (get-keyword :subject headers "no subject")))

     (let loop ((headers (delete-keyword :subject headers)))
       (when (<= 2 (length headers))
         (begin
           (print-head (keyword->field (car headers))
                       (cadr headers))
           (loop (cddr headers)))))
     (unless (get-keyword :content-transfer-encoding headers #f)
       (print-head "Content-Transfer-Encoding" "7bit"))
     (unless (get-keyword :content-type headers #f)
       (print-head "Content-Type" "text/plain; charset=ISO-2022-JP"))
     (display "\n\n" p)
     (display (ces-convert body "*JP" "iso2022jp") p))))



