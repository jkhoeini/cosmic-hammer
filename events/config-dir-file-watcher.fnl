
(local {: mapv : assoc} (require :io.gitlab.andreyorst.cljlib.core))

(local {: dispatch-event : tag-event} (require :lib.event-bus))


(tag-event :config-dir-file-watcher.events/file-change
           :config-dir-file-watcher.tags/file-change)


(fn handle-file-change [files attrs]
  (let [evs (mapv #(assoc $1 :file-path $2) attrs files)]
    (each [_ ev (ipairs evs)]
      (dispatch-event
       :config-dir-file-watcher.events/file-change
       :config-dir-file-watcher
       ev))))


(local watcher (hs.pathwatcher.new hs.configdir handle-file-change))
(global config-dir-file-watcher/path-watcher (watcher:start))


{}
