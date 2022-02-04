(in-package :nyxt-user)

(defvar *scholar-annotation-style* "font-size: large; color: red; font-weight: bold"
  "CSS style to be assigned to scholar annotations.")

(define-parenscript collect-scholar-references-on-page ()
    (ps:let ((paper-ids (ps:*array))
             (papers (ps:chain document
                               (query-selector-all ".gs_scl.gs_or.gs_r"))))
      (ps:for ((i 0)) ((< i (length papers))) ((incf i))
              (ps:let*
                  ((paper (ps:getprop papers i))
                   ;; (url (ps:@ (ps:chain paper
                   ;;                      (query-selector ".gs_ri > .gs_fl"))
                   ;;            children 2
                   ;;            href))
                   ;; (id (ps:chain (-reg-exp ".*scholar\\?cites=([0-9]+)&.*")
                   ;;               (exec url)))
                   (data-did (ps:getprop (ps:chain paper dataset) "did")))
                ;; (ps:if (not id) ps:continue)
                ;; (ps:setq id (ps:getprop id 1))
                (ps:chain paper-ids (push data-did))))
      paper-ids))

(define-parenscript annotate-scholar-entries-by-id (id text)
  (ps:let* ((paper (ps:chain document
                            (query-selector
                             (ps:lisp (concatenate 'string "[data-did=\"" id "\"]")))))
           (annotation (ps:if paper
                              (ps:chain document (create-element "h4")))))
    (ps:when paper 
      (ps:setf (ps:chain annotation style) (ps:lisp *scholar-annotation-style*))
      (ps:setf (ps:inner-html annotation) (ps:lisp text))
      (ps:chain paper (append-child annotation))
      )))

(define-parenscript find-scholar-paper-title-by-id (id)
  (ps:let ((paper (ps:chain document
                            (query-selector
                             (ps:lisp (concatenate 'string "[data-did=\"" id "\"]"))))))
    (ps:chain paper (query-selector "h3 > a") text)))

(define-class scholar-annotation (nyxt:annotation)
  ((gsc-id ""
           :documentation "Google Scholar ID for reference.")
   (paper-title ""
    :documentation "Paper title of reference."))
  (:export-class-name-p t)
  (:export-accessor-names-p t)
  (:accessor-name-transformer (class*:make-name-transformer name)))

(defmethod nyxt::render ((annotation scholar-annotation))
  (spinneret:with-html-string
    (:p (:b "Title: ") (paper-title annotation))
    (:p (:b "Annotation: ") (data annotation))
    (:p (:b "GSCID: ") (gsc-id annotation))
    (:p (:b "Tags: ") (format nil "~{~a ~}" (tags annotation)))))

(defmacro with-user-provided-scholar-entry (id-sym &body body)
  "Prompt user for a google scholar entry and then pass the selected
id to THEN."
  (let ((lam-var-sym (gensym)))
    `(nyxt/web-mode:query-hints
      "Paper to annotate"
      (lambda (,lam-var-sym) (when (and ,lam-var-sym (car ,lam-var-sym))
                               (let ((,id-sym (plump:get-attribute (car ,lam-var-sym) "id")))
                                 ,@body)))
      :selector ".gs_scl.gs_or > .gs_ri > h3 a")))

(define-command-global add-scholar-annotation (&optional (buffer (current-buffer)))
  "Create a annotation for a Google Scholar entry in BUFFER."
  (with-current-buffer buffer
    (with-user-provided-scholar-entry id
    (let* ((data (prompt1
                   :prompt "Annotation"
                   :sources (list (make-instance 'prompter:raw-source
                                                 :name "Note"))))
           (tags (prompt
                  :prompt "Tag(s)"
                  :sources (list (make-instance 'prompter:word-source
                                                :name "New tags"
                                                :multi-selection-p t))))
           (annotation (make-instance
                        'scholar-annotation
                        :gsc-id id
                        :paper-title (find-scholar-paper-title-by-id id)
                        :data data
                        :tags tags)))
      (annotate-scholar-entries-by-id id data)
      (nyxt::annotation-add annotation)))))

(define-command show-scholar-annotations-for-page ()
  "Update current buffer with any google-scholar annotations."
  (let ((citations-on-page (collect-scholar-references-on-page))
        (annotations (nyxt::annotations)))
    (loop for annotation in annotations do
      (when (and (scholar-annotation-p annotation)
                 (member (gsc-id annotation)
                         citations-on-page
                         :test #'equal))
        (print (list "adding annotation" (gsc-id annotation) (data annotation)))
        (annotate-scholar-entries-by-id (gsc-id annotation) (data annotation))
        ))))

(defun update-scholar-entries-with-annotations-handler (buffer)
  (let ((buffer-url (url buffer)))
    (when (and
           (or (quri.uri.http:uri-https-p buffer-url)
               (quri.uri.http:uri-http-p buffer-url))
           (equal (quri:uri-authority buffer-url) "scholar.google.com"))

      (with-current-buffer buffer
        (show-scholar-annotations-for-page)))))

(define-configuration web-buffer
  ((nyxt:buffer-loaded-hook
    (hooks:add-hook %slot-default% #'update-scholar-entries-with-annotations-handler)
    )))

;; (defun old-reddit-handler (request-data)
;;   (let ((url (url request-data)))
;;     (setf (url request-data)
;;           (if (search "reddit.com" (quri:uri-host url))
;;               (progn
;;                 (setf (quri:uri-host url) "old.reddit.com")
;;                 (log:info "Switching to old Reddit: ~s" (object-display url))
;;                 url)
;;               url)))
;;   request-data)
;; (use-package :nyxt)

;; (define-configuration web-buffer
;;   ((request-resource-hook
;;     (hooks:add-hook %slot-default (make-handler-resource #'old-reddit-handler)))))
