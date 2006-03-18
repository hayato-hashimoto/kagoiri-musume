;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: login-logout.scm,v 1.1 2006/03/18 12:21:16 shibata Exp $

(load "common.scm")

(test-start "kagoiri-musume login-logout check")

(*setup*)

;;------------------------------------------------------------
;; Run kagoiri-musume
(test-section "kahua-server kagoiri-musume.kahua")

(with-worker
 (w *worker-command*)

 (test* "run kagoiri-musume.kahua" #t (worker-running? w))

 (call-worker-test* "ログイン画面フォーム"

                    :node '(*TOP*
                            (form (@ (method "POST")
                                     (action ?&login))
                                  ?*))

                    :sxpath (//body '(form)))


 (call-worker-test* "ログイン画面インプット要素"

                    :node '(*TOP* (input (@ (value "login") (type "submit") (name "submit")))
                                  (input (@ (value "") (type "text") (name "name") (id "focus")))
                                  (input (@ (value "") (type "password") (name "pass"))))

                    :sxpath (//body '(form // input)))

 (call-worker-test* "ログインリンク"

                    :node '(*TOP* (!contain "Login"))

                    :sxpath (//header-action '(// a *text*)))

 (call-worker-test* "ログインしてユーザ名をチェック"

                    :gsid 'login

                    :node '(*TOP* (!contain "cut-sea"))

                    :body '(("name" "cut-sea") ("pass" "cutsea"))

                    :sxpath (//header-action '(// a *text*)))

 (call-worker-test* "ログインしてログアウトリンクをチェック"

                    :gsid 'login

                    :node '(*TOP* (!contain
                                   (a (@ (href ?&logout) ?*)
                                      "Logout")))

                    :body '(("name" "cut-sea") ("pass" "cutsea"))

                    :sxpath (//header-action '(// a)))

 (call-worker-test* "ログアウトしてユーザ名が表示されない事をチェック"

                    :gsid 'logout

                    :node '(*TOP* (!exclude "cut-sea"))

                    :sxpath (//header-action '(// a *text*))

                    :redirect #t
                    )

 (call-worker-test* "ログアウトしてログインリンクをチェック"

                    :gsid 'logout

                    :node '(*TOP* (!contain "Login"))

                    :sxpath (//header-action '(// a *text*))

                    :redirect #t
                    )

 )

(test-end)


