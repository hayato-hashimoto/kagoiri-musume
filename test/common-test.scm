;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: common-test.scm,v 1.9 2006/12/14 06:35:56 cut-sea Exp $

;; コンテンツ作成用テストライブラリ

(define-module common-test
  (use srfi-13)
  (use gauche.test)
  (use gauche.parameter)
  (use gauche.collection)
  (use file.util)
  (use text.tree)
  (use sxml.ssax)
  (use sxml.sxpath)
  (use kahua)
  (use kahua.test.xml)
  (use kahua.test.worker)
  (export  //body
           //page-title
           //navigation
           //navigation-action
           //menu
           //header-action
           login
           make-unit
           make-musume
           current-worker
           call-worker-test*
           with-worker
           ))

(select-module common-test)

(define current-worker (make-parameter #f))

(define (call-worker-test* name . options)
  (let-keywords* options ((gsid   :gsid #f)
                          (node   :node '())
                          (header :header '())
                          (body   :body '())
                          (query :sxpath '())
                          (worker :worker (current-worker))
                          (redirect :redirect #f)
                          )
    (when (or (not gsid)
              (begin
                (set-gsid worker gsid)
                (hash-table-exists? (ref worker 'sessions) (symbol->string gsid))))

      (when redirect
        (test (string-append name "(redirect)")
              '(*TOP* (!contain (Status "302 Found")
                                (Location ?&)))
              (lambda ()
                (call-worker/gsid
                 worker
                 header body
                 header->sxml))
              (make-match&pick worker)))

      (test name node
            (lambda ()
              (call-worker/gsid->sxml
               worker
               (if redirect '() header)
               (if redirect '() body)
               query))
            (if (find (lambda (attr) (string-prefix? "?&"
                                         (x->string (cadr attr))))
                         ((sxpath '(// @ (or@ href action))) node))
                (make-match&pick worker)
              test-sxml-match?)))))

(define $with-worker with-worker)

(define-syntax with-worker
  (syntax-rules ()
    ((_ (w command) body ...)
     ($with-worker (w command)
                   (current-worker w)
                   body ...))))

(define-syntax define-sxpath
  (syntax-rules ()
    ((_ name sxpath1)
     (define (name . sxpath)
       (let1 child (get-optional sxpath '())
         (append sxpath1 child))))))

(define-sxpath //body
  '(// (div (@ (equal? (id "body"))))))

(define-sxpath //page-title
  (//body '(h2)))

(define-sxpath //navigation
  '(// (div (@ (equal? (id "navigation"))))))

(define-sxpath //navigation-action
  '(// (* (@ (equal? (id "navigation-action"))))))

(define-sxpath //menu
  '(// (ul (@ (equal? (class "menu"))))))

(define-sxpath //header-action
  '(// (div (@ (equal? (id "header-action"))))))



(define (login w . options)
  (let-keywords* options ((top :top '?&))

    (test-section "common-test.scm: login")

    (reset-gsid w)

    (call-worker-test* "login: ログイン画面"

                       :node `(*TOP*
                               (form (@ (method "POST")
                                        (action ,top))
                                     ?*))

                       :sxpath (//body '(form))
                       :pick #t)))

(define (make-unit w . options)
  (let-keywords* options ((view :view '?*)
                          (edit :edit '?*))

    (test-section "common-test.scm: make-unit")

    (call-worker-test* "make-unit: ユニット作成ページへ移動"

                    :node '(*TOP*
                            (!contain
                             (a (@ (href ?&)
                                   ?*)
                                "プロジェクト追加")))

                    :body '(("name" "cut-sea") ("pass" "cutsea"))
                    :sxpath (//navigation-action '(// a)))

    (call-worker-test* "make-unit: ユニット作成ページ"

                       :node '(*TOP*
                               (form (@ (onsubmit "return submitCreateUnit(this)")
                                        (method "POST")
                                        (action ?&))
                                     ?*
                                     (input (@ (value "新ユニット結成") (type "submit")))))

                       :sxpath (//body '(form)))

    (call-worker-test* "make-unit: ユニット作成 サブミット&作成ユニットの確認"

                       :node `(*TOP*
                               (tr ?@
                                   (td ?@ (a (@ (href ,view)) "籠入娘。Test Proj.") " (0)")
                                   (td "籠入娘。のバグトラッキングを行うユニット")
                                   (td (span ?@
                                             (span ?@ "1人"))
                                       (div ?@ (div "cut-sea")))
                                   (td (a ?@ "○"))
                                   (td ?@ (span ?@ (a (@ (href ,edit)) "設定")))))

                       :body '(("priority" "normal" "low" "high")
                               ("status" "open" "completed")
                               ("type" "bug" "task" "request")
                               ("category" "global" "section")
                               ("name" "籠入娘。Test Proj.")
                               ("desc" "籠入娘。のバグトラッキングを行うユニット")
                               ("fans" "cut-sea"))

                       :sxpath (//body '(table tbody tr))

                       :redirect #t)
    ))

(define (make-musume w . options)
  (let-keywords* options ((unit-view :unit-view #f)
                          (view :view #f))

    (test-section "common-test.scm: make-musume")

    (make-unit w :view (or unit-view '?&))

    (when unit-view
      (set-gsid w (string-drop (symbol->string unit-view) 2)))

    (call-worker-test* "make-musume: 案件作成リンク"

                       :node '(*TOP*
                               (!contain
                                (a (@ (href ?&)
                                      ?*)
                                   "案件追加")))

                       :sxpath (//navigation-action '(// a)))

    (test* "make-musume: フォーム"
           '(*TOP*
             (form (@ ?*
                      (action ?&))
                   ?*))
           (call-worker/gsid->sxml w
                                   '()
                                   '()
                                   '(// (form (@ (equal? (id "mainedit"))))))
           (make-match&pick w))

    (test* "make-musume: 案件作成 サブミット"
           `(*TOP*
             (!contain (Status "302 Found")
                       (Location ,(or view '?&))))
           (call-worker/gsid
            w
            '()
            '(("priority" "high")
              ("status" "open")
              ("type" "task")
              ("category" "global")
              ("name" "テストな娘。")
              ("melody" "テストをする必要があるのでするなり")
              ("assign" "cut-sea"))
            header->sxml)
           (make-match&pick w))

    (when view
      (set-gsid w (string-drop (symbol->string view) 2)))

    (test* "make-musume: 新規案件のmelodyリストページ"
           '(*TOP*
             (h2 "籠入娘。Test Proj. - 1：テストな娘。 - OPEN"))
           (call-worker/gsid->sxml w
                                   '()
                                   '()
                                   (//body '(h2)))
           test-sxml-match?)


    ))
