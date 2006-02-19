;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: musume-operate.scm,v 1.2 2006/02/19 09:45:12 shibata Exp $

(use gauche.test)
(use gauche.collection)
(use file.util)
(use text.tree)
(use sxml.ssax)
(use sxml.sxpath)
(use kahua)
(use kahua.test.xml)
(use kahua.test.worker)

(use common-test)

(load "common.scm")

(test-start "kagoiri-musume operate musume")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (login w :top '?&)

 (make-musume w :unit-view '?&musume-list)

 (set-gsid w 'musume-list)

 (test* "案件作成リンク"
        '(*TOP*
          ?*
          (li (a (@ (href ?&musume-new)
                    ?*)
                 "新しい娘。"))
          ?*)
        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (ul (@ (equal? (class "menu")))) *)
                                )
        (make-match&pick w))

 (test-section "案件作成ページ")

 (set-gsid w 'musume-new)

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
                                //navigation)
        test-sxml-match?)

 (test* "メニュー"
        '(*TOP*
          (ul ?@
              (li (a (@ (href ?_)
                        (class "clickable"))
                     "新しい娘。"))))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (ul (@ (equal? (class "menu"))))))
        test-sxml-match?)

 (test* "ページタイトル"
        '(*TOP*
          (h2 "籠入娘。Test Proj. - 新しい娘。"))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                //page-title)
        test-sxml-match?)

 (test* "フォーム"
        '(*TOP*
          (form (@ (onsubmit "return false;")
                   (method "POST")
                   (id "mainedit")
                   (enctype "multipart/form-data")
                   (action ?&musume-new-submit))
                (table ?*)))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (form (@ (equal? (id "mainedit"))))))
        (make-match&pick w))

 (set-gsid w 'musume-new)

 (test* "フィールド選択エリア"
        '(*TOP*
          (table (tr (th "優先度")
                     (th "ステータス")
                     (th "タイプ")
                     (th "カテゴリ")
                     (th "アサイン"))
                 (tr (td (select
                          (@ (name "priority"))
                          (option (@ (value "normal")) "普通")
                          (option (@ (value "low")) "低")
                          (option (@ (value "high")) "高")))
                     (td (select
                          (@ (name "status"))
                          (option (@ (value "open")) "OPEN")
                          (option
                           (@ (value "completed"))
                           "COMPLETED")))
                     (td (select
                          (@ (name "type"))
                          (option (@ (value "bug")) "バグ")
                          (option (@ (value "task")) "タスク")
                          (option
                           (@ (value "request"))
                           "変更要望")))
                     (td (select
                          (@ (name "category"))
                          (option (@ (value "global")) "全体")
                          (option
                           (@ (value "section"))
                           "セクション")))
                     (td (select
                          (@ (name "assign"))
                          (option (@ (value "   ")))
                          (option
                           (@ (value "cut-sea"))
                           "cut-sea")))
                     (td (input (@ (value "新しい娘。加入")
                                   (type "button")
                                   (onclick "submit();")))))))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (form (@ (equal? (id "mainedit")))) table ((// table) 1)))
        test-sxml-match?)

 (test* "期限選択"
        '(*TOP*
          (table (@ (class "calendar"))
                 ?*))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (td (@ (equal? (id "limit-calendar")))) table))
        test-sxml-match?)

 (test* "タイトル・内容入力エリア"
        '(*TOP*
          (table (tr (td "タイトル"
                         (span (@ (class "warning")) "(※)"))
                     (td (input (@ (type "text")
                                   (size "80")
                                   (name "name")
                                   (id "focus")))))
                 (tr (td)
                     (td (span (@ (onclick ?_))
                               (span (@ (class "clickable"))
                                     "案件へのリンク"))))
                 (tr (td "内容")
                     (td (textarea
                          (@ (type "text")
                             (rows "20")
                             (name "melody")
                             (id "melody")
                             (cols "80")))))
                 (tr (td "ファイル")
                     (td (input (@ (type "file")
                                   (name "file")))
                         (input (@ (value "")
                                   (type "hidden")
                                   (name "filename")))))))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (form (@ (equal? (id "mainedit")))) table ((// table) 3)))
        test-sxml-match?)

 (test* "サブミットボタン"
        '(*TOP*
          (!repeat
           (input (@ (value "新しい娘。加入")
                     (type "button")
                     (onclick "submit();")))))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (input (@ (equal? (onclick "submit();"))))))
        test-sxml-match?)

 )

(test-end)