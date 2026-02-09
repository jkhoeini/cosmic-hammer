
;; subscriptions/init.fnl
;; Creates subscription registry and wires behaviors to event sources.

(local {: make-subscription-registry : define-subscription!} (require :lib.subscription-registry))
(local {: event-registry} (require :events))
(local {: behavior-registry} (require :behaviors))
(local {: source-registry} (require :event_sources))

;; Create subscription registry
(local subscription-registry
  (make-subscription-registry {:event-registry event-registry
                               :behavior-registry behavior-registry
                               :source-registry source-registry}))

(define-subscription! subscription-registry
 :sub/reload-on-config-change
 {:description "Reload Hammerspoon when init.lua changes"
  :behavior :reload-hammerspoon.behaviors/reload-hammerspoon
  :source-selector :event-source.file-watcher/config-dir
  :event-selector :event.kind.fs/file-change})

(define-subscription! subscription-registry
 :sub/compile-on-fnl-change
 {:description "Recompile Fennel when .fnl files change"
  :behavior :compile-fennel.behaviors/compile-fennel
  :source-selector :event-source.file-watcher/config-dir
  :event-selector :event.kind.fs/file-change})

{: subscription-registry}
