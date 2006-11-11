;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: csv.scm,v 1.2 2006/11/11 11:19:31 cut-sea Exp $

(use text.csv)
(use gauche.charconv)

(define-plugin "csv"
  (version "0.1")
  (export csv->list)
  (depend #f))

(define (csv->list csv-file)
  (call-with-input-file csv-file
    (cut port->list (make-csv-reader #\,) <>)
    :encoding '*jp))