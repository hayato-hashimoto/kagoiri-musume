;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: system-admin.scm,v 1.26 2006/12/13 01:21:03 cut-sea Exp $

(load "common.scm")

(test-start "kagoiri-musume admin-system check")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (login w :top '?&login)

 (set-gsid w 'login)

 (call-worker-test* "一般ユーザでは「システム管理」ボタンを表示しない"

                    :node '(*TOP*
                            (!exclude
                             "システム管理"))

                    :body '(("name" "cut-sea") ("pass" "cutsea"))
                    :sxpath (//header-action '(// a *text*)))

 (call-worker-test* "accept system administrator login to admin-system page & check"

                    :node '(*TOP*
                            (!contain
                             "システム管理"
                             "kago"))

                    :body '(("name" "kago") ("pass" "kago"))
                    :sxpath (//header-action '(// a *text*)))

 (call-worker-test* "システム管理ページへ移動"

                    :node '(*TOP*
                            (!contain
                             (a (@ (href ?&admin-system)
                                   ?*)
                                "システム管理")))

                    :body '(("name" "kago") ("pass" "kago"))
                    :sxpath (//header-action '(// a)))

 (set-gsid w 'admin-system)

 (test* "accept system administrator login to admin-system page & check user list table"
	'(*TOP*
	  (table
	   (thead "登録ユーザ一覧")
	   (!permute
	    (tr (th "管理者権限") (th "ログイン名") (th "メールアドレス") (th "開発") (th "顧客") (th "隠密"))
	    (tr (td "＊") (td "kago") (td "cut-sea@kagoiri.org") (td "＊") (td "＊") (td))
	    (tr (td) (td "cut-sea") (td "cut-sea@kagoiri.org") (td "＊") (td) (td))
	    (tr (td) (td "guest") (td) (td) (td) (td)))))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 1) (table 1)))
	test-sxml-match?)

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
				'()
				'(// (form 1) (table 2)))
	test-sxml-match?)

 (test* "accept system administrator login to admin-system page & save add-user entry point"
	'(*TOP*
	  (!contain
           (form (@ (action ?&add-user) ?*)
                 (table ?*)
                 (table ?*))))
        (call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 1)))
	(make-match&pick w))

 (set-gsid w 'admin-system)

 (test* "accept system administrator login to admin-system page & check unit list table"
	'(*TOP*
	  (table (thead "登録ユニット一覧") (tr (th "ユニット名") (th "概要") (th "活動状態"))))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 2) (table 1)))
	test-sxml-match?)


 (test* "accept system administrator login to admin-system page & check priority list table"
	'(*TOP*
	  (table
	   (thead "登録優先度一覧")
	   (!permute
	    (tr (th "優先度ID") (th "表示名") (th "レベル") (th "無効"))
	    (tr (td "normal") (td "普通") (td "3") (td))
	    (tr (td "low") (td "低") (td "2") (td))
	    (tr (td "high") (td "高") (td "4") (td))
	    (tr (td "super") (td "超高") (td "5") (td)))))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 3) (table 1)))
	test-sxml-match?)

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
				'()
				'(// (form 3) (table 2)))
	test-sxml-match?)

 (test* "accept system administrator login to admin-system page & save add-priority entry point"
	'(*TOP*
	  (form (@ (action ?&add-priority) ?*)
		(table ?*)
		(table ?*)))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 3)))
	(make-match&pick w))

 (set-gsid w 'admin-system)

 (test* "accept system administrator login to admin-system page & check status list table"
	'(*TOP*
	  (table
	   (thead "登録ステータス一覧")
	   (!permute
	    (tr (th "ステータスID") (th "表示名") (th "無効"))
	    (tr (td "open") (td "OPEN") (td))
	    (tr (td "completed") (td "COMPLETED") (td))
	    (tr (td "on-hold") (td "ON HOLD") (td))
	    (tr (td "taken") (td "TAKEN") (td))
	    (tr (td "rejected") (td "REJECTED") (td)))))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 4) (table 1)))
	test-sxml-match?)

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
				'()
				'(// (form 4) (table 2)))
	test-sxml-match?)


 (test* "accept system administrator login to admin-system page & save add-status entry point"
	'(*TOP*
	  (form (@ (action ?&add-status) ?*)
		(table ?*)
		(table ?*)))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 4)))
	(make-match&pick w))

 (set-gsid w 'admin-system)

 (test* "accept system administrator login to admin-system page & check type list table"
	'(*TOP*
	  (table
	   (thead "登録タイプ一覧")
	   (!permute
	    (tr (th "タイプID") (th "表示名") (th "無効"))
	    (tr (td "bug") (td "バグ") (td))
	    (tr (td "task") (td "タスク") (td))
	    (tr (td "request") (td "変更要望") (td))
	    (tr (td "discuss") (td "議論") (td))
	    (tr (td "report") (td "報告") (td))
	    (tr (td "term") (td "用語") (td))
	    (tr (td "etc") (td "その他") (td)))))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 5) (table 1)))
	test-sxml-match?)

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
				'()
				'(// (form 5) (table 2)))
	test-sxml-match?)

 (test* "accept system administrator login to admin-system page & save add-type entry point"
	'(*TOP*
	  (form (@ (action ?&add-type) ?*)
		(table ?*)
		(table ?*)))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 5)))
	(make-match&pick w))

 (set-gsid w 'admin-system)

 (test* "accept system administrator login to admin-system page & check category list table"
	'(*TOP*
	  (table
	   (thead "登録カテゴリ一覧")
	   (!permute
	    (tr (th "カテゴリID") (th "表示名") (th "無効"))
	    (tr (td "section") (td "セクション") (td))
	    (tr (td "global") (td "全体") (td))
	    (tr (td "infra") (td "インフラ") (td))
	    (tr (td "master") (td "マスタ") (td)))))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 6) (table 1)))
	test-sxml-match?)

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
				'()
				'(// (form 6) (table 2)))
	test-sxml-match?)

 (test* "accept system administrator login to admin-system page & save add-category entry point"
	'(*TOP*
	  (form (@ (action ?&add-category) ?*)
		(table ?*)
		(table ?*)))
	(call-worker/gsid->sxml w 
				'()
				'()
				'(// (form 6)))
	(make-match&pick w))

 (set-gsid w 'admin-system)

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

 (set-gsid w 'add-user)

 (test/send&pick "add new normal fan"
		 w
		 '(("login-name" "shibata")
                   ("passwd" "sh1b4t4")
                   ("mail-address" "shibata@kagoiri-musume.org")))

 (test* "confirm to added new fan"
	'(*TOP*
	  ?*
	  (tr (td) (td "shibata") (td "shibata@kagoiri-musume.org") (td) (td) (td))
	  ?*)
	(call-worker/gsid->sxml w '() '() '(// (form 1) (table 1) tr))
	test-sxml-match?)

 (set-gsid w 'add-user)

 (test/send&pick "change normal fan to admin role and hide him"
                 w
                 '(("admin" "on")
                   ("login-name" "shibata")
                   ("passwd" "")
                   ("mail-address" "shibata@kagoiri.org")
                   ("delete" "on")))

 (test* "confirm to change normal to admin and hide"
	'(*TOP*
	  ?*
	  (tr (td "＊") (td "shibata") (td "shibata@kagoiri.org") (td) (td) (td "＊"))
	  ?*)
	(call-worker/gsid->sxml w '() '() '(// (form 1) (table 1) tr))
	test-sxml-match?)

 (set-gsid w 'add-user)

 (test/send&pick "change admin fan to normal and hide him"
                 w
                 '(("admin" "off")
                   ("login-name" "shibata")
                   ("passwd" "")
                   ("mail-address" "")
                   ("delete" "on")))

 (test* "confirm to change admin to normal and hide keep"
	'(*TOP*
	  ?*
	  (tr (td) (td "shibata") (td "shibata@kagoiri.org") (td) (td) (td "＊"))
	  ?*)
	(call-worker/gsid->sxml w '() '() '(// (form 1) (table 1) tr))
	test-sxml-match?)

 (set-gsid w 'add-user)

 (test/send&pick "add fan role develop and client without input passwd and mail-address"
                 w
                 '(("admin" "off")
                   ("login-name" "shibata")
                   ("passwd" "")
                   ("mail-address" "")
		   ("devel" "on")
		   ("client" "on")
                   ("delete" "off")))

 (test* "confirm to develop and client roles without input passwd and mail-address"
	'(*TOP*
	  ?*
	  (tr (td) (td "shibata") (td "shibata@kagoiri.org") (td "＊") (td "＊") (td))
	  ?*)
	(call-worker/gsid->sxml w '() '() '(// (form 1) (table 1) tr))
	test-sxml-match?)

 (set-gsid w 'add-priority)

 (test/send&pick "add new priority item"
                 w
                 '(("id" "test")
                   ("disp" "テストレベル")
                   ("level" "3")
                   ("delete" "off")))

 (test* "confirm to added new priority item"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テストレベル") (td "3") (td))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 3) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-priority)

 (test/send&pick "change test priority's name and level and delete it"
                 w
                 '(("id" "test")
                   ("disp" "テスト")
                   ("level" "4")
                   ("delete" "on")))

 (test* "confirm to priority item's name level and delete"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テスト") (td "4") (td "＊"))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 3) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-priority)

 (test/send&pick "change test priority's name and level without input name"
                 w
                 '(("id" "test")
                   ("disp" "")
                   ("level" "2")
                   ("delete" "off")))

 (test* "confirm to priority item's name level and delete"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テスト") (td "2") (td))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 3) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-status)

 (test/send&pick "add new status item"
                 w
                 '(("id" "test")
                   ("disp" "テストステータス")
                   ("delete" "off")))

 (test* "confirm to added new status item"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テストステータス") (td))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 4) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-status)

 (test/send&pick "change test status's name and delete it"
                 w
                 '(("id" "test")
                   ("disp" "テスト")
                   ("delete" "on")))

 (test* "confirm to status item's name and delete"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テスト") (td "＊"))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 4) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-status)

 (test/send&pick "change test status's delete without input name"
                 w
                 '(("id" "test")
                   ("disp" "")
                   ("delete" "off")))

 (test* "confirm to status item's name and delete without input name"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テスト") (td))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 4) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-type)

 (test/send&pick "add new type item"
                 w
                 '(("id" "test")
                   ("disp" "テストタイプ")
                   ("delete" "off")))

 (test* "confirm to added new type item"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テストタイプ") (td))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 5) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-type)

 (test/send&pick "change test type's name and delete"
                 w
                 '(("id" "test")
                   ("disp" "テスト")
                   ("delete" "on")))

 (test* "confirm to type item's name and delete"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テスト") (td "＊"))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 5) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-type)

 (test/send&pick "change test type's delete without input name"
                 w
                 '(("id" "test")
                   ("disp" "")
                   ("delete" "off")))

 (test* "confirm to type item's name and delete without input name"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テスト") (td))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 5) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-category)

 (test/send&pick "add new category item"
                 w
                 '(("id" "test")
                   ("disp" "テストカテゴリ")
                   ("delete" "off")))

 (test* "confirm to added new category"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テストカテゴリ") (td))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 6) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-category)

 (test/send&pick "change test category's name and delete"
                 w
                 '(("id" "test")
                   ("disp" "テスト")
                   ("delete" "on")))

 (test* "confirm to category item's name and delete"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テスト") (td "＊"))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 6) (table 1) tr))
        test-sxml-match?)

 (set-gsid w 'add-category)

 (test/send&pick "change test category's delete without input name"
                 w
                 '(("id" "test")
                   ("disp" "")
                   ("delete" "off")))

 (test* "confirm to category item's name and delete without input name"
	'(*TOP*
	  ?*
	  (tr (td "test") (td "テスト") (td))
	  ?*)
        (call-worker/gsid->sxml w '() '() '(// (form 6) (table 1) tr))
        test-sxml-match?)

 )

(test-end)