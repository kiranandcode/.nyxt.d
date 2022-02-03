(in-package :nyxt-user)

(defstruct style-association
  (url)
  (predicate)
  (style)
  (style-file)
  (style-url))


(defvar *gopmacs-style-associations*
  (list
   (make-style-association
    :url "https://nyxt.atlas.engineer"
    :style (cl-css:css
            '((body :background-color "gray"))))
   (make-style-association
    :url "https://example.org"
    :style (cl-css:css
            '((body
               :background-color "black"))))))

(define-configuration
    nyxt/style-mode::dark-mode
  ((nyxt/style-mode::style-associations
    *gopmacs-style-associations*)))

(define-configuration (buffer web-buffer)
  ((default-modes (append '(style-mode) %slot-default))))
