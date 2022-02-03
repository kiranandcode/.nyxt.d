;;; Redirecting to privacy focused alternatives

(defvar *custom-request-resource-handlers*
    (list
     #'nx-freestance-handler:invidious-handler
     #'nx-freestance-handler:nitter-handler
     #'nx-freestance-handler:nitter-handler
     #'nx-freestance-handler:bibliogram-handler
     #'nx-freestance-handler:teddit-handler))

(define-configuration web-buffer
  ((request-resource-hook
    (reduce #'hooks:add-hook
            (mapcar #'make-handler-resource
		    *custom-request-resource-handlers*)
            :initial-value %slot-default%))))
