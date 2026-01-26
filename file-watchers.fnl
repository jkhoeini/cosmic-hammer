
(local {: mapv : assoc} (require :io.gitlab.andreyorst.cljlib.core))

(local {: dispatch-event : tag-events} (require :events))
(local {: register-behavior} (require :behaviors))
(local notify (require :notify))


(tag-events :file-watchers.events/file-change :file-watchers
            [:file-watchers.tags/file-change])


(fn handle-reload [files attrs]
  (let [evs (mapv #(assoc $1 :file-path $2) attrs files)]
    (each [_ ev (ipairs evs)]
      (dispatch-event :file-watchers.events/file-change :file-watchers ev))))


(local my-watcher (hs.pathwatcher.new hs.configdir handle-reload))
(global file-watchers/path-watcher (my-watcher:start))


(var reloading? false)
(local reload (hs.timer.delayed.new 0.5 hs.reload))

(register-behavior
 :file-watchers.behaviors/reload-hammerspoon
 "When init.lua changes, reload hammerspoon."
 [:file-watchers.tags/file-change]
 (fn [file-change-event]
   (let [path (?. file-change-event :event-data :file-path)]
      (when (and (not reloading?)
                 (not= nil path)
                 (= ".hammerspoon/init.lua" (path:sub -21)))
        (notify.warn "Reloading...")
        (reload:start)))))


(register-behavior
 :file-watchers.behaviors/hammerspoon-compile-fennel
 "Watch fennel files in hammerspoon folder and recompile them."
 [:file-watchers.tags/file-change]
 (fn [file-change-event]
   (let [path (?. file-change-event :event-data :file-path)]
     (when (and (not= nil path)
                (= ".fnl" (path:sub -4)))
       (print (hs.execute "./compile.sh" true))))))


{}
