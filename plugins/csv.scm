(use text.csv)
(use gauche.charconv)

(define-plugin "csv"
  (version "0.1")
  (export csv->list)
  (depend #f))

(define (csv->list csv-file)
  (call-with-input-file csv-file
    (cut port->list (make-csv-reader #\,) <>)
    :encoding '*jp))