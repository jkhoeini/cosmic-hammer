
;; Load all behavior modules (registration only)

(require :behaviors.reload-hammerspoon)
(require :behaviors.compile-fennel)


;; Centralized subscriptions
(local {: subscribe-behavior} (require :lib.behavior-registry))

(subscribe-behavior
 :reload-hammerspoon.behaviors/reload-hammerspoon
 :config-dir-file-watcher
 :event.kind.fs/file-change)

(subscribe-behavior
 :compile-fennel.behaviors/compile-fennel
 :config-dir-file-watcher
 :event.kind.fs/file-change)


{}
