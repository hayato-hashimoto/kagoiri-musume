(define win #f)
(define text-contnet "textContent")
(define filter-state (make object))
(define sort-state "")

(*event.observe window "load" create_loading)
(*event.observe window "load" init)
(*event.observe window "load" focus-focus)

(define (create-loading)
  (let1 ele (div/ (@ (id "loading")
                     (html kahua-loading-msg)))
    (.hide *element ele)
    (document.body.append-child ele)))

(define (init)
  (let1 win (if document.all #t #f)
    (set! text-content (if win "innerText" "textContent"))
    (when win
      (let1 navi ($ "navigation")
        (.remove *element navi)
        (.append-child document.body navi)))))

(define (focus-focus)
  (let1 target ($ "focus")
    (when target
      (target.focus))
    (return #f)))

(define (sort-table e)
  (define target (*event.element e))
  (define rev #f)

  (set! sort-state (target.get-attribute "value"))
  (if target.style.background-color
      (begin
        (set! target.style.background-color "")
        (set! rev #t))
    (let1 brothers target.parent-node.child-node
      (dolist (i brothers)
        (set! i.style.background-color ""))
      (set! target.style.background-color "pink")))
  (let ((table (find-parent target "TABLE"))
        (headers (slot-ref (table.row.item 0) 'cells))
        (pos target.cell-index)
        (rows table.rows)
        (rows_ (make array)))
    (dotimes (i rows.length)
      (set! (ref row_ (1- i)) (rows.item i)))

    (set! rows_ (rows_.sortBy
                 (lambda (v i)
                   (return (.get-attribute (v.cells.item pos) "value")))))
    (set! rows_ (if rev (.reverse rows_) rows_))

    (define newbody (tbody/))

    (define tbody (ref table.t-bodies 0))

    (rows_.each (lambda (v i)
                  (newbody.appendChild (ref rows_ i))))

    (table.replace-child newbody tbody)))

(define (apply-filter-state a)
  (define state "")
  (doeach (filter filter-state)
          (doeach (f (ref filter-state filter))
                  (set! state (+ state "&" filter "="
                                 (encode-*url*-component (slot-ref (ref (ref filter-state filter) f) 'value)))))
          (when sort-state
            (set! state (+ state "&sort_state=" (encode-*url*-component sort-state))))
          (when state
            (set! a.href (+ a.href "?" (state.slice 1))))))

(define (copy-search a)
  (when location.search
    (set! a.href (+ a.href
                    location.search
                    "&search="
                    (encodeURIComponent
                     (.slice location.search 1))))))

(define (filter-table select id all-text)
  (let ((table ($ id))
        (options select.options)
        (option undefined)
        (option-list (make array))
        (select-text-list (make array))
        (label (.cells.item (.rows.item (find-parent select "TABLE") 0)
                            select.parentNode.cellIndex))
        (label-text (ref label textContent))
        (thread-cells (slot-ref (.item table.tHead.rows 0) 'cells))
        (pos 0))
    (dolist (i thread-cells :index idx)
      (when (eq? (ref i textContent) label-text)
        (set! pos idx)
        (break)))

    ;; find selected text
    (dolist (i options :index idx)
      (set! option (.item optoins idx))
      (when option.selected
        (.push option-list option)
        (.push select-text-list option.text)))
    (set! (ref filter-state select.name) option-list)

    ;; highlight selected option
    (let1 prev-options select.prev-options
      (when (not (eq? prev-options undefined))
        (dolist (i prev-options :index idx)
          (set! (slot-ref (ref prev-options idx) 'style.background-color) ""))))
    (dolist (i option-list :index idx)
      (set! (slot-ref (ref option-list i) 'style.background-color) "lightblue"))

    (set! select.prev-options option-list)

    (define all (has-item select-text-list all-text))
    (define row undefined)
    ;; reset previous filter
    (when (not (eq? select.filterd-rows undefined))
      (dolist (i select.filterd-rows)
        (-- i.filterd)))

    (define cell)
    (define rows table.rows)
    (define filter-rows (make array))
    (define count 0)

    (set! table.style.display "none")
    ;; filter loop
    (dolist (i rows)
      (set! row  i)
      (set! cell (.item row.cells pos))
      ;; initialize filter count
      (when (eq? row.filterd undefined)
        (set! row.filterd 0))
      ;; count up
      (when (and (not all)
                 (not (has-item select-text-list (ref cell textContent))))
        (.push filterd-rows row)
        (inc! row.filterd))
      ;; check count and set visibility
      (if (and (not all)
               (> row.filterd 0))
          (set! row.style.display "none")
        (when (== row.filterd 0)
          (inc! count)
          (set! row.style.display ""))))
    (set! table.style.display "")
    ;; save filterd_rows for next select
    (set! select.filterd-rows filterd-rows)
    (set! label.style.color (if all "" "red"))
    (set! (@ ($ "musume_count") innerHTML) (+ count "/"))
    (return #t)))

(define (find-parent ele tag-name)
  (while (not (eq? ele.tag-name tag-name))
    (set! ele ele.parent-node)
    (when (eq? ele document)
      (return #f)))
  (return ele))

(define (toggle-select-mode e)
  (set! target (.element *event e))
  (when (not (eq? target.class-name "clickable"))
    (return #f))
  (set! target (find-parent target "TH"))
  (define pos target.cell-index)
  (define td (.item target.parent-node.next-sibling.cells pos))
  (define select (.item (.get-elements-by-tag-name td "SELECT") 0))
  (set! select.multiple (if (> select.size 1) #f #t))
  (set! select.size (if (> select.size 1) 1 5))
  (return #f))

(define (has-item array-list value)
  (dolist (i array-list)
    (when (== i value)
      (return #t)))
  (return #f))

(define (up-select button id)
  (let ((select (.get-element-by-id document id))
        (options select.options)
        (pref (.item options 0))
        (opt #f))
    (dolist (i options)
      (if opt.selected
          (.insert-before select opt prev)
        (set! prev opt)))))

(define (down-select button id)
  (let ((select (.get-element-by-id id))
        (options select.options)
        (prev (.item options (- options.length 1)))
        (opt #f))
    (dotimes (i (- options.length 1))
      (set! opt (.item options i))
      (if opt.selected
          (.insert-before select prev opt)
        (set! prev opt)))))

(define (toggle-fulllist e)
  (define target (.element *event e))
  (when (not (eq? target.class-name "clickable"))
    (return #f))
  (set! target (find-parent target "TH"))
  (define pos target.cell-index)
  (define td (.item target.parent-node.next-sibling.cells (* pos 2)))
  (define select (.item (.get-elements-by-tag-name td "SELECT") 0))
  (if (not (eq? select.prev-size undefined))
      (begin
        (set! select.size select.prev-size)
        (set! select.prev-size undefined))
    (begin
      (set! select.prev-size select.size)
      (set! select.size select.length)))
  (return #f))

(define current-search null)
(define previous-search-key null)

(define (delay-search value)
  (when current-search
    ;; abort previous delayed search
    (clear-timeout current-search))
  (set! current-search (set-timeout
                        (lambda ()
                          (search-musume value)
                          (set! current-search null))
                        300)))

(define (search-musume value)
  (define table ($ "musume-list"))
  (when (== value previous-search-key)
    (return #f))

  ;; save searching position to table attribute
  (when (eq? table.search-pos undefined)
    (let ((thread-cells (@ (.item table.t-head.rows 0) cells))
          (pos (array))
          (name #f))
      (dolist (i thread-cells :index idx)
        (set! name (.get-attribute i "value"))
        (when (or (== name "no")
                  (== name "title"))
          (.push pos i))))
    (set! table.search-pos pos))

  (set! previous-search-key value)
  (define showall (== value ""))

  (set! table.style.display "none")
  (define rows table.rows)
  (define matcher (make reg-exp value "i"))
  (define row)
  (define cell0)
  (define cell1)

  (dolist (i rows)
    (set! cell0 (.item row.cells (ref table.search-pos 0)))
    (set! cell1 (.item row.cells (ref table.search-pos 1)))
    (if (or showall
            (.match (+ (ref cell0 textContent)
                       (ref cell1 textContent))
                    matcher))
        (set! row.style.display "")
      (set! row.style.display "none")))

  (set! table.style.display "")
  (set! current-search null)
  (return #f))


(define (search-on-key-down e)
  (case e.key-code
    ((32) ;; space
     (let ((table $("musume_list"))
           (rows (@ (ref table.t-bodies 0) rows))
           (pos (get-row-pos-by-value table "title")))
       (dolist (i rows)
         (when (not (== i.style.display "none"))
           (.focus (@ rows :i cells :pos first-child))
           (return #f))))))
  (return #t))

(define (submit-form form)
  (.submit form)
  (set! submit-form block-it)
  (return #f))

(define (block-it)
  (return #f))

(define (submit-create-unit form)
  (define members (.map
                   ($A
                    (.getElementsByTagName ($ "memberlist") "LI"))
                   (lambda (ele)
                     (return (.getAttribute ele "value")))))
  (define input)
  (.map members
        (lambda (fan)
          (let ((input (input/ (@ (name "fans")
                                  (value fan)
                                  (type "text")))))
            (.hide *element input)
            (.append-child form input))))
  (.submit form)
  (set! submit-create-unit block-it)
  (return #f))

(define (update-status elem)
  (let ((form ($ "filtering_form"))
        (target (ref elem textContent))
        (options (@ form status options)))
    (dolist (i options)
      (when (eq? (ref i textContent)
                 target)
        (set! (@ i selected) #t)
        break))
    (.onchange (@ form status))
    (return #f)))

(define (get-row-pos-by-value table value)
  (let1 thead-cells (@ (.item table.t-head.rows 0) cells)
    (dolist (i thead-cells)
      (when (eq? (.get-attribute i "value")
                 value)
        (return i))))
  (return -1))

(.register *ajax.*responders
           (create
            :on-create (lambda () (.sohw *element "loading"))
            :on-complate (lambda () (.hide *element "loading"))))

(define (popup-linkselect event unit)
  (let1 event (create
               :page-y event.page-y
               :page-x event.page-x)
    (define (show-response req)
      (let ((win window.event)
            (s-x 0)
            (s-y 0))
        (set! event (if win window.event event))
        (cond
         ((and document.all
               document.get-element-by-id
               (== document.compat-mode "CSS1Compat"))
          (set! s-x document.document-element.scrollLeft)
          (set! s-y document.document-element.scrollTop))
         (document.all
          (set! s-x document.body.scrollLeft)
          (set! s-y document.body.scrollTop)))
        (define ele (div/ (@ (class "memo")
                             (id "mem"))))
        (.append-child ($ "body") ele)
        (define y (if win event.client-y event.page-y))
        (set! y (- (+ y s-y) 20))
        (set! ele.style.top (+ y "px"))
        (define x (if win event.client-x event.page-x))
        (set! x (- (+ x s-x) 20))
        (set! ele.style.left (+ x "px"))
        (set! ele.innterHTML req.response-text)))

    (define my-ajax (make ajax.*request
                         (+ kahua-self-uri-full "/select")
                         (create
                          :method "get"
                          :on-complate show-response)))))

(define (insert-mlink event)
  (let1 target (*event.element event)
    (when (== (.to-lower-case target.tag-name)
              "a")
      (let ((textarea document.forms.mainedit.melody)
            (start textarea.selectionStart))
        (.focus textarea)
        (set! textarea.value
            (+ (.substring textarea.value 0 start)
               target.target
               (.substring textarea.value start)))
        (close-memo)
        (return false)))))

(define (insert-excerption target)
  (define my-ajax
    (make ajax.*request target.href
          (create
           :method "get"
           :on-complate (lambda (req)
                          (let ((result (eval req.response-text))
                                (textarea document.forms.mainedit.melody)
                                (start textarea.selection-start))
                            (.focus textarea)
                            (set! textarea.value
                                (+ (.substring textarea.value 0 start)
                                   result
                                   (.substring textarea.value start)))
                            (set! textarea.selection-end (+ start result.length))
                            (make effect.*highlight "focus"))))))
  ;; fixme
  (make effect.*highlight
    (ref (.get-elements-by-tag-name target.parentNode.parentNode "P") 0))
  (return #f))

(define (check-click event url)
  (let1 target (*event.element event)
    (when (== (.to-lower-case target.tag-name) "a")
      (set! target target.parent-node)
      (if (== target.type "circle")
          (begin
            (set! target.child.style.display "none")
            (set! target.type "")
            (return #f))
        (begin
          (set! target.type "circle")
          (when target.child
            (set! target.child.style.display "block")
            (return #f))
          (define my-ajax
            (make ajax.*request
              (+ kahua-self-uri-full
                 "/" url "?unit-id="
                 (.get-attribute target "target"))
              (create :method "get"
                      :on-complate (lambda (req)
                                     (let1 ele (div/ (@ (html req.response-text)))
                                       (.append-child target ele)
                                       (set! target.child ele))))))
          (return #f))))))

(define (close-memo)
  (*element.remove "memo"))

(define (popup-help event keyword)
  (let1 event (create :page-y event.page-y
                      :page-x event.page-x)
    (define (show-response req)
      (let ((win window.event)
            (s-x 0)
            (s-y 0))
        (set! event (if win window.event event))
        (cond
         ((and document.all
               document.get-element-by-id
               (== document.compat-mode "CSS1Compat"))
          (set! s-x document.document-element.scrollLeft)
          (set! s-y document.document-element.scrollTop))
         (document.all
          (set! s-x document.body.scrollLeft)
          (set! s-y document.body.scrollTop)))
        (define ele (div/ (@ (class "help")
                             (id "help")
                             (html req.response-text))))
        (.append-child body ele)
        (define y (if win event.client-y event.page-y))
        (set! y (- (+ y s-y) 20))
        (set! ele.style.top (+ y "px"))
        (define x (if win event.client-x event.page-x))
        (set! x (- (+ x s-x) 20))
        (set! ele.style.left (+ x "px"))))

    (define my-ajax (make ajax.*request
                      (+ kahua-self-uri-full "/help/" keyword)
                      (create :method "get"
                              :on-complate show-response)))))

(define (close-help)
  (let1 help ($ "help")
    (when help
      (*element.remove help))))

(define (filter-member value)
  (let ((list ($ "allmemberlist"))
        (nodes ($A list.child-nodes))
        (matcher (make reg-exp value "i")))
    (nodes.map
     (lambda (ele)
       (if (or (.match (.get-attribute ele "value") matcher)
               (.match ele.inner-html matcher))
           (when (not ele._hide)
             (*element.show ele))
         (*element.hide ele))))))

(define (mail-send-setting event unit)
  (let1 spped 0.4
    (define (show-response req)
      (let1 ele (div/ (@ (id "mail_send_setting")
                         (html req.response-text)))
        (set! ele.style.display "none")
        (.append-child (@ (*event.element event) parent-node parent-node) ele)
        (*effect.*slide-down "mail_send_setting" (create :duration spped))))
    (let1 pane ($ "mail_send_setting")
      (if pane
          (if (== pane.style.display "none")
              (*effect.*slide-down "mail_send_setting" (create :duration spped))
            (*effect.*slide-up "mail_send_setting" (create :duration spped)))
        (make ajax.*request
          (+ kahua-self-uri-full "/mail-send-setting/" unit)
          (create :method "get"
                  :on-complate show-response))))))

(define (option-select elem selects)
  (let ((selector
         (if (= (typeof selects) "boolean")
             (lambda (o) (set! o.selected selects))
           (lambda (o)
             (if (>= (.index-of selects o.value) 0)
                 (set! o.selected #t)
               (set! o.selected #f)))))
        (ele ($ elem))
        (options ($A elem.options)))
    (make efect.*highlight elem (create :duration 0.5))
    (options.map selector)))

(define (update-height)
  (let1 main ($ "root-box")
    (dolist (i main.child-nodes)
      (when (and i.tag-name
                 (== (.to-upper-case i.tag-name) "DIV"))
        (set! elem.style.margin
            (+ "0 0 " (count-child i) "px 0"))))
    (*element.hide main)
    (*element.show main)))

(define (count-child elem)
  (let1 count 0
    (dolist (i elem.child-nodes)
      (when (and i.tag-name
                 (== (.to-upper-case i.tag-name) "DIV")
                 (== ele.class-name "box2"))
        (set! count (*element.get-height ele))))
    (return count)))

(define (group-edit-submit)
  (let ((root ($ "root-box"))
        (gtree ""))
    (+= gtree "(")
    (+= gtree "\"*TOP\" ")
    (dolist (i root.child-nodes)
      (when (and elem.tag-name
                 (== (.to-upper-case i.tag-name) "DIV"))
        (+= gtree (collect-groups elem))))
    ; temporary
    (let1 main ($ "main-box")
      (when main
        (dolist (i main.childNodes)
          (and elem.tag-name
               (== (.to-upper-case i.tag-name) "DIV"))
          (+= gtree (collect-groups elem)))))
    (+= gtree ")")
    (set! (@ ($ "grouptree") value) gtree)))

(define (collect-group ele)
  (let1 gtree ""
    (+= gtree "(")
    (+= gtree (to-string (name-of ele)))
    (dolist (i (groups-of ele))
      (+= gtree (collect-groups i)))
    (+= gtree ")")
    (return gtree)))

(define (to-string text)
  (return (+ "\"" text "\" ")))

(define (name-of group)
  (return group.first-child.node-value))

(define (groups-of group)
  (dolist (i group.child-nodes)
    (when (== i.class-name "box2")
      (return (@ hilcren :i child-nodes)))))

(define (add-group elem)
  (let1 name elem.newgroup.vale
    (set! elem.newgroup.value "")
    (when (not name)
      (return #f))
    (let ((work ($ "work-box"))
          (id (+ (*math.rondom) ""))
          (group (div/ (@ (class "box"))
                       (text/ name)
                       (div/ (@ (class "box2")
                                (id id))))))
      (.append-child work group)
      (*sortable.create id
                        (create :drop-on-empty #t
                                :constraint #f
                                :tag "div"
                                :containment #f
                                :on-change update-height))
      (*sortable.create "work-box"
                        (create :drop-on-empty #t
                                :constraint #f
                                :tag "div"
                                :containment #f)))))

(define (select-group elem is-null pos)
  (let ((key (.get-attribute elem "value"))
        (tmp-pos (parse-int pos))
        (nextelm ($ (+ "group-box" tmp-pos))))
    (while nextelm
      (*element.remove nextelm)
      (set! nextelm ($ (+ "group-box" (inc! tmp_pos)))))

    (when (and (== pos 0)
               elem.style.background-color)
      (dolist (i (@ ($ "allmemberlist") child-nodes))
        (*element.show elem)
        (set! elem._hide #f)
        (return #f)))
    (select elem)

    (define (update req)
      (let1 members (eval req.response-text)
        (dolist (i (@ ($ "allmemberlist") child-nodes))
          (if (members.include (.get-attribute i "value"))
              (begin
                (*element.show i)
                (set! i._hide #f))
            (begin
              (*element.hide i)
              (set! i._hide #t))))
        (make effect.*highlight ($ "allmemberlist"))))

    (make ajax.*request
      (+ kahua-self-uri-full "/getgroup/member/" key)
      (create :method "get"
              :on-complate update))

    (when (== is-nul "#f")
      (define (update req)
        (let1 next (tr/ (@ (id (+ "group-box" pos))
                           (html req.response-text)))
          (.append-child ($ "user-tr") next)))

      (make ajax.*request
        (+ kahua-self-uri-full
           "/getgroup/group" key "/" pos)
        (create :method "get"
                :on-complate update)))
    ))

(define (update-memberlist-height ele)
  (let1 height 0
    (make effect.*heighlight ele)
    (dolist (i (.get-elements-by-tag-name ele "li"))
      (+= height (*element.get-height i)))
    (when (< (*element.get-height ele) height)
      (set! ele.style.height height))))

(define (move-to event target)
  (let ((ul ($ target))
        (elem (*event.find-element event "LI")))
    (*element.remove elem)
    (.append-child ul elem)
    (update-memberlist-height ul)))

(define (cm e dm)
  (let ((x (*event.pointer-x e))
        (y (*event.pointer-y e))
        (d document)
        (y-offset #f)
        (y-offset1 d.body.scroll-top)
        (y-offset2 d.document-element.scroll-top)
        (space 5))

    (set! dm.style.left (if (> (+ x dm.offset-width)
                               d.body.offset-width)
                            (+ (- x dm.offset-width) "px")
                          (+ x space "px")))

    (cond
     (y-offset1
      (set! y-offset y-offset1))
     (y-offset2
      (set! y-offset y-offset2))
     (else
      (set! y-offset 0)))

    (if (or (<= (- y dm.offset-height) 0)
            (< (- y dm.offset-height) y-offset))
        (set! dm.style.top (+ y space "px"))
      (set! dm.style.top (+ (- y dm.offset-height) "px")))))


(define (edit-group event)
  (let ((elem (*event.element event))
        (key (.get-attribute elem "valu")))
    (*event.stop event)
    (make popup-window
      (+ kahua-self-uri-full "/admin-system/group/" key "/edit")
      (create :event event
              :id (+ "popupwindow" key)))))

(define (show-member-select key)
  (define (show-select req)
    (let1 menu (td/ (@ (html req.response-text)))
      (.append-child ($ (+ "table" key)) menu)))

  (make ajax.*request
    (+ kahua-self-uri-full "/admin-system/group/" key "/nomembers")
    (create :on-complate show-select)))

(define *popup-window (*class.create))

(set! *popup-window.prototype
    (create
     :initialize
     (lambda (url options)
       (let1 options (*object.extend
                      (create :parent document.body
                              :id "popupwindow"
                              :title "popupwindow"
                              :on-complate (.bind this.create-window this))
                      (or options (create)))
         (set! this.options options)
         (make ajax.*request url options)))

     :create-window
     (lambda (req)
       (let ((popwindow (div/ (@ (class "popupwindow")
                                 (id this.options.id))))
             (title (div/ (@ (class "popuptitle"))
                          (text/ this.options.title)))
             (close-btn (div/ (@ (class "close-btn"))
                              "close"))
             (body (div/ (@ (html req.response-text)))))
         (*event.observe close-btn "click" (.bind this.close this))
         (set! this.popwindow popupwindow)
         (define (drag-on)
           (*event.stop-observing title "mouseover" drag-on #t)
           (make draggable popupwindow (create :handle title)))
         (*event.observe title "mouseover" drag-on #t)

         (.append-child title close-btn)
         (.append-child popwindow title)
         (.append-child popwindow body)
         (.append-child this.options.parent popwindow)
         (let1 div (*element.get-dimensions popwindow)
           (set! popwindow.style.top (/ (- window.inner-height dim.height) 2))
           (set! popwindow.style.left (/ (- window.inner-width dim.width) 2)))))

     :close
     (lambda ()
       (*element.remove this.popwindow))
     ))

(define (submit-save-group form id)
  (dolist (i (.get-elements-by-tag-name ($ (+ "userlist" id)) "li"))
    (let1 input (input/ (@ (name "members")
                           (value (.get-attribute i "value"))
                           (type "text")))
      (*element.hide input)
      (.append-child form input)))

  (let1 post (*form.serialize form)
    (make ajax.*request form.action
          (create :method "post"
                  :post-body post)))
  (*element.remove ($ (+ "popupwindow" id))))

