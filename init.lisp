(in-package :nyxt-user)

#-quicklisp
(let ((quicklisp-init
       (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

(load (nyxt-init-file "lib.lisp"))

;; required by init-reader
(ql:quickload "cl-markup")

(load-libs
 'init-emacs
 'init-common
 'init-password
 'init-emacs-color-scheme
 (:after :nx-search-engines 'init-search-engines)
 (:after :nx-freestance-handler 'init-freestance)
 ;; (:after :nx-reader 'init-reader)
 )
