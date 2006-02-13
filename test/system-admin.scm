;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: system-admin.scm,v 1.2 2006/02/13 23:21:16 cut-sea Exp $

(use gauche.test)
(use gauche.collection)
(use file.util)
(use text.tree)
(use sxml.ssax)
(use sxml.sxpath)
(use kahua)
(use kahua.test.xml)
(use kahua.test.worker)

(load "common.scm")

(test-start "kagoiri-musume admin-system enter check")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (test* "first access & collect save points"
	'(*TOP*
	  (!permute
	   (a (@ (href ?&admin-system) ?*) ?_)
	   (a ?@ ?_)
	   (a ?@ ?_))
	  (form ?@
		(table
		 (tr ?*)
		 (tr ?*))
		(input ?@)))
        (call-worker/gsid->sxml w '() '() '(// (or@ form a)))
        (make-match&pick w))

 (test* "first access login name input textbox check"
	'(*TOP*
	  (tr (th ?_)
	      (td (input (@ (!permute (type "text")
				      (name "name"))
			    ?*)))))
        (call-worker/gsid->sxml w '() '() '(// form table (tr 1)))
        (make-match&pick w))

 (test* "first access login password input textbox check"
	'(*TOP*
	  (tr (th ?_)
	      (td (input (@ (!permute (type "password")
				      (name "pass"))
			    ?*)))))
        (call-worker/gsid->sxml w '() '() '(// form table (tr 2)))
        (make-match&pick w))

 (test* "first access login submit button check"
	'(*TOP* (input (@ (!permute (type "submit")
				    (name "submit"))
			  ?*)))
        (call-worker/gsid->sxml w '() '() '(// form input))
        (make-match&pick w))

 (set-gsid w "admin-system")

 (test* "click link to entry system admin link"
	'(*TOP*
	  (!repeat (a ?@ ?_))
	  (form (@ (action ?&login) ?*)
		(table ?*)
		(input ?@)))
	(call-worker/gsid->sxml w '() '() '(// (or@ form a)))
	(make-match&pick w))

 (set-gsid w "login")

 (test* "reject normal user login to admin-system page"
	'(*TOP* (h3 "システム管理者のアカウントが必要です"))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "cut-sea") ("pass" "cutsea"))
				'(// h3))
	(make-match&pick w))

 (set-gsid w "login")

 #;(test* "accept system administrator login to admin-system page"
	'()
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'())
	(make-match&pick w))

 )

(test-end)