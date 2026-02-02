
;; event_sources/init.fnl
;; Load event source type definitions and create instances.

(local {: start-event-source} (require :lib.source-registry))

;; Load source type definitions
(require :event_sources.file-watcher)


;; Create source instances
(start-event-source
 :event-source.file-watcher/config-dir
 :event-source.type/file-watcher
 {:path hs.configdir})


{}
