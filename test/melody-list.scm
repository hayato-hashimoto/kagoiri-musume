;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: melody-list.scm,v 1.5 2006/03/05 16:58:30 cut-sea Exp $

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

(test-start "kagoiri-musume melody list check")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (login w :top '?&)

 (make-musume w :view '?&melody-list)

 (set-gsid w 'melody-list)

 (test-section "melody list")

 (test* "ナビゲーション"
        '(*TOP*
          (div ?@
               (a (@ (href ?_)) "トップ")
               " > "
               (a (@ (href ?_))
                  "籠入娘。Test Proj.")
               " > "
               (span (@ (class "current"))
                     (a (@ (href ?_))
                        "テストな娘。"))))
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
                                //menu)
        test-sxml-match?)

 (test* "ブックマークボタン"
        '(*TOP*
          (a ?@
             "ブックマークに追加"))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (a (@ (equal? (id "bookmark-button"))))))
        test-sxml-match?)

 (test* "前後移動リンク"
        '(*TOP*
          (div (a (@ (onclick "copy_search(this)")
                     (href ?_)
                     (class "clickable"))
                  "<<")
               (a (@ (onclick "copy_search(this)")
                     (href ?_)
                     (class "clickable"))
                  ">>")))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                `(,@//body (div 2)))
        test-sxml-match?)

 (test* "ページタイトル"
        '(*TOP*
          (h3 "籠入娘。Test Proj. - 1：テストな娘。 - OPEN"))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                `(,@//body h3))
        test-sxml-match?)


 (test* "投稿フォーム"
        '(*TOP*
          (form (@ (method "POST")
                   (id "mainedit")
                   (enctype "multipart/form-data")
                   (action ?_))
                (table ?*)))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                `(// (form (@ (equal? (id "mainedit"))))))
        test-sxml-match?)


 (test* "フィールド選択エリア"
        '(*TOP*
          (table (tr (th "優先度")
                     (th "ステータス")
                     (th "タイプ")
                     (th "カテゴリ")
                     (th "アサイン"))
                 (tr (td (select
                          (@ (name "priority"))
                          (option
                           (@ (value "normal"))
                           "普通")
                          (option
                           (@ (value "low"))
                           "低")
                          (option
                           (@ (value "high")
                              (selected "true"))
                           "高")))
                     (td (select
                          (@ (name "status"))
                          (option
                           (@ (value "open")
                              (selected "true"))
                           "OPEN")
                          (option
                           (@ (value "completed"))
                           "COMPLETED")))
                     (td (select
                          (@ (name "type"))
                          (option
                           (@ (value "bug"))
                           "バグ")
                          (option
                           (@ (value "task")
                              (selected "true"))
                           "タスク")
                          (option
                           (@ (value "request"))
                           "変更要望")))
                     (td (select
                          (@ (name "category"))
                          (option
                           (@ (value "global")
                              (selected "true"))
                           "全体")
                          (option
                           (@ (value "section"))
                           "セクション")))
                     (td (select
                          (@ (name "assign"))
                          (option (@ (value "   ")))
                          (option
                           (@ (value "cut-sea")
                              (selected "true"))
                           "cut-sea")))
                     (td (input (@ (value "コミット")
                                   (type "submit")))))))
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

 (test* "内容入力エリア"
        '(*TOP* (table (@ (class "extension"))
              (tr (td)
                  (td (span (@ (onclick ?_))
                            (span (@ (class "clickable")) "案件へのリンク"))))
              (tr (td "内容")
                  (td (@ (id "melody-text")) 
		      (textarea
		       (@ (type "text")
			  (rows "10")
			  (name "melody")
			  (id "focus")
			  (cols "80")))))
              (tr (td "ファイル")
                  (td (input (@ (type "file") (name "file")))))))
	
        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (form (@ (equal? (id "mainedit")))) table ((// table) 3)))
        test-sxml-match?)

 (test* "参照リンクエリア"
        '(*TOP*
          (table (@ (id "links-table"))
                    (tr (th "リンク先") (th "リンク元"))
                    (tr (td (ul)) (td (ul)))))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (table (@ (equal? (id "links-table"))))))
        test-sxml-match?)

 (test* "投稿表示エリア"
        '(*TOP*
          (dl (@ (id ?_))
              (dt (span (@ (class "song-no")) "♪1.")
                  (span (@ (class "song-time")) ?_)
                  (span (@ (class "song-fan")) "[cut-sea]")
		  (a (@ (!permute (onClick ?_) (href ?_))) "[輪唱]")
                  (a (@ (onClick "return confirm('本当に削除しますか？')?true:false")
                        (href ?_))
                     "[削除]"))
              (dd (p (@ (class "rectangle")) "テストをする必要があるのでするなり"))))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                `(,@//body dl))
        test-sxml-match?)
 )

(test-end)
