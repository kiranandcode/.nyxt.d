(in-package :nyxt-user)

(ql:quickload "trivia")

(defun file-symbol-to-config-path (file)
  (let ((lower-case-name (string-downcase (symbol-name file))))
    (concatenate 'string "lib/" lower-case-name ".lisp")))

(defmacro load-libs (&rest files)
  `(progn
     ,@(mapcar (lambda (file)
                 (trivia:match file
                   ((list 'QUOTE file)
                    (let* ((file-name (file-symbol-to-config-path file))
                           (file-path (nyxt-init-file file-name)))
                      `(when (probe-file ,file-path)
                         (load ,file-path))))
                   ((list :after pkg (list 'QUOTE file))
                    (let* ((file-name (file-symbol-to-config-path file))
                           (file-path (nyxt-init-file file-name)))
                        `(load-after-system ,pkg ,file-path)))
                     )) files)))
