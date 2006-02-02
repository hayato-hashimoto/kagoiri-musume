;; -*- coding: euc-jp; mode: scheme -*-
;;
;;  Copyright (c) 2005 Kahua.Org, All rights reserved.
;;  See COPYING for terms and conditions of using this software
;;
;; $Id: calendar.scm,v 1.1 2006/02/02 15:07:04 cut-sea Exp $

(use srfi-1)
(use srfi-19)
(use util.list)

(define-plugin "calendar"
  (version "0.1")
  (export make-date-lite make-month-lite make-year-lite today
          current-month prev-month next-month
          days-of-month first-date-of-month last-date-of-month
          same-date? same-month? same-year? include?
          dates-of-month date-slices-of-month
          dates-of-week current-week prev-week next-week
          nth-week-before nth-week-after
          current-day prev-day next-day nth-day-before nth-day-after
          yesterday tomorrow
          current-year prev-year next-year
          date=? date<? date<=? date>? date>=?
	  holiday?
          )
  (depend #f))

(define (inc n) (+ n 1))
(define (dec n) (- n 1))

(define (mask pred? item ilst)
  (map (lambda (i)
         (if (pred? i item) i #f))
       ilst))

(define (include? item ilst pred?)
  (if (null? ilst) #f
      (if (pred? item (car ilst)) #t
          (include? item (cdr ilst) pred?))))

(define (make-date-lite y m d)
  (make-date 0 0 0 0 d m y (date-zone-offset (current-date))))

(define (make-month-lite y m)
  (make-date 0 0 0 0 1 m y (date-zone-offset (current-date))))

(define (make-year-lite y)
  (make-date 0 0 0 0 1 1 y (date-zone-offset (current-date))))

(define (today)
  (let1 d (current-date)
    (make-date-lite (date-year d) (date-month d) (date-day d))))

(define (current-month date)
  (make-month-lite (date-year date) (date-month date)))

(define (prev-month date)
  (if (= (date-month date) 1)
      (make-month-lite (dec (date-year date)) 12)
      (make-month-lite (date-year date) (dec (date-month date)))))

(define (next-month date)
  (if (= (date-month date) 12)
      (make-month-lite (inc (date-year date)) 1)
      (make-month-lite (date-year date) (inc (date-month date)))))

(define (days-of-month date)
  (inexact->exact
   (- (date->modified-julian-day (next-month date))
      (date->modified-julian-day (current-month date)))))

(define (first-date-of-month date)
  (make-date-lite (date-year date) (date-month date) 1))

(define (last-date-of-month date)
  (make-date-lite (date-year date) (date-month date) (days-of-month date)))

(define (same-date? d1 d2)
  (and (and (date? d1) (date? d2))
       (= (date-day d1) (date-day d2))
       (= (date-month d1) (date-month d2))
       (= (date-year d1) (date-year d2))))

(define (same-month? d1 d2)
  (and (and (date? d1) (date? d2))
       (= (date-month d1) (date-month d2))
       (= (date-year d1) (date-year d2))))

(define (same-year? d1 d2)
  (and (and (date? d1) (date? d2))
       (= (date-year d1) (date-year d2))))

(define (dates-of-month date)
  (let ((y (date-year date))
        (m (date-month date)))
    (map (lambda (d)
           (make-date-lite y m d))
         (iota (days-of-month date) 1))))

(define (date-slices-of-month date . flag)
  (let1 flag (get-optional flag #f)
    (let* ((cday1 date)
           (pday1 (prev-month date))
           (cmonth (dates-of-month date))
           (pmonth (dates-of-month (prev-month date)))
           (nmonth (dates-of-month (next-month date))))
      (let1 pcn (slices (append (make-list (date-week-day pday1) #f)
                                pmonth cmonth nmonth)
                        7 #t #f)
        (let rec ((pcn pcn)
                  (cal '()))
          (if (null? pcn)
              (if flag (reverse cal)
                  (map (lambda (w)
                         (mask same-month? date w))
                       (reverse cal)))
              (if (include? date (car pcn) same-month?)
                  (rec (cdr pcn) (cons (car pcn) cal))
                  (rec (cdr pcn) cal))))))))

(define (dates-of-week date . flag)
  (let1 flag (get-optional flag #f)
    (let* ((wd (date-week-day date))
           (sunday (nth-day-before wd date)))
      (let rec ((week '())
                (day sunday)
                (n 7))
        (if (= n 0)
            (if flag (reverse week)
                (mask same-month? date (reverse week)))
            (rec (cons day week) (next-day day) (dec n)))))))

(define current-week dates-of-week)

(define (prev-week date . flag)
  (let1 flag (get-optional flag #f)
    (let* ((wd (date-week-day date))
           (saturday (nth-day-before (+ wd 1) date)))
      (let rec ((week '())
                (day saturday)
                (n 7))
        (if (= n 0)
            (if flag week
                (mask same-month? date week))
            (rec (cons day week) (prev-day day) (dec n)))))))

(define (next-week date . flag)
  (let1 flag (get-optional flag #f)
    (let* ((wd (date-week-day date))
           (sunday (nth-day-after (- 7 wd) date)))
      (let rec ((week '())
                (day sunday)
                (n 7))
        (if (= n 0)
            (if flag (reverse week)
                (mask same-month? date (reverse week)))
            (rec (cons day week) (next-day day) (dec n)))))))

(define (current-day date)
  (make-date-lite (date-year date) (date-month date) (date-day date)))

(define (prev-day date)
  (if (same-date? date
                  (first-date-of-month date))
      (last-date-of-month (prev-month date))
      (make-date-lite (date-year date)
                      (date-month date)
                      (dec (date-day date)))))

(define (next-day date)
  (if (same-date? date
                  (last-date-of-month date))
      (first-date-of-month (next-month date))
      (make-date-lite (date-year date)
                      (date-month date)
                      (inc (date-day date)))))

(define (nth-day-before n date)
  (if (= n 0) date (nth-day-before (dec n) (prev-day date))))

(define (nth-day-after n date)
  (if (= n 0) date (nth-day-after (dec n) (next-day date))))

(define (nth-week-before n date . flag)
  (let1 flag (get-optional flag #f)
    (if (= n 0)
        (current-week date flag)
        (nth-week-before (dec n) (car (prev-week date #t)) flag))))

(define (nth-week-after n date . flag)
  (let1 flag (get-optional flag #f)
    (if (= n 0)
        (current-week date flag)
        (nth-week-after (dec n) (car (next-week date #t)) flag))))

(define (yesterday) (prev-day (today)))
(define (tomorrow) (next-day (today)))

(define (current-year date)
  (make-year-lite (date-year date)))

(define (prev-year date)
  (make-year-lite (dec (date-year date))))

(define (next-year date)
  (make-year-lite (inc (date-year date))))

(define (date=? . args)
  (apply = (map date->modified-julian-day args)))

(define (date<? . args)
  (apply < (map date->modified-julian-day args)))

(define (date<=? . args)
  (apply <= (map date->modified-julian-day args)))

(define (date>? . args)
  (apply > (map date->modified-julian-day args)))

(define (date>=? . args)
  (apply >= (map date->modified-julian-day args)))

;
; holiday
;
(define holy-day (make-date-lite 1948 7 20))
(define compensating-holiday (make-date-lite 1973 4 12))

(define int floor)
(define (make-equinox p1979 p2099 p2150)
  (define max-day 99)
  (lambda (yy)
    (let ((v1 (* 0.242194 (- yy 1980)))
          (v2 (int (/ (- yy 1983) 4)))
          (v3 (int (/ (- yy 1980) 4))))
      (cond ((<= yy 1947) max-day)
            ((<= yy 1979) (- (int (+ p1979 v1)) v2))
            ((<= yy 2099) (- (int (+ p2099 v1)) v3))
            ((<= yy 2150) (- (int (+ p2150 v1)) v3))
            (else max-day)))))

(define spring-equinox (make-equinox 20.8357 20.8431 21.851))
(define autumnal-equinox (make-equinox 23.2588 23.2488 24.2488))


(define (holiday? t)
  (define %workday 0)
  (define %saturday 1)
  (define %sunday 2)
  (define %holiday 3)
  (define %compensate 4)
  (define %holy 5)
  (define (prev-day d)
    (modified-julian-day->date
     (- (date->modified-julian-day d) 1.0)))

  (let ((yy (date-year t))
        (mm (date-month t))
        (dd (date-day t))
        (ww (date-week-day t)))

    (let1 r %workday
      (define (set-holy!) (set! r %holy))
      (define (set-holiday!) (set! r %holiday))

      (case ww
        ((6) (set! r %saturday))
        ((0) (set! r %sunday)))

      (if (date<? t holy-day) r
          (case mm
            ((1) (case dd
                   ((1) (set-holy!))
                   (else (if (>= yy 2000)
                             (if (= (int (/ (- dd 1) 7)) ww 1)
                                 (set-holy!))
                             (if (= dd 15) (set-holy!))))))
            ((2) (case dd
                   ((11) (if (>= yy 1967) (set-holy!)))
                   ((24) (if (= yy 1989) (set-holy!)))))
            ((3) (if (= dd (spring-equinox yy))
                     (set-holy!)))
            ((4) (case dd
                   ((29) (set-holy!))
                   ((10) (if (= yy 1959) (set-holy!)))))
            ((5) (case dd
                   ((3) (set-holy!))
                   ((4) (if (and (> ww 1) (>= yy 1986))
                            (set-holiday!)))
                   ((5) (set-holy!))))
            ((6) (if (and (= yy 1993) (= dd 9))
                     (set-holy!)))
            ((7) (cond ((>= yy 2003)
                        (if (and (= (int (/ (- dd 1) 7)) 2) (= ww 1))
                            (set-holy!)))
                       ((>= yy 1996)
                        (if (= dd 20) (set-holy!)))))
            ((9) (if (= dd (autumnal-equinox yy))
                     (set-holy!)
                     (cond ((>= yy 2003)
                            (if (and (= (int (/ (- dd 1) 7)) 2) (= ww 1))
                                (set-holy!)
                                (if (and (= ww 2)
                                         (= dd (- (autumnal-equinox yy) 1)))
                                    (set-holiday!))))
                           ((>= yy 1966) (if (= dd 15) (set-holy!))))))
            ((10) (cond ((>= yy 2000) (if (= (int (/ (- dd 1) 7)) ww 1)
                                       (set-holy!)))
                        ((>= yy 1966) (if (= dd 10) (set-holy!)))))
            ((11) (case dd
                    ((3 23) (set-holy!))
                    ((12) (if (= yy 1990) (set-holy!)))))
            ((12) (case dd
                    ((23) (if (>= yy 1989) (set-holy!)))))))

      (if (and (<= r %holiday) (= ww 1))
          (if (date>=? t compensating-holiday)
              (if (= (holiday? (prev-day t)) %holy)
                  %compensate)))

      r)))

;; Local variables:
;; mode: scheme
;; end:
