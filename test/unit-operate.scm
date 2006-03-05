;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: unit-operate.scm,v 1.4 2006/03/05 06:06:49 shibata Exp $

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

(test-start "kagoiri-musume operate unit")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (login w :top '?&unit-list)

 (set-gsid w 'unit-list)

 (make-unit w :edit '?&unit-edit)

 (test-section "ユニット設定")

 (set-gsid w 'unit-edit)

 (test* "ページタイトル"
	`(*TOP*
          "『籠入娘。Test Proj.』ユニット設定")
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
         '(// (div (@ (equal? (id "body")))) h2 *text*))
        (make-match&pick w))

 (set-gsid w 'unit-edit)

 (test* "フォーム"
	`(*TOP*
          (form (@ (onsubmit "return submitCreateUnit(this)")
                   (method "POST")
                   (action ?&unit-edit-submit))
                ?*
                (input (@ (value "確定") (type "submit")))))
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
         '(// (div (@ (equal? (id "body")))) form))
        (make-match&pick w))

 (set-gsid w 'unit-edit)

 (test* "フィールド選択(現在の値が選択されているか)"
	`(*TOP*
          (table (tr ?*)
                 (tr (td (select ?@
                          (option (@ (value "normal") (selected "#t")) "普通")
                          (option (@ (value "low") (selected "#t")) "低")
                          (option (@ (value "high") (selected "#t")) "高")
                          (option (@ (value "super")) "超高")))
                     (td ?*)
                     (td (select ?@
                          (option (@ (value "open") (selected "#t")) "OPEN")
                          (option (@ (value "completed") (selected "#t")) "COMPLETED")
                          (option (@ (value "on-hold")) "ON HOLD")
                          (option (@ (value "rejected")) "REJECTED")
                          (option (@ (value "taken")) "TAKEN")))
                     (td ?*)
                     (td (select ?@
                          (option (@ (value "bug") (selected "#t")) "バグ")
                          (option (@ (value "task") (selected "#t")) "タスク")
                          (option (@ (value "request") (selected "#t")) "変更要望")
                          (option (@ (value "discuss")) "議論")
                          (option (@ (value "etc")) "その他")
                          (option (@ (value "report")) "報告")
                          (option (@ (value "term")) "用語")))
                     (td ?*)
                     (td (select ?@
                          (option (@ (value "global") (selected "#t")) "全体")
                          (option (@ (value "section") (selected "#t")) "セクション")
                          (option (@ (value "infra")) "インフラ")
                          (option (@ (value "master")) "マスタ")))
                     (td ?*))))
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
         '(// (div (@ (equal? (id "body")))) form (table 1)))
        test-sxml-match?)

 (set-gsid w 'unit-edit)

 (test* "ユニット名・概要・ファン選択(現在の値が選択されているか)"
        '(*TOP*
          (table (tr (td "ユニット名" ?*)
                     (td (textarea ?@
                                   "籠入娘。Test Proj.")))
                 (tr (td "概要")
                     (td ?@
                         (textarea ?@
                                   "籠入娘。のバグトラッキングを行うユニット")))
                 (tr ?@
                     (td "ファン" ?*)
                     (td (table (tr (td (@ (id "memberlistblock"))
                                        (ul (@ (id "memberlist")
                                               (class "userlist"))
                                            (li (@ (value "   ")))
                                            (li (@ (value "cut-sea")) "cut-sea")))
                                    (td "<=")
                                    (td (@ (id "allmemberlistblock"))
                                        "検索:"
                                        (input (@ (type "text")
                                                  (onkeyup
                                                   "filter_member(this.value)")
                                                  (id "membersearch")))
                                        (ul (@ (id "allmemberlist")
                                               (class "userlist"))
                                            (li (@ (value "guest")) "guest")
                                            (li (@ (value "kago")) "kago")))
                                    (script
                                     (@ (type "text/javascript"))
                                     ?_)))))
                 (tr (td "通知アドレス")
                     (td (textarea ?@))))
          )
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
         '(// (div (@ (equal? (id "body")))) form (table 2)))
        test-sxml-match?)

 (set-gsid w 'unit-edit-submit)

 (test/send&pick "ユニット設定変更"
                 w
                 '(("priority" "normal" "super" "high")
		   ("status" "open" "on-hold" "completed")
		   ("type" "task" "request" "discuss")
		   ("category" "master" "infra" "global" "section")
		   ("name" "籠入娘。Test Project.")
		   ("desc" "籠入娘。のバグトラッキングとタスクマネージメントを行うユニット")
		   ("fans" "   " "cut-sea" "guest")))

 (test* "ユニット設定変更確認"
	`(*TOP*
          (tr ?@
              (td (a ?@ "設定"))
              (td (a (@ (href ?&) ?*) "籠入娘。Test Project.") " (0)")
              (td "籠入娘。のバグトラッキングとタスクマネージメントを行うユニット")
              (td "cut-sea , guest")
              (td (a ?@ "○")))
          )
        (call-worker/gsid->sxml
	 w
	 '()
	 '()
         '(// (div (@ (equal? (id "body")))) table tbody tr))
        (make-match&pick w))
 )

(test-end)