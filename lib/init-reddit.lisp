(in-package :nyxt-user)

(defun old-reddit-handler (request-data)
  (let ((url (url request-data)))
    (setf (url request-data)
          (if (search "reddit.com" (quri:uri-host url))
              (progn
                (setf (quri:uri-host url) "old.reddit.com")
                (log:info "Switching to old Reddit: ~s" (object-display url))
                url)
              url)))
  request-data)
(use-package :nyxt)

(define-configuration web-buffer
  ((request-resource-hook
    (hooks:add-hook %slot-default (make-handler-resource #'old-reddit-handler)))))
