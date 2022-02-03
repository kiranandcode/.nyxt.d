;;; Those are settings that every type of buffer should share.
(define-configuration (buffer internal-buffer editor-buffer prompt-buffer)
  ;; Emacs keybindings.
  ((default-modes `(emacs-mode ,@%slot-default%))
   ;; everything to be a bit zoomed-in.
   (current-zoom-ratio 1.25)))

(define-configuration browser
  ;; This is for Nyxt to never prompt me about restoring the previous session.
  ((session-restore-prompt :never-restore)
  ;; external editor is the one true editor
   (external-editor-program (list "emacsclient"))))
