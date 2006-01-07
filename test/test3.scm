;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: test3.scm,v 1.11 2006/01/07 08:05:15 cut-sea Exp $

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

(test-start "kagoiri-musume operate admin-system parameters")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (test* "kagoiri-musume top link click"
	`(html
          ,*head*
	  (body
           (div ?@
		(h1 ?@ ?_)
		(a (@ (href ?&) ?*) "システム管理")
		(a ?@ "ユニット一覧")
		(a ?@ "Login"))
           ,(*make-body*
             (h1 "籠入娘。へようこそ！")
             (h3 "ユニット一覧は一般ユーザアカウントが必要です")
             (form ?@
                   (table
                    (tr (th "Login Name") (td (input (@ (value "") (type "text") (name "name") (id "focus")))))
                    (tr (th "Password") (td (input (@ (value "") (type "password") (name "pass"))))))
                   (input (@ (value "login") (type "submit") (name "submit")))))
           ,*footer*))
        (call-worker/gsid w '() '() (lambda (h b) (tree->string b)))
        (make-match&pick w))

 (test* "kagoiri-musume system admin link click without login"
	`(html
	  ,*head*
	  (body
           ,*header*
           ,(*make-body*
             (h1 ?_)
             (h3 "システム管理者のアカウントが必要です")
             (form (@ (action ?&) ?*)
		 (table
		  (tr 
		   (th "Login Name")
		   (td (input (@ (!permute
				  (value "")
				  (type "text")
				  (name "name")
                                  (id "focus"))))))
		  (tr
		   (th "Password")
		   (td (input (@ (!permute
				  (value "") 
				  (type "password")
				  (name "pass")))))))
		 (input (@ (!permute
			    (value "login")
			    (type "submit")
			    (name "submit"))))))
           ,*footer*))
        (call-worker/gsid w '() '() (lambda (h b) (tree->string b)))
        (make-match&pick w))

 (test* "kagoiri-musume system admin link click with login"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録ユーザ一覧")
		 (tr (th "管理者権限") (th "ログイン名") (th "メールアドレス") (th "開発") (th "顧客") (th "隠密"))
		 (tr (td) (td "cut-sea") (td "cut-sea@kagoiri.org") (td "＊") (td) (td))
		 (tr (td) (td "guest") (td) (td) (td) (td))
		 (tr (td "＊") (td "kago") (td "cut-sea@kagoiri.org") (td "＊") (td "＊") (td)))
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
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '(("name" "kago") ("pass" "kago"))
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume add new normal fan"
                 w
                 '(("login-name" "shibata")
                   ("passwd" "sh1b4t4")
                   ("mail-address" "shibata@kagoiri-musume.org")))
 
 (test* "kagoiri-musume confirm to added new fan"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録ユーザ一覧")
		 (tr (th "管理者権限") (th "ログイン名") (th "メールアドレス") (th "開発") (th "顧客") (th "隠密"))
		 (tr (td) (td "cut-sea") (td "cut-sea@kagoiri.org") (td "＊") (td) (td))
		 (tr (td) (td "guest") (td) (td) (td) (td))
		 (tr (td "＊") (td "kago") (td "cut-sea@kagoiri.org") (td "＊") (td "＊") (td))
		 (tr (td) (td "shibata") (td "shibata@kagoiri-musume.org") (td) (td) (td)))
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
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume change normal fan to admin role and hide him"
                 w
                 '(("admin" "on")
                   ("login-name" "shibata")
                   ("passwd" "")
                   ("mail-address" "shibata@kagoiri.org")
                   ("delete" "on")))

 (test* "kagoiri-musume confirm to change user account"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録ユーザ一覧")
		 (tr (th "管理者権限") (th "ログイン名") (th "メールアドレス") (th "開発") (th "顧客") (th "隠密"))
		 (tr (td) (td "cut-sea") (td "cut-sea@kagoiri.org") (td "＊") (td) (td))
		 (tr (td) (td "guest") (td) (td) (td) (td))
		 (tr (td "＊") (td "kago") (td "cut-sea@kagoiri.org") (td "＊") (td "＊") (td))
		 (tr (td "＊") (td "shibata") (td "shibata@kagoiri.org") (td) (td) (td "＊")))
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
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume change admin fan to normal and hide him"
                 w
                 '(("admin" "off")
                   ("login-name" "shibata")
                   ("passwd" "")
                   ("mail-address" "")
                   ("delete" "on")))
 
 (test* "kagoiri-musume confirm to change user account"
	'(*TOP*
	  ?*
	  (form ?@
		(table
		 (thead "登録ユーザ一覧")
		 (tr (th "管理者権限") (th "ログイン名") (th "メールアドレス") (th "開発") (th "顧客") (th "隠密"))
		 (tr (td) (td "cut-sea") (td "cut-sea@kagoiri.org") (td "＊") (td) (td))
		 (tr (td) (td "guest") (td) (td) (td) (td))
		 (tr (td "＊") (td "kago") (td "cut-sea@kagoiri.org") (td "＊") (td "＊") (td))
		 (tr (td) (td "shibata") (td "shibata@kagoiri.org") (td) (td) (td "＊")))
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
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録優先度一覧")
		 (tr (th "優先度ID") (th "表示名") (th "レベル") (th "無効"))
		 (tr (td "high") (td "高") (td "4") (td))
		 (tr (td "low") (td "低") (td "2") (td))
		 (tr (td "normal") (td "普通") (td "3") (td))
		 (tr (td "super") (td "超高") (td "5") (td)))
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
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume add new precedence item"
                 w
                 '(("id" "test")
                   ("disp" "テストレベル")
                   ("level" "3")
                   ("delete" "off")))

 (test* "kagoiri-musume confirm to added precedence item"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録優先度一覧")
		 (tr (th "優先度ID") (th "表示名") (th "レベル") (th "無効"))
		 (tr (td "high") (td "高") (td "4") (td))
		 (tr (td "low") (td "低") (td "2") (td))
		 (tr (td "normal") (td "普通") (td "3") (td))
		 (tr (td "super") (td "超高") (td "5") (td))
		 (tr (td "test") (td "テストレベル") (td "3") (td)))
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
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume change normal fan to admin role and hide him"
                 w
                 '(("id" "test")
                   ("disp" "テスト")
                   ("level" "4")
                   ("delete" "on")))

 (test* "kagoiri-musume confirm to added precedence item"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録優先度一覧")
		 (tr (th "優先度ID") (th "表示名") (th "レベル") (th "無効"))
		 (tr (td "high") (td "高") (td "4") (td))
		 (tr (td "low") (td "低") (td "2") (td))
		 (tr (td "normal") (td "普通") (td "3") (td))
		 (tr (td "super") (td "超高") (td "5") (td))
		 (tr (td "test") (td "テスト") (td "4") (td "＊")))
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
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume change precedence item values"
                 w
                 '(("id" "test")
                   ("disp" "")
                   ("level" "2")
                   ("delete" "off")))


 (test* "kagoiri-musume confirm to added precedence item"
	'(*TOP*
	  ?*
	  (form ?@
		(table
		 (thead "登録優先度一覧")
		 (tr (th "優先度ID") (th "表示名") (th "レベル") (th "無効"))
		 (tr (td "high") (td "高") (td "4") (td))
		 (tr (td "low") (td "低") (td "2") (td))
		 (tr (td "normal") (td "普通") (td "3") (td))
		 (tr (td "super") (td "超高") (td "5") (td))
		 (tr (td "test") (td "テスト") (td "2") (td)))
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
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録ステータス一覧")
		 (tr (th "ステータスID") (th "表示名") (th "無効"))
		 (tr (td "completed") (td "COMPLETED") (td))
		 (tr (td "on-hold") (td "ON HOLD") (td))
		 (tr (td "open") (td "OPEN") (td))
		 (tr (td "rejected") (td "REJECTED") (td))
		 (tr (td "taken") (td "TAKEN") (td)))
		(table
		 (tr (th "ステータスID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume add new status item"
                 w
                 '(("id" "test")
                   ("disp" "テストステータス")
                   ("delete" "off")))


 (test* "kagoiri-musume confirm to added status item"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録ステータス一覧")
		 (tr (th "ステータスID") (th "表示名") (th "無効"))
		 (tr (td "completed") (td "COMPLETED") (td))
		 (tr (td "on-hold") (td "ON HOLD") (td))
		 (tr (td "open") (td "OPEN") (td))
		 (tr (td "rejected") (td "REJECTED") (td))
		 (tr (td "taken") (td "TAKEN") (td))
		 (tr (td "test") (td "テストステータス") (td)))
		(table
		 (tr (th "ステータスID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume change status item value"
                 w
                 '(("id" "test")
                   ("disp" "テスト")
                   ("delete" "on")))


 (test* "kagoiri-musume confirm to added status item"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録ステータス一覧")
		 (tr (th "ステータスID") (th "表示名") (th "無効"))
		 (tr (td "completed") (td "COMPLETED") (td))
		 (tr (td "on-hold") (td "ON HOLD") (td))
		 (tr (td "open") (td "OPEN") (td))
		 (tr (td "rejected") (td "REJECTED") (td))
		 (tr (td "taken") (td "TAKEN") (td))
		 (tr (td "test") (td "テスト") (td "＊")))
		(table
		 (tr (th "ステータスID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume change status item value"
                 w
                 '(("id" "test")
                   ("disp" "")
                   ("delete" "off")))

 (test* "kagoiri-musume confirm to added status item"
	'(*TOP*
	  ?*
	  (form ?@
		(table
		 (thead "登録ステータス一覧")
		 (tr (th "ステータスID") (th "表示名") (th "無効"))
		 (tr (td "completed") (td "COMPLETED") (td))
		 (tr (td "on-hold") (td "ON HOLD") (td))
		 (tr (td "open") (td "OPEN") (td))
		 (tr (td "rejected") (td "REJECTED") (td))
		 (tr (td "taken") (td "TAKEN") (td))
		 (tr (td "test") (td "テスト") (td)))
		(table
		 (tr (th "ステータスID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録タイプ一覧")
		 (tr (th "タイプID") (th "表示名") (th "無効"))
		 (tr (td "bug") (td "バグ") (td))
		 (tr (td "discuss") (td "議論") (td))
		 (tr (td "etc") (td "その他") (td))
		 (tr (td "report") (td "報告") (td))
		 (tr (td "request") (td "変更要望") (td))
		 (tr (td "task") (td "タスク") (td))
		 (tr (td "term") (td "用語") (td)))
		(table
		 (tr (th "タイプID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume add new type item"
                 w
                 '(("id" "test")
                   ("disp" "テストタイプ")
                   ("delete" "off")))

 (test* "kagoiri-musume confirm to added type item"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録タイプ一覧")
		 (tr (th "タイプID") (th "表示名") (th "無効"))
		 (tr (td "bug") (td "バグ") (td))
		 (tr (td "discuss") (td "議論") (td))
		 (tr (td "etc") (td "その他") (td))
		 (tr (td "report") (td "報告") (td))
		 (tr (td "request") (td "変更要望") (td))
		 (tr (td "task") (td "タスク") (td))
		 (tr (td "term") (td "用語") (td))
		 (tr (td "test") (td "テストタイプ") (td)))
		(table
		 (tr (th "タイプID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume change type item value"
                 w
                 '(("id" "test")
                   ("disp" "テスト")
                   ("delete" "on")))

 (test* "kagoiri-musume confirm to added type item"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録タイプ一覧")
		 (tr (th "タイプID") (th "表示名") (th "無効"))
		 (tr (td "bug") (td "バグ") (td))
		 (tr (td "discuss") (td "議論") (td))
		 (tr (td "etc") (td "その他") (td))
		 (tr (td "report") (td "報告") (td))
		 (tr (td "request") (td "変更要望") (td))
		 (tr (td "task") (td "タスク") (td))
		 (tr (td "term") (td "用語") (td))
		 (tr (td "test") (td "テスト") (td "＊")))
		(table
		 (tr (th "タイプID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume change type item value"
                 w
                 '(("id" "test")
                   ("disp" "")
                   ("delete" "off")))


 (test* "kagoiri-musume confirm to added type item"
	'(*TOP*
	  ?*
	  (form ?@
		(table
		 (thead "登録タイプ一覧")
		 (tr (th "タイプID") (th "表示名") (th "無効"))
		 (tr (td "bug") (td "バグ") (td))
		 (tr (td "discuss") (td "議論") (td))
		 (tr (td "etc") (td "その他") (td))
		 (tr (td "report") (td "報告") (td))
		 (tr (td "request") (td "変更要望") (td))
		 (tr (td "task") (td "タスク") (td))
		 (tr (td "term") (td "用語") (td))
		 (tr (td "test") (td "テスト") (td)))
		(table
		 (tr (th "タイプID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録カテゴリ一覧")
		 (tr (th "カテゴリID") (th "表示名") (th "無効"))
		 (tr (td "global") (td "全体") (td))
		 (tr (td "infra") (td "インフラ") (td))
		 (tr (td "master") (td "マスタ") (td))
		 (tr (td "section") (td "セクション") (td)))
		(table
		 (tr (th "カテゴリID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume add new category item"
                 w
                 '(("id" "test")
                   ("disp" "テストカテゴリ")
                   ("delete" "off")))


 (test* "kagoiri-musume confirm to added category item 1"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録カテゴリ一覧")
		 (tr (th "カテゴリID") (th "表示名") (th "無効"))
		 (tr (td "global") (td "全体") (td))
		 (tr (td "infra") (td "インフラ") (td))
		 (tr (td "master") (td "マスタ") (td))
		 (tr (td "section") (td "セクション") (td))
		 (tr (td "test") (td "テストカテゴリ") (td)))
		(table
		 (tr (th "カテゴリID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume change category item value"
                 w
                 '(("id" "test")
                   ("disp" "テスト")
                   ("delete" "on")))
 
 (test* "kagoiri-musume confirm to added category item 2"
	'(*TOP*
	  ?*
	  (form (@ (action ?&) ?*)
		(table
		 (thead "登録カテゴリ一覧")
		 (tr (th "カテゴリID") (th "表示名") (th "無効"))
		 (tr (td "global") (td "全体") (td))
		 (tr (td "infra") (td "インフラ") (td))
		 (tr (td "master") (td "マスタ") (td))
		 (tr (td "section") (td "セクション") (td))
		 (tr (td "test") (td "テスト") (td "＊")))
		(table
		 (tr (th "カテゴリID") (th "表示名") (th "無効"))
		 (tr (td (input (@ (type "text") (name "id"))))
		     (td (input (@ (type "text") (name "disp"))))
		     (td (input (@ (type "checkbox") (name "delete")))))
		 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
	  ?*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// form))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume change category item value"
                 w
                 '(("id" "test")
                   ("disp" "")
                   ("delete" "off")))

 (test* "kagoiri-musume confirm to added category item 3"
        '(*TOP*
          ?*
          (form (@ (action ?&) ?*)
                (table
                 (thead "登録カテゴリ一覧")
                 (tr (th "カテゴリID") (th "表示名") (th "無効"))
                 (tr (td "global") (td "全体") (td))
                 (tr (td "infra") (td "インフラ") (td))
                 (tr (td "master") (td "マスタ") (td))
                 (tr (td "section") (td "セクション") (td))
                 (tr (td "test") (td "テスト") (td)))
                (table
                 (tr (th "カテゴリID") (th "表示名") (th "無効"))
                 (tr (td (input (@ (type "text") (name "id"))))
                     (td (input (@ (type "text") (name "disp"))))
                     (td (input (@ (type "checkbox") (name "delete")))))
                 (tr (td (input (@ (value "登録") (type "submit") (name "submit")))))))
          ?*)
        (call-worker/gsid->sxml
         w
         '()
         '()
         '(// form))
        (make-match&pick w))
 )

(test-end)
