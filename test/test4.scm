;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: test4.scm,v 1.30 2006/02/12 03:05:17 cut-sea Exp $

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

(test-start "kagoiri-musume operate unit&musume&melody")

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
		(a ?@ "システム管理")
		(a (@ (href ?&) ?*) "ユニット一覧")
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

 (test* "kagoiri-musume unit-list link click without login"
	'(*TOP*
	  (form (@ (action ?&) ?*)
		(table (tr (th "Login Name")
			   (td (input (@ (value "") (type "text") (name "name") (id "focus")))))
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
		     (a ?@ "システム管理")
		     (a ?@ "ユニット一覧")
		     (a ?@ "パスワード変更")
		     (span " Now login:" (a ?@ "cut-sea"))
		     (a ?@ "Logout")
		     (form ?@ (input ?@) (input ?@)))
		(div ?@
		     (h2 "ユニット一覧")
		     (table ?@
			    (thead (tr (th) (th "ユニット名") (th "概要") (th "ファン") (th "購読")))
			    (tbody))
		     (hr)
		     (h2 "新ユニット結成")
		     (form (@ (action ?&) ?*)
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
					       (option (@ (value "guest")) "guest")
					       (option (@ (value "kago")) "kago")))
				   (td (div ?@ "↑")
				       (div ?@ "↓"))))))
                            (tr (td "通知アドレス") (td (textarea ?@) ?*)))
			   (input (@ (value "新ユニット結成") (type "submit")))))
		,*footer*))
	(call-worker/gsid w
			  '()
			  '(("name" "cut-sea") ("pass" "cutsea"))
			  (lambda (h b) (tree->string b)))
	(make-match&pick w))

 (test/send&pick "kagoiri-musume add new unit"
                 w
                 '(("priority" "normal" "low" "high")
		   ("status" "open" "completed")
		   ("type" "bug" "task" "request")
		   ("category" "global" "section")
		   ("name" "籠入娘。Test Proj.")
		   ("desc" "籠入娘。のバグトラッキングを行うユニット")
		   ("fans" "   " "cut-sea")))

 (test* "kagoiri-musume check new unit"
	`(*TOP*
	  (table ?@
		 (thead (tr (th) (th "ユニット名") (th "概要") (th "ファン") (th "購読")))
		 (tbody (tr ?@
			    (td (a (@ (href ?&)) "設定"))
			    (td (a ?@ "籠入娘。Test Proj.") " (0)")
			    (td "籠入娘。のバグトラッキングを行うユニット")
			    (td "cut-sea")
                            (td (a ?@ "○"))))))
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// body div table))
        (make-match&pick w))

 (test* "kagoiri-musume edit unit"
	`(html
	  ,*head*
	  (body
	   (div ?@ (h1 ?@ "籠入娘。 - Groupie System")
		(a ?@ "システム管理")
		(a ?@ "ユニット一覧")
		(a ?@ "パスワード変更")
		(span " Now login:" (a ?@ "cut-sea"))
		(a ?@ "Logout")
		(form ?@ (input ?@) (input ?@)))
	   (div ?@ (h2 "『籠入娘。Test Proj.』ユニット設定")
		(form (@ (action ?&) ?*)
		      (table
		       (tr ?@
			   (th ?@ (span ?@ "優先度"))
			   (th ?@ (span ?@ "ステータス"))
			   (th ?@ (span ?@ "タイプ"))
			   (th ?@ (span ?@ "カテゴリ")))
		       (tr
			(td (select ?@
				    (option (@ (value "normal") (selected "#t")) "普通")
				    (option (@ (value "low") (selected "#t")) "低")
				    (option (@ (value "high") (selected "#t")) "高")
				    (option (@ (value "super")) "超高")))
			(td (div ?@ "↑")
			    (div ?@ "↓"))
			(td (select ?@
				    (option (@ (value "open") (selected "#t")) "OPEN")
				    (option (@ (value "completed") (selected "#t")) "COMPLETED")
				    (option (@ (value "on-hold")) "ON HOLD")
				    (option (@ (value "rejected")) "REJECTED")
				    (option (@ (value "taken")) "TAKEN")))
			(td (div ?@ "↑")
			    (div ?@ "↓"))
			(td (select ?@
				    (option (@ (value "bug") (selected "#t")) "バグ")
				    (option (@ (value "task") (selected "#t")) "タスク")
				    (option (@ (value "request") (selected "#t")) "変更要望")
				    (option (@ (value "discuss")) "議論")
				    (option (@ (value "etc")) "その他")
				    (option (@ (value "report")) "報告")
				    (option (@ (value "term")) "用語")))
			(td (div ?@ "↑")
			    (div ?@ "↓"))
			(td (select ?@
				    (option (@ (value "global") (selected "#t")) "全体")
				    (option (@ (value "section") (selected "#t")) "セクション")
				    (option (@ (value "infra")) "インフラ")
				    (option (@ (value "master")) "マスタ")))
			(td (div ?@ "↑")
			    (div ?@ "↓"))))
		      (table
		       (tr (td "ユニット名" (span ?@ "(※)"))
			   (td (textarea ?@ "籠入娘。Test Proj.")))
		       (tr (td "概要")
			   (td ?@ (textarea ?@ "籠入娘。のバグトラッキングを行うユニット")))
		       (tr ?@
			   (td "ファン" (span ?@ "(※)"))
			   (td
			    (table
			     (tr (td (select ?@
					     (option (@ (value "   ") (selected "#t")))
					     (option (@ (value "cut-sea") (selected "#t")) "cut-sea")
					     (option (@ (value "guest")) "guest")
					     (option (@ (value "kago")) "kago")))
				 (td (div ?@ "↑")
				     (div ?@ "↓"))))))
                       (tr (td "通知アドレス") (td (textarea ?@) ?*)))
		      (input ?@)))
	   ,*footer*))
        (call-worker/gsid
	 w
	 '()
	 '()
	 (lambda (h b) (tree->string b)))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume modify unit setting"
                 w
                 '(("priority" "normal" "super" "high")
		   ("status" "open" "on-hold" "completed")
		   ("type" "task" "request" "discuss")
		   ("category" "master" "infra" "global" "section")
		   ("name" "籠入娘。Test Project.")
		   ("desc" "籠入娘。のバグトラッキングとタスクマネージメントを行うユニット")
		   ("fans" "   " "cut-sea" "guest")))

 (test* "kagoiri-musume check modified unit"
	`(*TOP*
	  (table ?@
		 (thead (tr (th) (th "ユニット名") (th "概要") (th "ファン") (th "購読")))
		 (tbody (tr ?@
			    (td (a ?@ "設定"))
			    (td (a (@ (href ?&) ?*) "籠入娘。Test Project.") " (0)")
			    (td "籠入娘。のバグトラッキングとタスクマネージメントを行うユニット")
			    (td "cut-sea , guest")
                            (td (a ?@ "○"))))))
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// body div table))
        (make-match&pick w))

 (test* "kagoiri-musume view unit's empty musume-list"
	`(html
	  ,*head*
	  (body
	   (div ?@
		(h1 ?@ "籠入娘。 - Groupie System")
		(a ?@ "システム管理")
		(a ?@ "ユニット一覧")
		(a ?@ "パスワード変更")
		(span " Now login:" (a ?@ "cut-sea"))
		(a ?@ "Logout")
		(form ?@ (input ?@) (input ?@)))
	   (div ?@
		(ul ?@
		    (li (a ?@ "娘。一覧"))
		    (li (a (@ (href ?&) ?*) "新しい娘。")))
		(div ?@
		     (form ?@ (input ?@) "ユニット内検索:"
			   (input ?@)
			   (input (@ (value "検索") (type "submit")))))
		(h2 "籠入娘。Test Project. - 娘。一覧")
		(form ?@
		      (table ?@
			     (tr ?@
				 (th (span ?@ "優先度"))
				 (th (span (@ (class "clickable")) "ステータス"))
				 (th (span (@ (class "clickable")) "タイプ"))
				 (th (span (@ (class "clickable")) "カテゴリ"))
				 (th (span (@ (class "clickable")) "アサイン"))
				 (th "表示上限"))
			     (tr ?@
				 (td (select (@ (onchange ?_) (name "priority"))
					     (option (@ (value "*all*")) "全て")
					     (option (@ (value "normal")) "普通")
					     (option (@ (value "super")) "超高")
					     (option (@ (value "high")) "高")))
				 (td (select (@ (onchange ?_) (name "status"))
					     (option (@ (value "*all*")) "全て")
					     (option (@ (value "open")) "OPEN")
					     (option (@ (value "on-hold")) "ON HOLD")
					     (option (@ (value "completed")) "COMPLETED")))
				 (td (select (@ (onchange ?_) (name "type"))
					     (option (@ (value "*all*")) "全て")
					     (option (@ (value "task")) "タスク")
					     (option (@ (value "request")) "変更要望")
					     (option (@ (value "discuss")) "議論")))
				 (td (select (@ (onchange ?_) (name "category"))
					     (option (@ (value "*all*")) "全て")
					     (option (@ (value "master")) "マスタ")
					     (option (@ (value "infra")) "インフラ")
					     (option (@ (value "global")) "全体")
					     (option (@ (value "section")) "セクション")))
				 (td (select (@ (onchange ?_) (name "assign"))
					     (option (@ (value "*all*")) "全て")
					     (option (@ (value "   ")))
					     (option (@ (value "cut-sea")) "cut-sea")
					     (option (@ (value "guest")) "guest")))
				 (td (select (@ (name "limit"))
					     (option (@ (value "")))
					     (option (@ (value "20")) "20")
					     (option (@ (value "50")) "50")
					     (option (@ (value "200") (selected "true")) "200")
					     (option (@ (value "500")) "500")
					     (option (@ (value "1000")) "1000")))
				 (td (input (@ (value "絞り込み") (type "submit") (name "submit"))))))
		      (table ?@
			     (thead "萌えられる娘。がいません(T^T)"
				    (div ?@
					 (span (a ?@ "OPEN") "(0) ")
					 (span (a ?@ "ON HOLD") "(0) ")
					 (span (a ?@ "COMPLETED") "(0) "))
				    (tr ?@
					(th)
					(th ?@ "No.")
					(th ?@ "タイトル")
					(th ?@ "優先度")
					(th ?@ "ステータス")
					(th ?@ "タイプ")
					(th ?@ "カテゴリ")
					(th ?@ "アサイン")
					(th ?@ "期限")
					(th ?@ "登録日")
					(th ?@ "更新日"))) (tbody))))
	   ,*footer*))
        (call-worker/gsid
	 w
	 '()
	 '()
	 (lambda (h b) (tree->string b)))
        (make-match&pick w))

 (test* "kagoiri-musume musume-new link click"
	`(html
	  ,*head*
	  (body
	   (div ?@ (h1 ?@ "籠入娘。 - Groupie System")
		(a ?@ "システム管理")
		(a ?@ "ユニット一覧")
		(a ?@ "パスワード変更")
		(span " Now login:" (a ?@ "cut-sea"))
		(a ?@ "Logout")
		(form ?@ (input ?@) (input ?@)))
	   (div ?@
		(ul ?@
		    (li (a ?@ "娘。一覧"))
		    (li (a ?@ "新しい娘。")))
		(h2 "籠入娘。Test Project. - 新しい娘。")
		(form (@ (action ?&) ?*)
		      (table
		       (tr
			(td
			 (table
			  (tr (th "優先度")
			      (th "ステータス")
			      (th "タイプ")
			      (th "カテゴリ")
			      (th "アサイン"))
			  (tr
			   (td
			    (select (@ (name "priority"))
				    (option (@ (value "normal")) "普通")
				    (option (@ (value "super")) "超高")
				    (option (@ (value "high")) "高")))
			   (td
			    (select (@ (name "status"))
				    (option (@ (value "open")) "OPEN")
				    (option (@ (value "on-hold")) "ON HOLD")
				    (option (@ (value "completed")) "COMPLETED")))
			   (td
			    (select (@ (name "type"))
				    (option (@ (value "task")) "タスク")
				    (option (@ (value "request")) "変更要望")
				    (option (@ (value "discuss")) "議論")))
			   (td
			    (select (@ (name "category"))
				    (option (@ (value "master")) "マスタ")
				    (option (@ (value "infra")) "インフラ")
				    (option (@ (value "global")) "全体")
				    (option (@ (value "section")) "セクション")))
			   (td
			    (select (@ (name "assign"))
				    (option (@ (value "   ")))
				    (option (@ (value "cut-sea")) "cut-sea")
				    (option (@ (value "guest")) "guest")))
			   (td
			    (input (@ (value "新しい娘。加入") (onclick "submit();") (type "button")))))))
			(td ?@ (table ?*)))
		       (tr (td
			    (table
			     (tr
			      (td "タイトル" (span ?@ "(※)"))
			      (td (input (@ (!permute (type "text") (name "name") ?*)))))
			     (tr (td "内容")
				 (td (textarea (@ (!permute (type "text") (name "melody") ?*)))))
			     (tr (td "ファイル")
				 (td (input (@ (type "file") (name "file")))
				     (input (@ (value "") (type "hidden") (name "filename"))))))))
		       (tr (td
			    (input (@ (value "新しい娘。加入") (onclick "submit();") (type "button"))))))))
	   ,*footer*))
        (call-worker/gsid
	 w
	 '()
	 '()
	 (lambda (h b) (tree->string b)))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume musume-new create"
                 w
                 '(("priority" "high")
		   ("status" "open")
		   ("type" "task")
		   ("category" "global")
		   ("name" "テストな娘。")
		   ("melody" "テストをする必要があるのでするなり")
		   ("assign" "cut-sea")))

 (test* "kagoiri-musume check melody-list"
	`(html
	  ,*head*
	  (body
	   (div ?@ (h1 ?@ "籠入娘。 - Groupie System")
		(a ?@ "システム管理")
		(a ?@ "ユニット一覧")
		(a ?@ "パスワード変更")
		(span " Now login:" (a ?@ "cut-sea"))
		(a ?@ "Logout")
		(form ?@ (input ?@) (input ?@)))
	   (div ?@
		(ul ?@
		    (li (a ?@ "娘。一覧"))
		    (li (a ?@ "新しい娘。")))
                (a ?@ "ブックマークに追加")
		(div (a ?@ "<<")
		     (a ?@ ">>"))
		(h3 "籠入娘。Test Project. - 1：テストな娘。 - OPEN")
		(form (@ (action ?&) ?*)
		      (table
		       (tr
			(td
			 (table
			  (tr
			   (th "優先度")
			   (th "ステータス")
			   (th "タイプ")
			   (th "カテゴリ")
			   (th "アサイン"))
			  (tr
			   (td
			    (select (@ (name "priority"))
				    (option (@ (value "normal")) "普通")
				    (option (@ (value "super")) "超高")
				    (option (@ (value "high") (selected "true")) "高")))
			   (td
			    (select (@ (name "status"))
				    (option (@ (value "open") (selected "true")) "OPEN")
				    (option (@ (value "on-hold")) "ON HOLD")
				    (option (@ (value "completed")) "COMPLETED")))
			   (td
			    (select (@ (name "type"))
				    (option (@ (value "task") (selected "true")) "タスク")
				    (option (@ (value "request")) "変更要望")
				    (option (@ (value "discuss")) "議論")))
			   (td
			    (select (@ (name "category"))
				    (option (@ (value "master")) "マスタ")
				    (option (@ (value "infra")) "インフラ")
				    (option (@ (value "global") (selected "true")) "全体")
				    (option (@ (value "section")) "セクション")))
			   (td
			    (select (@ (name "assign"))
				    (option (@ (value "   ")))
				    (option (@ (value "cut-sea") (selected "true")) "cut-sea")
				    (option (@ (value "guest")) "guest")))
			   (td
			    (input (@ (value "コミット") (type "submit")))))))
			(td ?@ (table ?*)))
		       (tr
			(td
			 (table ?@
				(tr (td "内容")
				    (td (textarea (@ (!permute (type "text") (name "melody") ?*)))))
				(tr (td "ファイル")
				    (td (input (@ (type "file") (name "file"))))))))))
		(dl ?@ 
		    (dt (span ?@ "♪1.") (span ?@ ?_)
			(span ?@ "[cut-sea]")
			?*)
		    (dd (pre "テストをする必要があるのでするなり"))))
	   ,*footer*))
        (call-worker/gsid
	 w
	 '()
	 '()
	 (lambda (h b) (tree->string b)))
        (make-match&pick w))

 (test/send&pick "kagoiri-musume check melody-list"
                 w
                 '(("priority" "super")
		   ("status" "completed")
		   ("type" "discuss")
		   ("category" "section")
		   ("melody" "クローズする")
		   ("assign" "   ")))

 (test* "kagoiri-musume check melody-list complete"
	`(*TOP*
	  (div ?@ (h1 ?@ "籠入娘。 - Groupie System")
	       (a ?@ "システム管理")
	       (a ?@ "ユニット一覧")
	       (a ?@ "パスワード変更")
	       (span " Now login:" (a ?@ "cut-sea"))
	       (a ?@ "Logout")
	       (form ?@ (input ?@) (input ?@)))
	  (div ?@
	       (ul ?@
		   (li (a ?@ "娘。一覧"))
		   (li (a ?@ "新しい娘。")))
               (a ?@ "ブックマークに追加")
	       (div
		(a ?@ "<<")
		(a ?@ ">>"))
	       (h3 "籠入娘。Test Project. - 1：テストな娘。 - COMPLETED")
	       (form ?@
		     (table
		      (tr
		       (td
			(table
			 (tr (th "優先度") (th "ステータス") (th "タイプ") (th "カテゴリ") (th "アサイン"))
			 (tr
			  (td
			   (select (@ (name "priority"))
				   (option (@ (value "normal")) "普通")
				   (option (@ (value "super") (selected "true")) "超高")
				   (option (@ (value "high")) "高")))
			  (td
			   (select (@ (name "status"))
				   (option (@ (value "open")) "OPEN")
				   (option (@ (value "on-hold")) "ON HOLD")
				   (option (@ (value "completed") (selected "true")) "COMPLETED")))
			  (td
			   (select (@ (name "type"))
				   (option (@ (value "task")) "タスク")
				   (option (@ (value "request")) "変更要望")
				   (option (@ (value "discuss") (selected "true")) "議論")))
			  (td
			   (select (@ (name "category"))
				   (option (@ (value "master")) "マスタ")
				   (option (@ (value "infra")) "インフラ")
				   (option (@ (value "global")) "全体")
				   (option (@ (value "section") (selected "true")) "セクション")))
			  (td
			   (select (@ (name "assign"))
				   (option (@ (value "   ") (selected "true")))
				   (option (@ (value "cut-sea")) "cut-sea")
				   (option (@ (value "guest")) "guest")))
			  (td (input (@ (value "コミット") (type "submit")))))))
		       (td ?@ (table ?*)))
		      (tr
		       (td
			(table ?@
			       (tr (td "内容")
				   (td (textarea (@ (!permute (type "text") (name "melody") ?*)))))
			       (tr (td "ファイル")
				   (td (input (@ (type "file") (name "file"))))))))))
	       (dl ?@
		   (dt (span ?@ "♪2.") (span ?@ ?_) (span ?@ "[cut-sea]") ?*)
		   (dd (pre "クローズする")))
	       (dl ?@
		   (dt (span ?@ "♪1.") (span ?@ ?_) (span ?@ "[cut-sea]") ?*)
		   (dd (pre "テストをする必要があるのでするなり"))))
	  ,*footer*)
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
	 '(// body div))
        (make-match&pick w))

 )

(test-end)
