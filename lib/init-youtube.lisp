
(defun youtube-dl-url (&optional url)
  "Run 'youtube-dl' over the URL.
If URL is nil, use URL at point."
  (interactive)
  (setq url (or url (thing-at-point-url-at-point)))
  (let ((eshell-buffer-name "*youtube-dl*")
        (directory (cl-loop for dir in '("~/Videos" "~/Downloads")
                            when (file-directory-p dir)
                            return (expand-file-name dir)
                            finally return "."))
    (eshell)
    (when (eshell-interactive-process)
      (eshell t))
    (eshell-interrupt-process)
    (insert (format "cd '%s' && youtube-dl " directory) url)
    (eshell-send-input)))
