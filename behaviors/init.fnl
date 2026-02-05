
;; Load all behavior modules (registration only)

(require :behaviors.reload-hammerspoon)
(require :behaviors.compile-fennel)


;; Centralized subscriptions
(local {: define-subscription} (require :lib.subscription-registry))

(define-subscription
 :sub/reload-on-config-change
 {:description "Reload Hammerspoon when init.lua changes"
  :behavior :reload-hammerspoon.behaviors/reload-hammerspoon
  :source-selector :event-source.file-watcher/config-dir
  :event-selector :event.kind.fs/file-change})

(define-subscription
 :sub/compile-on-fnl-change
 {:description "Recompile Fennel when .fnl files change"
  :behavior :compile-fennel.behaviors/compile-fennel
  :source-selector :event-source.file-watcher/config-dir
  :event-selector :event.kind.fs/file-change})


{}
