;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: melody-operate.scm,v 1.5 2006/03/08 12:58:58 cut-sea Exp $

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

(test-start "kagoiri-musume operate melody")

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

 (test-section "new melody")

 (test* "フォーム"
        '(*TOP*
          (form (@ (!contain (action ?&)))
                ?*))
        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (form (@ (equal? (id "mainedit"))))))
        (make-match&pick w))

 (test/send&pick "新しい投稿"
                 w
                 '(("priority" "super")
		   ("status" "completed")
		   ("type" "discuss")
		   ("category" "section")
		   ("melody" "クローズする")
		   ("assign" "   ")))

 (test* "ページタイトルの更新をチェック"
        '(*TOP*
          (h3 "籠入娘。Test Proj. - 1：テストな娘。 - COMPLETED"))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                `(,@//body h3))
        test-sxml-match?)

 (test* "フィールド選択エリアの更新をチェック"
        '(*TOP*
          (table (tr ?*)
                 (tr (td (select
                          (@ (name "priority"))
                          (option (@ (value "normal")) "普通")
                          (option (@ (value "low")) "低")
                          (option (@ (value "high")) "高")))
                     (td (select
                          (@ (name "status"))
                          (option (@ (value "open")) "OPEN")
                          (option
                           (@ (value "completed") (selected "true"))
                           "COMPLETED")))
                     (td (select
                          (@ (name "type"))
                          (option (@ (value "bug")) "バグ")
                          (option (@ (value "task")) "タスク")
                          (option (@ (value "request")) "変更要望")))
                     (td (select
                          (@ (name "category"))
                          (option (@ (value "global")) "全体")
                          (option
                           (@ (value "section") (selected "true"))
                           "セクション")))
                     (td (select
                          (@ (name "assign"))
                          (option (@ (value "   ") (selected "true")))
                          (option (@ (value "cut-sea")) "cut-sea")))
                     (td ?*))))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                '(// (form (@ (equal? (id "mainedit")))) table ((// table) 1)))
        test-sxml-match?)

 (test* "新規投稿をチェック"
        '(*TOP*
          (dl (@ (id ?_))
              (dt (span (@ (class "song-no")) "♪2.")
                  (span (@ (class "song-time")) ?_)
                  (span (@ (class "song-fan")) "[cut-sea]")
		  (a (@ (!permute (onclick ?_) (href ?_))) "[輪唱]")
                  (a (@ (onClick "return confirm('本当に削除しますか？')?true:false")
                        (href ?_)) "[削除]"))
              (dd (p (@ (class "rectangle")) "クローズする")))
          (dl ?*))

        (call-worker/gsid->sxml w
                                '()
                                '()
                                `(,@//body dl))
        test-sxml-match?)
 )


(test-end)