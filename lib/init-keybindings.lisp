(defvar *gopnyxt-keymap* (make-keymap "gopnyxt-map"))

(define-key *gopnyxt-keymap*
  "C-f" 'nyxt/web-mode:history-forwards
  "C-b" 'nyxt/web-mode:history-backwards
  "C-s a" 'nyxt/web-mode:search-buffers
  "C-x r m" 'bookmark-current-page
  "C-x r b" 'set-url-from-bookmark
  "C-x r B" 'set-url-from-bookmark-new-buffer
  "C-x r l" 'list-bookmarks
  "C-x C-e" 'fill-input-from-external-editor)

(define-mode gopnyxt-mode ()
  ((keymap-scheme (keymap:make-scheme
                   scheme:emacs *gopnyxt-keymap*))))

(define-configuration (buffer web-buffer)
  ((default-modes (append '(gopnyxt-mode) %slot-default))))
