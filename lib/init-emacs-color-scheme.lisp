;;;; Taken from Kssytrk (GPL):  https://github.com/kssytsrk/.nyxt.d/blob/master/theme.lisp

;;;; the code in this file copies all colors from Emacs, hence its working name
;;;; is "emacs-colorscheme-theme"
;;;; for me it worked and looked fine with multiple themes, but it's sort of a
;;;; Russian roulette

;;;; to use all of this, you need to have Emacs and emacs server runnning at the
;;;; time of opening the browser: in Emacs, execute
;;;; M-x server-start RET

(in-package :nyxt-user)

(defun emacs-face-attribute (face attribute)
  (string-trim "\"" (uiop:run-program (concatenate 'string
                                                   "emacsclient -e \"(face-attribute '"
                                                   (string-downcase (string face))
                                                   " :"
                                                   (string-downcase (string attribute))
                                                   " nil t)\"")
                                      :output '(:string :stripped t))))

(let ((bg (emacs-face-attribute 'default :background))
      (fg (emacs-face-attribute 'default :foreground))
      (mlbg (emacs-face-attribute 'mode-line :background)) ;; modeline bg
      (mlfg (emacs-face-attribute 'mode-line :foreground))
      ;;(ml-inactive-bg (emacs-face-attribute 'mode-line-inactive :background))
      ;;(ml-inactive-fg (emacs-face-attribute 'mode-line-inactive :foreground))
      (ml-highlight-fg
        (getf (read-from-string (emacs-face-attribute 'mode-line-highlight :box))
              :color))
      (h1 (emacs-face-attribute 'outline-2 :foreground))
      (h2 (emacs-face-attribute 'outline-3 :foreground))
      (h3 (emacs-face-attribute 'outline-4 :foreground))
      (h4 (emacs-face-attribute 'outline-5 :foreground))
      (h5 (emacs-face-attribute 'outline-6 :foreground))
      (h6 (emacs-face-attribute 'outline-7 :foreground))
      (a (emacs-face-attribute 'link :foreground))
      (hrfg (emacs-face-attribute 'window-divider :foreground))
      (cursor (emacs-face-attribute 'cursor :background))
      (mode-line-fg (emacs-face-attribute 'mode-line :foreground))
      (mode-line-bg (emacs-face-attribute 'mode-line :background))
      (mb-prompt (emacs-face-attribute 'minibuffer-prompt :foreground)) ; minibuffer prompt
      (mb-selection (emacs-face-attribute 'ivy-current-match :background))
      (mb-separator (emacs-face-attribute 'ivy-current-match :foreground)))

  ;; minibuffer (bg and fg colors)
  (defun override (color)
    (concatenate 'string color " !important"))

  (define-configuration prompt-buffer
      ((style
        (str:concat
         %slot-default%
         (cl-css:css
          `((body
             :border-top ,(str:concat "1px solid" mb-separator)
             :background-color ,(override bg)
             :color ,(override fg))
            (".source"
             :background-color ,(override bg)
             :color ,(override fg))
            (".source-name"
             :background-color ,(override bg)
             :color ,(override fg))
            (".source-content"
             :background-color ,(override bg)
             :color ,(override fg))
            (".source-content th"
             :background-color ,(override mode-line-bg)
             :color ,(override mode-line-fg))
            ("#input"
             :background-color ,(override bg)
             :color ,(override fg)
             :border-bottom ,(str:concat "solid 1px " mb-separator))
            ("#cursor"
             :background-color ,(override cursor)
             :color ,(override fg))
            ("#prompt"
             :color ,(override mb-prompt))
            (.marked
             :background-color ,(override mb-selection)
             :color ,(if (equal mb-selection fg)
                         (override bg)
                         (override fg)))
            ("#selection"
             :background-color ,(override mb-selection)
             :color ,(if (equal mb-selection fg)
                         (override bg)
                         (override fg)))
            (.selected
             :background-color ,(override mb-selection)
             :color ,(if (equal mb-selection fg)
                         (override bg)
                         (override fg)))))))))

  (define-configuration window
      ((message-buffer-style
        (str:concat
         %slot-default%
         (cl-css:css
          `((body
             :border-top ,(str:concat "1px solid" mb-separator)
             :background-color ,(override bg)
             :color ,(override fg))))))))
  



  ;; internal buffers (help, list, etc)
  (define-configuration internal-buffer
      ((style
        (str:concat
         %slot-default%
         (cl-css:css
          `((body
             :background-color ,(override bg)
             :color ,(override fg))
            (hr
             :background-color ,(override bg)
             :color ,(override hrfg))
            (.button
             :background-color ,(override mlbg)
             :color ,(override mlfg))
            (".button:hover"
             :color ,(override ml-highlight-fg))
            (".button:active"
             :color ,(override ml-highlight-fg))
            (".button:visited"
             :color ,(override ml-highlight-fg))
            (a
             :color ,(override a))
            (h1
             :color ,(override h1))
            (h2
             :color ,(override h2))
            (h3
             :color ,(override h3))
            (h4
             :color ,(override h4))
            (h5
             :color ,(override h5))
            (h6
             :color ,(override h6))))))))


  ;; colorscheme for websites/web-buffers, turn on with
  (define-configuration web-buffer
  ((default-modes (append '(emacs-colorscheme-mode)
                          %slot-default%))))

  (nyxt::define-bookmarklet-command apply-emacs-colorscheme
    "Modify the page with Emacs's colors"
    (str:concat "javascript:document.querySelectorAll('*').forEach(e=> { e.setAttribute('style','background-color:" bg " !important;color:'+(/^A|BU/.test(e.tagName)?" "'" a ";':'" fg ";')+e.getAttribute('style')); /*e.style.fontFamily='Anonymous Pro,serif'; */ } )"))

  (define-mode emacs-colorscheme-mode (nyxt/style-mode:style-mode)
    "Mode that styles the page to match the user's Emacs theme."
    ((style (cl-css:css
             `((hr
                :color ,(override hrfg))
               (.button
                :background-color ,(override mlbg)
                :color ,(override mlfg))
               (".button:hover"
                :color ,(override ml-highlight-fg))
               (".button:active"
                :color ,(override ml-highlight-fg))
               (".button:visited"
                :color ,(override ml-highlight-fg))
               (a
                :color ,(override a))
               (h1
                :color ,(override h1))
               (h2
                :color ,(override h2))
               (h3
                :color ,(override h3))
               (h4
                :color ,(override h4))
               (h5
                :color ,(override h5))
               (h6
                :color ,(override h6)))))
     (constructor
      (lambda (mode)
        (nyxt/style-mode::initialize mode)))))

  (defmethod nyxt/style-mode::apply-style ((mode emacs-colorscheme-mode))
    (if (style mode)
        (apply-emacs-colorscheme)
        (nyxt::html-set-style (style mode) (buffer mode))))

  (defun apply-emacs-colorscheme-handler ()
    (if (and (web-buffer-p (current-buffer))
             (find-submode (current-buffer)
                           'emacs-colorscheme))
        (apply-emacs-colorscheme))))


(hooks:add-hook nyxt/web-mode:unzoom-page-after-hook
                (hooks:make-handler-void #'apply-emacs-colorscheme-handler))
(hooks:add-hook nyxt::reload-current-buffer-after-hook
                (hooks:make-handler-void #'apply-emacs-colorscheme-handler))
