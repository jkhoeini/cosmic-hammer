
;; Load all behavior modules (registration only)

(require :behaviors.reload-hammerspoon)
(require :behaviors.compile-fennel)


;; Centralized subscriptions
(local {: subscribe} (require :lib.subscription-registry))

(subscribe
 :reload-hammerspoon.behaviors/reload-hammerspoon
 :event-source.file-watcher/config-dir
 :event.kind.fs/file-change)

(subscribe
 :compile-fennel.behaviors/compile-fennel
 :event-source.file-watcher/config-dir
 :event.kind.fs/file-change)


{}
