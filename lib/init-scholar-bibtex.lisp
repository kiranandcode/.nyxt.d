(in-package :nyxt-user)

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


(defun fetch-bibtex-from-scholar-id (id)
  "Given a scholar ID, retrieves the associated Bibtex to reference the paper."
  (alexandria:when-let* ((refs-url (concatenate 'string
                                              "https://scholar.google.com/scholar?output=gsb-cite&hl=en&q=info:"
                                              id
                                              ":scholar.google.com/"))
                       (raw-response (dex:get refs-url))
                       (json-response (json:decode-json-from-string raw-response))
                       (lookup-url (json-$ json-response :I 0 :U)))
    (dex:get lookup-url)))

(define-command-global annotate-scholar-paper-with-bibtex ()
  "When on a google scholar page, ask the user to select a google
  scholar paper, and then opens the corresponding org bibtex file."
  (with-user-provided-scholar-entry id
    (let ((bibtex-content (fetch-bibtex-from-scholar-id id)))
      (eval-in-emacs `(init-ref-add-and-annotate-bibtex-ref ,bibtex-content)))))
