
;; event_sources/init.fnl
;; Create source registry, load source types, and create instances.

(local {: make-source-registry : add-source-type! : start-event-source!} (require :lib.source-registry))
(local {: event-registry} (require :events))
(local {: file-watcher-source-type} (require :event_sources.file-watcher))
(local {: hotkey-source-type} (require :event_sources.hotkey))


;; Create source registry
(local source-registry (make-source-registry {:event-registry event-registry}))


;; Register source types
(add-source-type! source-registry file-watcher-source-type)
(add-source-type! source-registry hotkey-source-type)


;; Create source instances
(start-event-source! source-registry
                     :event-source.file-watcher/config-dir
                     :event-source.type/file-watcher
                     {:path hs.configdir})


{: source-registry}
