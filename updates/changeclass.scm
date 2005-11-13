;; -*- coding: euc-jp; mode: scheme -*-

(use srfi-1)
(use gauche.collection)
(use kahua)
;; (sys-system "mysql -u root < drop.sql")
;; (sys-system "mysql -u root kagoiri < kagoiri20051029.sql")
(define *db* "mysql:khead::db=kagoiri")
;; (define *old-classes* "/home/tomohisa/work/kago/kagoiri-musume.khead/class.kahua")
(define *old-classes* "/home/khead/var/kahua/checkout/kagoiri-musume/class.kahua")
;; (define *new-classes* "/home/tomohisa/kahua/var/kahua/checkout/kagoiri-musume/class.kahua")
(define *new-classes* "/home/khead/src/kahua/kagoiri-musume/kagoiri-musume/class.kahua")

(define old-load load)
(define (load path)
  (if (member path
              (list *old-classes* *new-classes*))
      (old-load path)
    (print path)))

;; load old classes
(load *old-classes*)

(define (touch-slot-values obj)
  (for-each (lambda (s)
              (and (eq? (slot-definition-allocation s) :persistent)
                   (slot-ref obj (slot-definition-name s))))
            (class-slots (class-of obj))))

;; read all objects.
(with-db
 (db *db*)
 (let1 db (current-db)
   (for-each
    (lambda (item)
      (map touch-slot-values
           (make-kahua-collection (cdr item))))
    (class-slot-ref <kahua-persistent-meta> 'class-alist))))

;; save old classes
(define <old-file> <file>)
(define <old-musume> <musume>)

;; load new classes and redefine
(load *new-classes*)

(redefine-class! <music> <song>)
(redefine-class! <fan-property> <fan>)

(define-method change-class ((obj <old-file>) (new-class <class>))
  (let* ((file-name (slot-ref-using-class <old-file> obj 'file-name))
         (file-xtnsn (let1 body+ext (string-split file-name ".")
                       (if (= (length body+ext) 1)
                           "" (last body+ext)))))
    (next-method)
    (slot-set-using-class! new-class obj 'extension file-xtnsn)))

(define-method change-class ((obj <old-musume>) (new-class <class>))
  (let* ((musics (slot-ref-using-class <old-musume> obj 'musics)))
    (next-method)
    (slot-set-using-class! new-class obj 'songs musics)))

(define-method change-class ((obj <fan-property>) (new-class <class>))
  (let* ((fan-name (slot-ref-using-class <fan-property> obj 'fan-name))
         (email (slot-ref-using-class <fan-property> obj 'email)))
    (next-method)
    (slot-set-using-class! new-class obj 'login-user
                           (find-kahua-instance <kahua-user> fan-name))
    (slot-set-using-class! new-class obj 'email
                            (make <email>
                              :address email))))


;; touch all objects
(with-db
 (db *db*)
 (let1 db (current-db)
   (print "**********class redefine**********")
   (map class-of (make-kahua-collection <fan-property>))
   (for-each
    (lambda (m)
      (class-of m))
    (hash-table-values (ref db 'instance-by-id)))))
