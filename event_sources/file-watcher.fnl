
;; event_sources/file-watcher.fnl
;; Event source: watches ~/.hammerspoon for file changes

(local {: mapv : assoc} (require :io.gitlab.andreyorst.cljlib.core))
(local {: dispatch-event} (require :lib.event-bus))


(fn handle-file-change [files attrs]
  (let [evs (mapv #(assoc $1 :file-path $2) attrs files)]
    (each [_ ev (ipairs evs)]
      (dispatch-event
       :file-watcher.events/file-change
       :file-watcher
       ev))))


(local watcher (hs.pathwatcher.new hs.configdir handle-file-change))
(global file-watcher/path-watcher (watcher:start))


{}
