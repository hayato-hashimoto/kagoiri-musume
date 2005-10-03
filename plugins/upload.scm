;; upload
;;
(define-plugin "upload"
  (version "0.1")
  (export open-uploaded-file
      call-with-uploaded-file
      with-input-from-uploaded-file
      get-original-name
      save-uploaded-file)
  (depend #f))


(define-export (open-uploaded-file spec)
  (let1 tmpf (car spec)
    (open-input-file tmpf)))


(define-export (call-with-uploaded-file spec proc)
  (let1 in (open-uploaded-file spec)
    (with-error-handler
      (lambda (e) (close-input-port in) (raise e))
      (lambda ()
        (begin0
          (proc in)
          (close-input-port in))))))


(define-export (with-input-from-uploaded-file spec thunk)
  (call-with-uploaded-file spec (cut with-input-from-port <> thunk)))


(define-export (get-original-name spec)
  (cadr spec))


(define-export (save-uploaded-file spec path)
  (sys-rename (car spec) path))
