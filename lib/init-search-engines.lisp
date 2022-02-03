(ql:quickload "serapeum")

(defun extract-opam-package-name (str)
  (car (str:split " " str :omit-nulls 't)))

(defun get-opam-packages ()
  (let ((installed-packages
          (str:split nyxt::+newline+
                     (ignore-errors
                      (uiop:run-program
                       "opam list --installed"
                       :output '(:string :stripped t))))))
      (mapcar #'extract-opam-package-name  (serapeum:drop 2 installed-packages))))

;; We'll compute this once at load time, and cache it.
;; Won't account for changing opam switches, but hey, how often will I use this?
(defvar installed-opam-packages (get-opam-packages))

(define-configuration (buffer web-buffer)
  ((search-engines (list (engines:google :shortcut "gmaps"
                                         :object :maps)
                         (engines:wordnet :shortcut "wn"
                                          :show-word-frequencies t)
                         (engines:google :shortcut "g"
                                         :safe-search nil)
                         (make-instance 'search-engine
                                   :shortcut "opam"
                                   :search-url "https://opam.ocaml.org/packages/~a/"
                                   :fallback-url (quri:uri "https://opam.ocaml.org/packages/")
                                   :completion-function
                                     (lambda (input)
                                       (sort
                                        (serapeum:filter (alexandria:curry #'str:containsp input)
                                                         installed-opam-packages)
                                        #'> :key (alexandria:curry
                                                  #'prompter::score-suggestion-string input))))
                         (engines:github :shortcut "gh")
                         (engines:duckduckgo :theme :terminal
                                             :help-improve-duckduckgo nil
                                             :homepage-privacy-tips nil
                                             :privacy-newsletter nil
                                             :newsletter-reminders nil
                                             :install-reminders nil
                                             :install-duckduckgo nil)
                         ))))
