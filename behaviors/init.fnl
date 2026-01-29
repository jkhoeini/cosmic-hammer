
;; Load all behavior modules (registration only)

(require :behaviors.reload-hammerspoon)
(require :behaviors.compile-fennel)


;; Centralized subscriptions
(local {: subscribe} (require :lib.behavior-registry))

(subscribe
 :reload-hammerspoon.behaviors/reload-hammerspoon
 :config-dir-file-watcher
 :event.kind.fs/file-change)

(subscribe
 :compile-fennel.behaviors/compile-fennel
 :config-dir-file-watcher
 :event.kind.fs/file-change)


{}
