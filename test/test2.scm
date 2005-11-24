;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: test2.scm,v 1.13 2005/11/24 16:42:59 shibata Exp $

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

(test-start "kagoiri-musume unit-list enter check")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (test* "kagoiri-musume top2"
	`(html
	  ,*head*
	  (body (div ?@
                     (h1 ?@ ?_)
		     (a ?@ "トップ")
		     (a ?@ "システム管理")
		     (a (@ (href ?&)) "ユニット一覧")
		     (a ?@ "Login"))
                ,(*make-body*
                  (h2 ?_)
                  (ul ?@
                   (li (a ?@ "システム設定管理画面"))
                   (li (a ?@ "ユニット一覧"))))
                ,*footer*))
        (call-worker/gsid w '() '() (lambda (h b) (tree->string b)))
        (make-match&pick w))

 (test* "kagoiri-musume unit-list link click without login"
	`(html
	  ,*head*
	  (body
           ,*header*
           ,(*make-body*
             (h1 "籠入娘。へようこそ！")
             (h3 "ユニット一覧は一般ユーザアカウントが必要です")
             (form (@ (action ?&) ?*)
                   (table
                    (tr (th "Login Name") (td (input (@ (value "") (type "text") (name "name") (id "focus")))))
                    (tr (th "Password") (td (input (@ (value "") (type "password") (name "pass"))))))
                   (input (@ (value "login") (type "submit") (name "submit")))))
           ,*footer*))
        (call-worker/gsid w '() '() (lambda (h b) (tree->string b)))
        (make-match&pick w))

 (test* "kagoiri-musume unit-list link click with login"
	`(html
	  ,*head*
	  (body
	   (div ?@
                (h1 ?@ ?_)
		(a ?@ "トップ")
		(a ?@ "システム管理")
                (a ?@ "ユニット一覧")
		(a (@ (href ?&)) "パスワード変更")
                (span " Now login:" (a ?@ "cut-sea"))
		(a ?@ "Logout")
                (form ?@ "検索:" (input ?@)))
           ,(*make-body*
             (h2 "ユニット一覧")
             (table
              ?@
              (thead (tr (th) (th) (th "ユニット名") (th "概要") (th "ファン") (th "購読")))
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
                    (tr
                     (td (select (@ (size "5")
                                    (name "priority")
                                    (multiple "true")
                                    (id "priority"))
                                 (!permute
                                  (option (@ (value "high")) "高")
                                  (option (@ (value "low")) "低")
                                  (option (@ (value "normal")) "普通")
                                  (option (@ (value "super")) "超高"))))
                     (td ?*)
                     (td (select (@ (size "5") (name "status") (multiple "true") (id "status"))
                                 (!permute
                                  (option (@ (value "completed")) "COMPLETED")
                                  (option (@ (value "on-hold")) "ON HOLD")
                                  (option (@ (value "open")) "OPEN")
                                  (option (@ (value "rejected")) "REJECTED")
                                  (option (@ (value "taken")) "TAKEN"))))
                     (td ?*)
                     (td (select (@ (size "5") (name "type") (multiple "true") (id "type"))
                                 (!permute
                                  (option (@ (value "bug")) "バグ")
                                  (option (@ (value "discuss")) "議論")
                                  (option (@ (value "etc")) "その他")
                                  (option (@ (value "report")) "報告")
                                  (option (@ (value "request")) "変更要望")
                                  (option (@ (value "task")) "タスク")
                                  (option (@ (value "term")) "用語"))))
                     (td ?*)
                     (td (select (@ (size "5") (name "category") (multiple "true") (id "category"))
                                 (!permute
                                  (option (@ (value "global")) "全体")
                                  (option (@ (value "infra")) "インフラ")
                                  (option (@ (value "master")) "マスタ")
                                  (option (@ (value "section")) "セクション"))))
                     (td ?*)))
                   (table
                    (tr (td "ユニット名" ?_) (td (textarea ?@) ?*))
                    (tr (td "概要") (td (@ (colspan "2")) (textarea ?@)))
                    (tr (@ (align "left"))
                        (td "ファン" ?_)
                        (td
                         (table (tr (td
                                     (select ?@
                                             (option (@ (value "   ")))
                                             (option (@ (value "cut-sea")) "cut-sea")
					     (option (@ (value "guest")) "guest")
                                             (option (@ (value "kago")) "kago")))
                                    (td ?*)))))
                    (tr (td "通知アドレス") (td (textarea ?@) ?*)))
                   (input (@ (!permute
                              (value "新ユニット結成")
                              (type "submit"))))))
           ,*footer*))
        (call-worker/gsid w
			  '()
			  '(("name" "cut-sea") ("pass" "cutsea"))
			  (lambda (h b) (tree->string b)))
        (make-match&pick w))

(test* "kagoiri-musume click change password"
       `(html
	 ,*head*
	 (body
	  ,(*header-logedin* "cut-sea")
          ,(*make-body*
            (h3 "cut-sea さんのパスワード変更")
            (form (@ (action ?&) ?*)
                  (table
                   (tr (th "旧パスワード")
                       (td (input (@ (!permute (value "") (type "password") (name "old-pw") (id "focus"))))))
                   (tr (th "新パスワード")
                       (td (input (@ (!permute (value "") (type "password") (name "new-pw"))))))
                   (tr (th "新パスワード(確認)")
                       (td (input (@ (!permute (value "") (type "password") (name "new-again-pw")))))))
                  (input (@ (!permute (value "変更") (type "submit") (name "submit"))))
                  (p (@ (class "warning")) ?*)))
          ,*footer*))
        (call-worker/gsid w
			  '()
			  '(("name" "cut-sea") ("pass" "cutsea"))
			  (lambda (h b) (tree->string b)))
        (make-match&pick w))

(test* "kagoiri-musume change password with bad new-password"
       '(*TOP*
	 ?*
	 (form (@ (action ?&) ?*)
	       (table
		(tr (th "旧パスワード")
		    (td (input (@ (!permute (value "") (type "password") (name "old-pw") (id "focus"))))))
		(tr (th "新パスワード")
		    (td (input (@ (!permute (value "") (type "password") (name "new-pw"))))))
		(tr (th "新パスワード(確認)")
		    (td (input (@ (!permute (value "") (type "password") (name "new-again-pw")))))))
	       (input (@ (!permute (value "変更") (type "submit") (name "submit"))))
	       (p (@ (class "warning")) "新パスワードが不正です"))
	 ?*
	 )
       (call-worker/gsid->sxml w
			       '()
			       '(("old-pw" "cutsea") ("new-pw" "badsea") ("new-again-pw" "newsea"))
			       '(// form))
       (make-match&pick w))

(test* "kagoiri-musume change password with bad old-password"
       '(*TOP*
	 ?*
	 (form (@ (action ?&) ?*)
		(table
		 (tr (th "旧パスワード")
		     (td (input (@ (!permute (value "") (type "password") (name "old-pw") (id "focus"))))))
		 (tr (th "新パスワード")
		     (td (input (@ (!permute (value "") (type "password") (name "new-pw"))))))
		 (tr (th "新パスワード(確認)")
		     (td (input (@ (!permute (value "") (type "password") (name "new-again-pw")))))))
		(input (@ (!permute (value "変更") (type "submit") (name "submit"))))
		(p (@ (class "warning")) "旧パスワードが不正です"))
	 ?*
	 )
        (call-worker/gsid->sxml w
			       '()
			       '(("old-pw" "badsea") ("new-pw" "newsea") ("new-again-pw" "newsea"))
			       '(// form))
        (make-match&pick w))

(test* "kagoiri-musume change password with good password"
       `(html
	 ,*head*
	 (body
	  (div ?@
           (h1 ?@ ?_)
           (a ?@ "トップ")
           (a ?@ "システム管理")
           (a ?@ "ユニット一覧")
           (a (@ (href ?&)) "パスワード変更")
           (span " Now login:" (a ?@ "cut-sea"))
           (a ?@ "Logout")
           (form ?@ "検索:" (input ?@)))
	  ,(*make-body*
            (div ?@ (h3 "cut-sea さんのパスワードを変更しました")))
          ,*footer*))
       (call-worker/gsid w
			 '()
			 '(("old-pw" "cutsea") ("new-pw" "goodsea") ("new-again-pw" "goodsea"))
			 (lambda (h b) (tree->string b)))
       (make-match&pick w))

(test* "kagoiri-musume change password again"
       '(*TOP*
	 ?*
	 (form (@ (action ?&) ?*)
		(table
		 (tr (th "旧パスワード")
		     (td (input (@ (!permute (value "") (type "password") (name "old-pw") (id "focus"))))))
		 (tr (th "新パスワード")
		     (td (input (@ (!permute (value "") (type "password") (name "new-pw"))))))
		 (tr (th "新パスワード(確認)")
		     (td (input (@ (!permute (value "") (type "password") (name "new-again-pw")))))))
		(input (@ (!permute (value "変更") (type "submit") (name "submit"))))
		(p (@ (class "warning"))))
	 ?*
	 )
        (call-worker/gsid->sxml w
			       '()
			       '(("old-pw" "badsea") ("new-pw" "newsea") ("new-again-pw" "newsea"))
			       '(// form))
        (make-match&pick w))

(test* "kagoiri-musume change password back to original password"
       '(*TOP*
         ?*
	 (div ?@ (h3 "cut-sea さんのパスワードを変更しました"))
         ?*)
       (call-worker/gsid->sxml w
			       '()
			       '(("old-pw" "goodsea") ("new-pw" "cutsea") ("new-again-pw" "cutsea"))
			       '(// div))
       (make-match&pick w))


 )

(test-end)
