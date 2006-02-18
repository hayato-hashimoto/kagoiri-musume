;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: unit-list.scm,v 1.2 2006/02/18 14:14:32 shibata Exp $

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
                (a (@ (href "kahua.cgi/kagoiri-musume/")) "トップ")))
        (call-worker/gsid->sxml w
                                '()
                                '(("name" "cut-sea") ("pass" "cutsea"))
                                '(// (div (@ (equal? (id "navigation")))) *))
        test-sxml-match?)

 (test* "ユニット一覧"
        '(*TOP*
          ?*
          (h2 "ユニット一覧")
          (table (@ (class "listing"))
                 (thead (tr (th)
                            (th "ユニット名")
                            (th "概要")
                            (th "ファン")
                            (th "購読")))
                 (tbody))
          ?*)
        (call-worker/gsid->sxml w
                                '()
                                '(("name" "cut-sea") ("pass" "cutsea"))
                                '(// (div (@ (equal? (id "body")))) *))
        test-sxml-match?)

 (test* "新ユニット作成フォーム"
        '(*TOP*
          (form (@ (onsubmit "return submitForm(this)")
                   (method "POST")
                   (action ?&unit-list))
                ?*
                (input (@ (value "新ユニット結成") (type "submit")))))
        (call-worker/gsid->sxml w
                                '()
                                '(("name" "cut-sea") ("pass" "cutsea"))
                                '(// (div (@ (equal? (id "body")))) form))
        (make-match&pick w))

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
                          (option (@ (value "high")) "高")
                          (option (@ (value "low")) "低")
                          (option (@ (value "normal")) "普通")
                          (option (@ (value "super")) "超高")))
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
                          (option (@ (value "completed")) "COMPLETED")
                          (option (@ (value "on-hold")) "ON HOLD")
                          (option (@ (value "open")) "OPEN")
                          (option (@ (value "rejected")) "REJECTED")
                          (option (@ (value "taken")) "TAKEN")))
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
                          (option (@ (value "bug")) "バグ")
                          (option (@ (value "discuss")) "議論")
                          (option (@ (value "etc")) "その他")
                          (option (@ (value "report")) "報告")
                          (option (@ (value "request")) "変更要望")
                          (option (@ (value "task")) "タスク")
                          (option (@ (value "term")) "用語")))
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
                          (option (@ (value "global")) "全体")
                          (option (@ (value "infra")) "インフラ")
                          (option (@ (value "master")) "マスタ")
                          (option (@ (value "section")) "セクション")))
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
          (table (tr (td "ユニット名" (span (@ (class "warning")) "(※)"))
                     (td (textarea
                          (@ (type "text")
                             (rows "1")
                             (name "name")
                             (cols "32")))))
                 (tr (td "概要")
                     (td (@ (colspan "2"))
                         (textarea
                          (@ (type "text")
                             (rows "10")
                             (name "desc")
                             (cols "80")))))
                 (tr (@ (align "left"))
                     (td "ファン" (span (@ (class "warning")) "(※)"))
                     (td (table (tr (td (select
                                         (@ (size "5")
                                            (name "fans")
                                            (multiple "true")
                                            (id "fans"))
                                         (option (@ (value "   ")))
                                         (option (@ (value "cut-sea")) "cut-sea")
                                         (option (@ (value "guest")) "guest")
                                         (option (@ (value "kago")) "kago")))
                                    (td (div (@ (onclick
                                                 "up_select(this, 'fans')")
                                                (class "clickable"))
                                             "↑")
                                        (div (@ (onclick
                                                 "down_select(this, 'fans')")
                                                (class "clickable"))
                                             "↓"))))))
                 (tr (td "通知アドレス")
                     (td (textarea
                          (@ (type "text")
                             (rows "2")
                             (name "notify-addresses")
                             (cols "20"))))))
          )
        (call-worker/gsid->sxml w
                                '()
                                '(("name" "cut-sea") ("pass" "cutsea"))
                                '(// (div (@ (equal? (id "body")))) form (table 2)))
        test-sxml-match?)
 )

(test-end)