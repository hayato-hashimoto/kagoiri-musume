;; -*- coding: euc-jp; mode: scheme -*-
;; test kagoiri-musume script.
;; $Id: test4.scm,v 1.1 2005/10/30 15:01:27 cut-sea Exp $

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
	   (body (div ?@
		      (h1 ?@ ?_)
		      (a ?@ "トップ")
		      (a ?@ "システム管理")
		      (a ?@ "ユニット一覧")
		      (a ?@ "Login"))
		 ,(*make-body*
		   (h2 ?_)
		   (ul ?@
		       (li (a ?@ "システム設定管理画面"))
		       (li (a (@ (href ?&)) "ユニット一覧"))))
		 ,*footer*))
        (call-worker/gsid w '() '() (lambda (h b) (tree->string b)))
        (make-match&pick w))

 (test* "kagoiri-musume unit-list link click without login"
	'(*TOP*
	  (form (@ (action ?&) ?*)
		(table (tr (th "Login Name")
			   (td (input (@ (value "") (type "text") (name "name")))))
		       (tr (th "Password")
			   (td (input (@ (value "") (type "password") (name "pass"))))))
		(input (@ (value "login") (type "submit") (name "submit")))))
	(call-worker/gsid->sxml w '() '() '(// form))
	(make-match&pick w))

 (test* "kagoiri-musume unit-list link click with login"
	`(html
	  ,*head*
	  (body (div ?@
		     (h1 ?@ ?_)
		     (a ?@ "トップ")
		     (a ?@ "システム管理")
		     (a ?@ "ユニット一覧")
		     (a ?@ "パスワード変更")
		     (span " Now login:" (a ?@ "cut-sea"))
		     (a ?@ "Logout")
		     (form ?@ "検索:" (input ?@)))
		(div ?@
		     (h2 "ユニット一覧")
		     (table ?@
			    (thead (tr (th) (th) (th "ユニット名") (th "概要") (th "ファン")))
			    (tbody))
		     (hr)
		     (h2 "新ユニット結成")
		     (form ?@
			   (table
			    (tr ?@
				(th ?@ (span ?@ "優先度"))
				(th ?@ (span ?@ "ステータス"))
				(th ?@ (span ?@ "タイプ"))
				(th ?@ (span ?@ "カテゴリ")))
			    (tr (td (select ?@
					    (option (@ (value "high")) "高")
					    (option (@ (value "low")) "低")
					    (option (@ (value "normal")) "普通")
					    (option (@ (value "super")) "超高")))
				(td (div ?@ "↑")
				    (div ?@ "↓"))
				(td (select ?@
					    (option (@ (value "completed")) "COMPLETED")
					    (option (@ (value "on-hold")) "ON HOLD")
					    (option (@ (value "open")) "OPEN")
					    (option (@ (value "rejected")) "REJECTED")
					    (option (@ (value "taken")) "TAKEN")))
				(td (div ?@ "↑")
				    (div ?@ "↓"))
				(td (select ?@
					    (option (@ (value "bug")) "バグ")
					    (option (@ (value "discuss")) "議論")
					    (option (@ (value "etc")) "その他")
					    (option (@ (value "report")) "報告")
					    (option (@ (value "request")) "変更要望")
					    (option (@ (value "task")) "タスク")
					    (option (@ (value "term")) "用語")))
				(td (div ?@ "↑")
				    (div ?@ "↓"))
				(td (select ?@
					    (option (@ (value "global")) "全体")
					    (option (@ (value "infra")) "インフラ")
					    (option (@ (value "master")) "マスタ")
					    (option (@ (value "section")) "セクション")))
				(td (div ?@ "↑")
				    (div ?@ "↓"))))
			   (table
			    (tr
			     (td "ユニット名" (span (|@| (class "warning")) "(※)"))
			     (td (textarea (|@| (type "text") (rows "1") (name "name") (cols "32")))))
			    (tr
			     (td "概要")
			     (td (|@| (colspan "2")) (textarea (|@| (type "text") (rows "10") (name "desc") (cols "80")))))
			    (tr ?@
				(td "ファン" (span ?@ "(※)"))
				(td
				 (table
				  (tr
				   (td (select ?@
					       (option (@ (value "   ")))
					       (option (@ (value "cut-sea")) "cut-sea")
					       (option (@ (value "kago")) "kago")))
				   (td (div ?@ "↑")
				       (div ?@ "↓")))))))
			   (input (@ (value "新ユニット結成") (type "submit") (name "submit")))))
		,*footer*))
	(call-worker/gsid w
			  '()
			  '(("name" "cut-sea") ("pass" "cutsea"))
			  (lambda (h b) (tree->string b)))
	(make-match&pick w))

 )

(test-end)
