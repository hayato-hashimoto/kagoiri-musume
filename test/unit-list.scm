;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: unit-list.scm,v 1.17 2007/04/15 12:44:26 shibata Exp $

(load "common.scm")

(test-start "kagoiri-musume unit-list enter check")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (test-section "kagoiri-musume unit-list link click without login")

 (test* "ログイン画面"
        '(*TOP*
          (h1 "籠入娘。へようこそ！")
          (h3 "ユニット一覧は一般ユーザアカウントが必要です")
          (form (@ (method "POST")
                   (action ?&unit-list))
                ?*))
        (call-worker/gsid->sxml w '() '() '(// (div (@ (equal? (id "body")))) *))
        (make-match&pick w))

 (set-gsid w 'unit-list)

 (test-section "kagoiri-musume unit-list link click with login")

 (test* "ナビゲーション"
        '(*TOP*
          (span (@ (class "current"))
                (a (@ (href (!or "/kahua.cgi/kagoiri-musume/"
				 "/kahua.cgi/kagoiri-musume"))) "トップ")))
        (call-worker/gsid->sxml w
                                '()
                                '(("name" "cut-sea") ("pass" "cutsea"))
                                '(// (div (@ (equal? (id "navigation")))) *))
        test-sxml-match?)

 (test* "ユニット一覧"
        '(*TOP*
	  (!contain
	   (!seq
	    (h2 "ユニット一覧")
	    (table (@ (class "listing"))
		   (thead (tr (th "ユニット名")
			      (th "概要")
			      (th (@ (nowrap "nowrap")) "ファン")
			      (th "購読")
			      (th)))
		   (tbody)))))
        (call-worker/gsid->sxml w
                                '()
                                '(("name" "cut-sea") ("pass" "cutsea"))
                                '(// (div (@ (equal? (id "body")))) *))
        test-sxml-match?)

 (call-worker-test* "ユニット追加ページへ移動"

                    :node '(*TOP*
                            (!contain
                             (a (@ (href ?&))
                                "ユニット結成")))

                    :sxpath (//navigation-action '(// a))
                    :body '(("name" "cut-sea") ("pass" "cutsea")))

 (test* "新ユニット作成フォーム"
        '(*TOP*
          (form (@ (onsubmit "return submitCreateUnit(this)")
                   (method "POST")
                   (action ?_))
                ?*
                (input (@ (value "新ユニット結成") (type "submit")))))
        (call-worker/gsid->sxml w
                                '()
                                '(("name" "cut-sea") ("pass" "cutsea"))
                                '(// (div (@ (equal? (id "body")))) form))
        test-sxml-match?)

 (test* "フィールド選択"
        '(*TOP*
          (table (tr (@ (onclick "toggle_fulllist(event)"))
                     (th (@ (colspan "2"))
                         (span (@ (class "clickable")) "優先度"))
                     (th (@ (colspan "2"))
                         (span (@ (class "clickable")) "ステータス"))
                     (th (@ (colspan "2"))
                         (span (@ (class "clickable")) "タイプ"))
                     (th (@ (colspan "2"))
                         (span (@ (class "clickable")) "カテゴリ")))
                 (tr (td (select
                          (@ (size "5")
                             (name "priority")
                             (multiple "true")
                             (id "priority"))
			  (!permute
			   (option (@ (value "normal")) "普通")
			   (option (@ (value "low")) "低")
			   (option (@ (value "high")) "高")
			   (option (@ (value "super")) "超高"))))
                     (td (div (@ (onclick "up_select(this, 'priority')")
                                 (class "clickable"))
                              "↑")
                         (div (@ (onclick "down_select(this, 'priority')")
                                 (class "clickable"))
                              "↓"))
                     (td (select
                          (@ (size "5")
                             (name "status")
                             (multiple "true")
                             (id "status"))
			  (!permute
			   (option (@ (value "open")) "OPEN")
			   (option (@ (value "completed")) "COMPLETED")
			   (option (@ (value "on-hold")) "ON HOLD")
			   (option (@ (value "taken")) "TAKEN")
			   (option (@ (value "rejected")) "REJECTED"))))
                     (td (div (@ (onclick "up_select(this, 'status')")
                                 (class "clickable"))
                              "↑")
                         (div (@ (onclick "down_select(this, 'status')")
                                 (class "clickable"))
                              "↓"))
                     (td (select
                          (@ (size "5")
                             (name "type")
                             (multiple "true")
                             (id "type"))
			  (!permute
			   (option (@ (value "bug")) "バグ")
			   (option (@ (value "task")) "タスク")
			   (option (@ (value "request")) "変更要望")
			   (option (@ (value "discuss")) "議論")
			   (option (@ (value "report")) "報告")
			   (option (@ (value "term")) "用語")
			   (option (@ (value "etc")) "その他"))))
                     (td (div (@ (onclick "up_select(this, 'type')")
                                 (class "clickable"))
                              "↑")
                         (div (@ (onclick "down_select(this, 'type')")
                                 (class "clickable"))
                              "↓"))
                     (td (select
                          (@ (size "5")
                             (name "category")
                             (multiple "true")
                             (id "category"))
			  (!permute
			   (option (@ (value "section")) "セクション")
			   (option (@ (value "global")) "全体")
			   (option (@ (value "infra")) "インフラ")
			   (option (@ (value "master")) "マスタ"))))
                     (td (div (@ (onclick "up_select(this, 'category')")
                                 (class "clickable"))
                              "↑")
                         (div (@ (onclick "down_select(this, 'category')")
                                 (class "clickable"))
                              "↓"))))
          )
        (call-worker/gsid->sxml w
                                '()
                                '(("name" "cut-sea") ("pass" "cutsea"))
                                '(// (div (@ (equal? (id "body")))) form (table 1)))
        test-sxml-match?)


 (test* "ユニット名・概要・ファン選択"
        '(*TOP*
          (table (tr (td "非表示ステータス")
                     (td (select (@ (size "5") (name "non-display-statuss") (multiple "true"))
                                 (option (@ (value "open")) "OPEN")
                                 (option (@ (value "taken")) "TAKEN")
                                 (option (@ (value "on-hold")) "ON HOLD")
                                 (option (@ (value "completed")) "COMPLETED")
                                 (option (@ (value "rejected")) "REJECTED"))))
                 (tr (td "ユニット名" (span (@ (class "warning")) "(※)"))
                     (td (input
                          (@ (value "")
                             (type "text")
                             (size "80")
                             (name "name")))))
                 (tr (td "概要")
                     (td (@ (colspan "2"))
                         (textarea
                          (@ (type "text")
                             (rows "10")
                             (name "desc")
                             (cols "80")))))
                 (tr (@ (align "left"))
                     (td "ファン" (span (@ (class "warning")) "(※)"))
                     (td (table (tr (@ (id "user-tr"))
                                    (td (@ (id "memberlistblock"))
                                     (ul (@ (ondblclick ?_)
                                            (id "memberlist")
                                            (class "userlist"))))
                                 (td "<=")
                                 (td (@ (id "allmemberlistblock"))
                                     "検索:"
                                     (input (@ (type "text")
                                               (onkeyup
						"filter_member(this.value)")
                                               (id "membersearch")))
                                     (ul (@ (ondblclick ?_)
                                            (id "allmemberlist")
                                            (class "userlist"))
					 (!permute
					  (li (@ (user-name "kago")) "kago")
					  (li (@ (user-name "cut-sea")) "cut-sea"))))
                                 (td (@ (id "select-td")))
                                 (script
                                   (@ (type "text/javascript"))
                                   ?*)))))
                 (tr (td "通知アドレス")
                     (td (textarea
                          (@ (type "text")
                             (rows "2")
                             (name "notify-addresses")
                             (cols "20")))))
                 (tr (td "公開")
                  (td (input (@ (type "checkbox")
                                (name "public")
                                (id "public")))
                      (label (@ (for "public")) "公開"))))
          )
        (call-worker/gsid->sxml w
                                '()
                                '(("name" "cut-sea") ("pass" "cutsea"))
                                '(// (div (@ (equal? (id "body")))) form (table 2)))
        test-sxml-match?)
 )

(test-end)