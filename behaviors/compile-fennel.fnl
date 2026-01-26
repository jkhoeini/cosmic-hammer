
(local {: register-behavior} (require :lib.behavior-registry))


(register-behavior
 :compile-fennel.behaviors/compile-fennel
 "Watch fennel files in hammerspoon folder and recompile them."
 [:config-dir-file-watcher.tags/file-change]
 (fn [file-change-event]
   (let [path (?. file-change-event :event-data :file-path)]
     (when (and (not= nil path)
                (= ".fnl" (path:sub -4)))
       (print (hs.execute "./compile.sh" true))))))


{}
