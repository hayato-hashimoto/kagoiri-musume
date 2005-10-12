;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: initdb.scm,v 1.7 2005/10/12 17:49:01 cut-sea Exp $
;;
;; include
(use kahua)
(use kahua-server)

(load "kagoiri-musume/version.kahua")
(load "kagoiri-musume/local.kahua")
(load "kagoiri-musume/class.kahua")

;;
(define (main args)
  (with-db (db *kagoiri-musume-database-name*)
    (add-fan "   " "anybody" "anybody@kagoiri.org")
    (add-fan "kago" "kago" "cut-sea@kagoiri.org" 'admin 'user)
    (add-fan "cut-sea" "cutsea" "cut-sea@kagoiri.org" 'user)

    (make <priority> :code "normal" :disp-name "普通" :level 3)
    (make <priority> :code "low" :disp-name "低" :level 2)
    (make <priority> :code "high" :disp-name "高" :level 4)
    (make <priority> :code "super" :disp-name "超高" :level 5)

    (make <status> :code "open" :disp-name "OPEN")
    (make <status> :code "completed" :disp-name "COMPLETED")
    (make <status> :code "on-hold" :disp-name "ON HOLD")
    (make <status> :code "taken" :disp-name "TAKEN")
    (make <status> :code "rejected" :disp-name "REJECTED")

    (make <type> :code "bug" :disp-name "バグ")
    (make <type> :code "task" :disp-name "タスク")
    (make <type> :code "request" :disp-name "変更要望")
    (make <type> :code "discuss" :disp-name "議論")
    (make <type> :code "report" :disp-name "報告")
    (make <type> :code "term" :disp-name "用語")
    (make <type> :code "etc" :disp-name "その他")

    (make <category> :code "section" :disp-name "セクション")
    (make <category> :code "global" :disp-name "全体")
    (make <category> :code "infra" :disp-name "インフラ")
    (make <category> :code "master" :disp-name "マスタ")
    )
  (format #t "done~%")
  )

