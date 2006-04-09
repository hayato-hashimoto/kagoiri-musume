;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: musume-list.scm,v 1.6 2006/04/09 10:34:21 shibata Exp $

(load "common.scm")

(test-start "kagoiri-musume musume list check")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (login w :top '?&)

 (make-unit w :view '?&musume-list)

 (set-gsid w 'musume-list)

 (test* "ナビゲーション"
        '(*TOP*
          (div ?@
               (a ?@ "トップ")
               " > "
               (span (@ (class "current"))
                     (a ?@
                        "籠入娘。Test Proj."))))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                (//navigation))
        test-sxml-match?)

 (test* "メニュー"
        '(*TOP*
          (!contain
           (a ?@
              "案件追加")
           (a ?@
              "一覧")
           (a ?@
              "設定")))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                (//navigation-action '(// a)))
        test-sxml-match?)

 (test* "ユニット内検索"
        '(*TOP*
          (div ?@
               (form (@ (method "POST")
                        (action ?_))
                 (input (@ (value ?_)
                           (type "hidden")
                           (name "unit-id")))
                 "ユニット内検索:"
                 (input (@ (type "text")
                           (size "10")
                           (onKeyUp "delay_search(this.value)")
                           (onKeyDown "search_onKeyDown(event)")
                           (name "word")
                           (id "focus")))
                 (input (@ (value "検索") (type "submit"))))))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (div (@ (equal? (id "search-box"))))))
        test-sxml-match?)

 (test* "ページタイトル"
        '(*TOP*
          (h2 "籠入娘。Test Proj. - 娘。一覧"))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                (//page-title))
        test-sxml-match?)


 (test-section "案件一覧テーブル")

 (test* "フォーム"
        '(*TOP*
          (form (@ (method "POST")
                   (id "filtering_form")
                   (action ?_))
                (table ?*)
                ))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (form (@ (equal? (id "filtering_form"))))))
        test-sxml-match?)

 (test* "フィルタ操作テーブル"
        '(*TOP*
          (table (@ (class "table-filter"))
                   (tr (@ (onclick "toggle_select_mode(event)"))
                       (th (span (@ (class "clickable")) "優先度"))
                       (th (span (@ (class "clickable")) "ステータス"))
                       (th (span (@ (class "clickable")) "タイプ"))
                       (th (span (@ (class "clickable")) "カテゴリ"))
                       (th (span (@ (class "clickable")) "アサイン"))
                       (th "表示上限"))
                   (tr (@ (valign "top"))
                       (td (select
                             (@ (onchange
                                  "filter_table(this, 'musume_list', '全て')")
                                (name "priority"))
                             (option (@ (value "*all*")) "全て")
                             (option (@ (value "normal")) "普通")
                             (option (@ (value "low")) "低")
                             (option (@ (value "high")) "高")))
                       (td (select
                             (@ (onchange
                                  "filter_table(this, 'musume_list', '全て')")
                                (name "status"))
                             (option (@ (value "*all*")) "全て")
                             (option (@ (value "open")) "OPEN")
                             (option (@ (value "completed")) "COMPLETED")))
                       (td (select
                             (@ (onchange
                                  "filter_table(this, 'musume_list', '全て')")
                                (name "type"))
                             (option (@ (value "*all*")) "全て")
                             (option (@ (value "bug")) "バグ")
                             (option (@ (value "task")) "タスク")
                             (option (@ (value "request")) "変更要望")))
                       (td (select
                             (@ (onchange
                                  "filter_table(this, 'musume_list', '全て')")
                                (name "category"))
                             (option (@ (value "*all*")) "全て")
                             (option (@ (value "global")) "全体")
                             (option (@ (value "section")) "セクション")))
                       (td (select
                             (@ (onchange
                                  "filter_table(this, 'musume_list', '全て')")
                                (name "assign"))
                             (option (@ (value "*all*")) "全て")
                             (option (@ (value "   ")))
                             (option (@ (value "cut-sea")) "cut-sea")))
                       (td (select
                             (@ (name "limit"))
                             (option (@ (value "")))
                             (option (@ (value "20")) "20")
                             (option (@ (value "50")) "50")
                             (option
                               (@ (value "200") (selected "true"))
                               "200")
                             (option (@ (value "500")) "500")
                             (option (@ (value "1000")) "1000")))
                       (td (noscript
                             (input (@ (value "絞り込み")
                                       (type "submit")
                                       (name "submit"))))))))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (table (@ (equal? (class "table-filter"))))))
        test-sxml-match?)


 (test* "フィルタ操作テーブル"
        '(*TOP*
          (table (@ (id "musume_list") (class "listing"))
                   (thead (span (@ (id "musume_count")))
                          "萌えられる娘。がいません(T^T)"
                          (div (@ (id "status-num"))
                               (span (a (@ (onclick
                                             "return update_status(this)")
                                           (href ?_))
                                        "OPEN")
                                     "(0) ")
                               (span (a (@ (onclick
                                             "return update_status(this)")
                                           (href ?_))
                                        "COMPLETED")
                                     "(0) "))
                          (tr (@ (onclick "sort_table(event);return false"))
                              (th)
                              (th (@ (value "no")) "No.")
                              (th (@ (value "title")) "タイトル")
                              (th (@ (value "priority")) "優先度")
                              (th (@ (value "status")) "ステータス")
                              (th (@ (value "type")) "タイプ")
                              (th (@ (value "category")) "カテゴリ")
                              (th (@ (value "assign")) "アサイン")
                              (th (@ (value "ltime")) "期限")
                              (th (@ (value "ctime")) "登録日")
                              (th (@ (value "mtime")) "更新日")))
                   (tbody)))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (table (@ (equal? (id "musume_list"))))))
        test-sxml-match?)
 )

(test-end)