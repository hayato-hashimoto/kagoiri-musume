;; -*- coding: euc-jp; mode: scheme -*-
;;
;; you eval in repl.
;;

;; read all objects.
(map key-of (make-kahua-collection <musume>))
(map key-of (make-kahua-collection <song>))

(define-class <musume> (<kahua-persistent-base>)
  (
   ;; new slot
   (unit            :allocation :persistent :init-keyword :unit
		    :accessor unit-of)
   ;; musume-no means issue number.
   (musume-no       :allocation :persistent :init-keyword :musume-no
		    :init-value #f :accessor mno-of)
   ;; issue title
   (musume-name     :allocation :persistent :init-keyword :musume-name
		    :init-value "" :accessor mname-of)
   ;; issue priority
   ;; normal above-normal low high super
   (priority        :allocation :persistent :init-keyword :priority
		    :init-value "normal" :accessor priority-of)
   ;; status
   ;; open completed on-hold taken rejected
   (status          :allocation :persistent :init-keyword :status
		    :init-value "open" :accessor status-of)
   ;; type
   ;; discuss request bug report task term etc
   (type            :allocation :persistent :init-keyword :type
		    :init-value #f :accessor type-of)
   ;; category
   ;;
   (category        :allocation :persistent :init-keyword :category
		    :initi-value #f :accessor category-of)
   ;; assign
   (assign          :allocation :persistent :init-keyword :assign
		    :init-value #f :accessor assign-of)
   ;; songs
   (songs           :allocation :persistent :init-keyword :songs
		    :init-value '() :accessor songs-of)
   ;; create time
   (ctime           :allocation :persistent :init-keyword :ctime
		    :init-thunk sys-time :accessor ctime-of)
   (delete          :allocation :persistent :init-keyword :delete
		    :init-value #f :accessor delete-of)
   ))

(define-class <song> (<kahua-persistent-base>)
  ((seq-no          :allocation :persistent :init-keyword :seq-no
		    :init-value #f :accessor seq-no-of)
   (musume          :allocation :persistent :init-keyword :musume
		    :accessor musume-of)
   (melody          :allocation :persistent :init-keyword :melody
		    :accessor melody-of)
   (files           :allocation :persistent :init-keyword :files
		    :init-value '() :accessor files-of)
   (fan             :allocation :persistent :init-keyword :fan
		    :init-value #f :accessor fan-of)
   (ctime           :allocation :persistent :init-keyword :ctime
		    :init-thunk sys-time :accessor ctime-of)
   (delete          :allocation :persistent :init-keyword :delete
		    :init-value #f :accessor delete-of)
   ))

(map (lambda (o) (ref o 'delete)) (make-kahua-collection <musume>))
(map (lambda (o) (ref o 'delete)) (make-kahua-collection <song>))




