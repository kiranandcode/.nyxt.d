(in-package :nyxt-user)

(ps:ps
  (ps:let ((paper-map (ps:create))
           (papers (ps:chain document
                             (query-selector-all ".gs_scl.gs_or.gs_r"))))
    (ps:for ((i 0)) ((< i (length papers))) ((incf i))
            (ps:let*
                ((paper (ps:getprop papers i))
                 (url (ps:@ (ps:chain paper
                                      (query-selector ".gs_ri > .gs_fl"))
                            children 2
                            href))
                 (id (ps:chain (-reg-exp ".*scholar\\?cites=([0-9]+)&.*")
                               (exec url))))
              (ps:if (not id) ps:continue)
              (ps:setq id (ps:getprop id 1))
              (ps:setf (ps:getprop paper-map id) paper)
              ))
    paper-map
    ))


(define-class paper-annotation (nyxt:annotation)
  ((data ""
    :documentation "The annotation text.")
   (tags '()
    :type list-of-strings)
   (date (local-time:now)))
  (:export-class-name-p t)
  (:export-accessor-names-p t)
  (:accessor-name-transformer (class*:make-name-transformer name)))



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
