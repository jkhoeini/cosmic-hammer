
(local {: mapv : assoc : string?} (require :io.gitlab.andreyorst.cljlib.core))

(local {: register-event : dispatch-event} (require :lib.event-bus))
(local {: derive} (require :lib.hierarchy))


(register-event :config-dir-file-watcher.events/file-change
                "File change detected in hammerspoon config directory"
                {:file-path string?})

(derive :config-dir-file-watcher.events/file-change :event.kind.fs/file-change)


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
