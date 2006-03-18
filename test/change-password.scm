;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: change-password.scm,v 1.2 2006/03/18 12:21:16 shibata Exp $

(load "common.scm")

(test-start "kagoiri-musume change password check")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (login w)

 (call-worker-test* "マイページへ移動"

                    :node '(*TOP*
                            (!contain
                             (a (@ (href ?&)
                                   ?*)
                                "cut-sea")))

                    :body '(("name" "cut-sea") ("pass" "cutsea"))
                    :sxpath (//header-action '(// a)))

 (test-section "kagoiri-musume click change password")

 (call-worker-test* "パスワード変更リンク"

                    :node '(*TOP*
                            (!contain
                             (a (@ (href ?&) ?*) "パスワード変更")))
                    :sxpath (//navigation-action '(// a))
                    :redirect #t)

 (call-worker-test* "パスワード変更ページ"

                    :node '(*TOP*
                            (!contain
                             (h3 "cut-sea さんのパスワード変更")
                             (form (@ (method "POST")
                                      (action ?&change-pw))
                                   (table (tr (th "旧パスワード")
                                              (td (input (@ (value "")
                                                            (type "password")
                                                            (name "old-pw")
                                                            (id "focus")))))
                                          (tr (th "新パスワード")
                                              (td (input (@ (value "")
                                                            (type "password")
                                                            (name "new-pw")))))
                                          (tr (th "新パスワード(確認)")
                                              (td (input (@ (value "")
                                                            (type "password")
                                                            (name "new-again-pw"))))))
                                   (input (@ (value "変更") (type "submit") (name "submit")))
                                   (p (@ (class "warning"))))
                             ))

                    :sxpath (//body '(*)))

 (set-gsid w 'change-pw)

 (test* "新パスワード(確認)を間違える"
        '(*TOP*
          "新パスワードが不正です")
        (call-worker/gsid->sxml w
                                '()
                                '(("old-pw" "cutsea") ("new-pw" "badsea") ("new-again-pw" "newsea"))
                                '(// (p (@ (equal? (class "warning")))) *text*))
        (make-match&pick w))

 (set-gsid w 'change-pw)

 (test* "旧パスワードを間違える"
        '(*TOP*
          "旧パスワードが不正です")
        (call-worker/gsid->sxml w
                                '()
                                '(("old-pw" "badsea") ("new-pw" "newsea") ("new-again-pw" "newsea"))
                                '(// (p (@ (equal? (class "warning")))) *text*))
        test-sxml-match?)

 (set-gsid w 'change-pw)

 (test* "パスワードを変更"
        '(*TOP*
          "cut-sea さんのパスワードを変更しました")
        (call-worker/gsid->sxml w
                                '()
                                '(("old-pw" "cutsea") ("new-pw" "goodsea") ("new-again-pw" "goodsea"))
                                '(// (div (@ (equal? (class "msgbox")))) h3 *text*))
        test-sxml-match?)

 (set-gsid w 'change-pw)

 (test* "変更したパスワードでパスワードを変更"
        '(*TOP*
          "cut-sea さんのパスワードを変更しました")
        (call-worker/gsid->sxml w
                                '()
                                '(("old-pw" "goodsea") ("new-pw" "cutsea") ("new-again-pw" "cutsea"))
                                '(// (div (@ (equal? (class "msgbox")))) h3 *text*))
        test-sxml-match?)
 )

(test-end)