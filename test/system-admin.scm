;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: system-admin.scm,v 1.11 2006/02/15 16:27:11 cut-sea Exp $

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
	  (a (@ (!permute (href ?&admin-system)
			  (class "clickable"))
		?*) "システム管理"))
        (call-worker/gsid->sxml w '() '() '(// (a 1)))
        (make-match&pick w))

 (test* "first access login name input textbox check"
	'(*TOP*
	  (tr (th ?_)
	      (td (input (@ (!permute (type "text")
				      (name "name"))
			    ?*)))))
        (call-worker/gsid->sxml w '() '() '(// form table (tr 1)))
        test-sxml-match?)

 (test* "first access login password input textbox check"
	'(*TOP*
	  (tr (th ?_)
	      (td (input (@ (!permute (type "password")
				      (name "pass"))
			    ?*)))))
        (call-worker/gsid->sxml w '() '() '(// form table (tr 2)))
        test-sxml-match?)

 (test* "first access login submit button check"
	'(*TOP* (input (@ (!permute (type "submit")
				    (name "submit"))
			  ?*)))
        (call-worker/gsid->sxml w '() '() '(// form input))
        test-sxml-match?)

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
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check (a 1)"
	'(*TOP*
	  (a ?@ "システム管理")
	  (a ?@ "kago"))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (a 1)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check (a 2)"
	'(*TOP*
	  (a ?@ "ユニット一覧"))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (a 2)))
	test-sxml-match?)

 (set-gsid w "login")
 
 (test* "accept system administrator login to admin-system page & check (a 3)"
	'(*TOP*
	  (a (@ (href ?&change-password) ?*) "パスワード変更"))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (a 3)))
	(make-match&pick w))

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check (a 4)"
	'(*TOP*
	  (a (@ (href ?&logout) ?*) "Logout"))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (a 4)))
	(make-match&pick w))

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check user list table"
	'(*TOP*
	  (table
	   (thead "登録ユーザ一覧")
	   (tr (th "管理者権限") (th "ログイン名") (th "メールアドレス") (th "開発") (th "顧客") (th "隠密"))
	   (tr (td) (td "cut-sea") (td "cut-sea@kagoiri.org") (td "＊") (td) (td))
	   (tr (td) (td "guest") (td) (td) (td) (td))
	   (tr (td "＊") (td "kago") (td "cut-sea@kagoiri.org") (td "＊") (td "＊") (td))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 1) (table 1)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check add user"
	'(*TOP*
	  (table
	   (tr (th "管理者権限") (th "ログイン名") (th "パスワード") (th "メールアドレス") (th "開発") (th "顧客") (th "隠密"))
	   (tr (td (input (@ (type "checkbox") (name "admin"))))
	       (td (input (@ (type "text") (name "login-name"))))
	       (td (input (@ (type "password") (name "passwd"))))
	       (td (input (@ (type "text") (name "mail-address"))))
	       (td (input (@ (type "checkbox") (name "devel"))))
	       (td (input (@ (type "checkbox") (name "client"))))
	       (td (input (@ (type "checkbox") (name "delete")))))
	   (tr (td (input (@ (value "ファン登録") (type "submit") (name "submit")))))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 1) (table 2)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & save add-user entry point"
	'(*TOP*
	  ?_ ;; search box
	  (form (@ (action ?&add-user) ?*)
		(table ?*)
		(table ?*)))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 1)))
	(make-match&pick w))


 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check unit list table"
	'(*TOP*
	  (table (thead "登録ユニット一覧") (tr (th "ユニット名") (th "概要") (th "活動状態"))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 2) (table 1)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check priority list table"
	'(*TOP*
	  (table
	   (thead "登録優先度一覧")
	   (tr (th "優先度ID") (th "表示名") (th "レベル") (th "無効"))
	   (tr (td "high") (td "高") (td "4") (td))
	   (tr (td "low") (td "低") (td "2") (td))
	   (tr (td "normal") (td "普通") (td "3") (td))
	   (tr (td "super") (td "超高") (td "5") (td))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 3) (table 1)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check add priority"
	'(*TOP*
	  (table
	   (tr (th "優先度ID") (th "表示名") (th "レベル") (th "無効"))
	   (tr (td (input (@ (type "text") (name "id"))))
	       (td (input (@ (type "text") (name "disp"))))
	       (td (select (@ (name "level"))
			   (option (@ (value "1")) "1")
			   (option (@ (value "2")) "2")
			   (option (@ (value "3")) "3")
			   (option (@ (value "4")) "4")
			   (option (@ (value "5")) "5")))
	       (td (input (@ (type "checkbox") (name "delete")))))
	   (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 3) (table 2)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & save add-priority entry point"
	'(*TOP*
	  (form (@ (action ?&add-priority) ?*)
		(table ?*)
		(table ?*)))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 3)))
	(make-match&pick w))

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check status list table"
	'(*TOP*
	  (table
	   (thead "登録ステータス一覧")
	   (tr (th "ステータスID") (th "表示名") (th "無効"))
	   (tr (td "completed") (td "COMPLETED") (td))
	   (tr (td "on-hold") (td "ON HOLD") (td))
	   (tr (td "open") (td "OPEN") (td))
	   (tr (td "rejected") (td "REJECTED") (td))
	   (tr (td "taken") (td "TAKEN") (td))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 4) (table 1)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check add status"
	'(*TOP*
	  (table
	   (tr (th "ステータスID") (th "表示名") (th "無効"))
	   (tr (td (input (@ (type "text") (name "id"))))
	       (td (input (@ (type "text") (name "disp"))))
	       (td (input (@ (type "checkbox") (name "delete")))))
	   (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 4) (table 2)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & save add-status entry point"
	'(*TOP*
	  (form (@ (action ?&add-status) ?*)
		(table ?*)
		(table ?*)))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 4)))
	(make-match&pick w))

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check type list table"
	'(*TOP*
	  (table
	   (thead "登録タイプ一覧")
	   (tr (th "タイプID") (th "表示名") (th "無効"))
	   (tr (td "bug") (td "バグ") (td))
	   (tr (td "discuss") (td "議論") (td))
	   (tr (td "etc") (td "その他") (td))
	   (tr (td "report") (td "報告") (td))
	   (tr (td "request") (td "変更要望") (td))
	   (tr (td "task") (td "タスク") (td))
	   (tr (td "term") (td "用語") (td))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 5) (table 1)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check add type"
	'(*TOP*
	  (table
	   (tr (th "タイプID") (th "表示名") (th "無効"))
	   (tr (td (input (@ (type "text") (name "id"))))
	       (td (input (@ (type "text") (name "disp"))))
	       (td (input (@ (type "checkbox") (name "delete")))))
	   (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 5) (table 2)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & save add-type entry point"
	'(*TOP*
	  (form (@ (action ?&add-type) ?*)
		(table ?*)
		(table ?*)))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 5)))
	(make-match&pick w))

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check category list table"
	'(*TOP*
	  (table
	   (thead "登録カテゴリ一覧")
	   (tr (th "カテゴリID") (th "表示名") (th "無効"))
	   (tr (td "global") (td "全体") (td))
	   (tr (td "infra") (td "インフラ") (td))
	   (tr (td "master") (td "マスタ") (td))
	   (tr (td "section") (td "セクション") (td))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 6) (table 1)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check add category"
	'(*TOP*
	  (table
	   (tr (th "カテゴリID") (th "表示名") (th "無効"))
	   (tr (td (input (@ (type "text") (name "id"))))
	       (td (input (@ (type "text") (name "disp"))))
	       (td (input (@ (type "checkbox") (name "delete")))))
	   (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 6) (table 2)))
	test-sxml-match?)

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & save add-category entry point"
	'(*TOP*
	  (form (@ (action ?&add-category) ?*)
		(table ?*)
		(table ?*)))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 6)))
	(make-match&pick w))

 (set-gsid w "login")

 (test* "accept system administrator login to admin-system page & check dead musumes list table"
	'(*TOP*
	  (table
	   (thead "不良娘。一覧")
	   (tr (th "元所属ユニット") (th "娘。No") (th "タイトル") (th "作成日") (th "活動状態"))))
	(call-worker/gsid->sxml w 
				'()
				'(("name" "kago") ("pass" "kago"))
				'(// (form 7) (table 1)))
	test-sxml-match?)

 (set-gsid w "change-password")

 #;(test* "accept system administrator login to admin-system page & check dead musumes list table"
	'()
	(call-worker/gsid->sxml w 
				'()
				'()
				'())
	test-sxml-match?)



 (set-gsid w "logout")

 (test/send&pick "logout" w ())

 (test* "redirect and login page"
	'(*TOP* (h3 "ユニット一覧は一般ユーザアカウントが必要です"))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// h3))
	test-sxml-match?)
 
 )

(test-end)