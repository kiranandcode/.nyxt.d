(in-package :nyxt-user)

(defvar fuck-you-google-headers
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36"
  "Headers to get around Google's dumb checker - FUCK YOU, BAN ME, GO ON, BAN ME!")

(defmacro json-$ (expr &rest fields)
  (let ((result expr))
    (loop for field in fields do
      (cond
        ((numberp field)
         (setq result
               (let ((sym (gensym)))
                 `(let ((,sym ,result))
                    (when (and ,sym (listp ,sym) (< ,field (length ,sym)))
                      (elt ,sym ,field))))))
        ((symbolp field)
         (setq result
               (let ((sym (gensym)))
                 `(let ((,sym ,result))
                    (when ,sym
                      (cdr (assoc ,field ,sym)))))))))
    result))

(defun http-req-to-string (url)
  (let ((result
          (uiop:run-program
           `("curl"
             "-H" ,(concatenate 'string  "user-agent: " fuck-you-google-headers)
             ,url) :output :string)))
    (log:info "retrieved " url " -> "  result)
    result
    ))

(defun fetch-bibtex-from-scholar-id (id)
  "Given a scholar ID, retrieves the associated Bibtex to reference the paper."
  (alexandria:when-let* ((refs-url (concatenate 'string
                                                "https://scholar.google.com/scholar?output=gsb-cite&hl=en&q=info:"
                                                id
                                                ":scholar.google.com/"))
                         (raw-response (http-req-to-string refs-url))
                         (json-response (json:decode-json-from-string raw-response))
                         (lookup-url (json-$ json-response :I 0 :U)))
    (http-req-to-string lookup-url)))

(define-command-global annotate-scholar-paper-with-bibtex ()
  "When on a google scholar page, ask the user to select a google
  scholar paper, and then opens the corresponding org bibtex file."
  (with-user-provided-scholar-entry id
    (let ((bibtex-content (fetch-bibtex-from-scholar-id id)))
      (log:info "got bibtex info: " bibtex-content)
      (eval-in-emacs `(init-ref-add-and-annotate-bibtex-ref ,bibtex-content)))))
