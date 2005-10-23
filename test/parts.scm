(define *head*
  `(head
    (title ?_) (meta ?@) (link ?@) (script ?@)))

(define *header*
  '(div ?@
        (h1 ?@ ?_)
        (a ?@ "トップ")
        (a ?@ "システム管理")
        (a ?@ "ユニット一覧")
        (a ?@ "Login")))

(define *footer*
  '(div (@ (id "bottom-pane"))
        (p ?_)))

(define (*header-logedin* user)
  `(div ?@
        (h1 ?@ ?_)
        (a ?@ "トップ")
        (a ?@ "システム管理")
        (a ?@ "ユニット一覧")
        (a ?@ "パスワード変更")
        (span " Now login:" (a ?@ ,user))
        (a (@ (href ?&)) "Logout")
        (form ?@ "検索:" (input ?@))))

(define-syntax *make-body*
  (syntax-rules ()
    ((*mke-body* b1 ...)
     `(div (@ (id "body"))
           b1 ...))))

