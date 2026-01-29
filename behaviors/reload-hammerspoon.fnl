
(local {: define-behavior} (require :lib.behavior-registry))
(local notify (require :notify))


(var reloading? false)
(local reload (hs.timer.delayed.new 0.5 hs.reload))


(define-behavior
 :reload-hammerspoon.behaviors/reload-hammerspoon
 "When init.lua changes, reload hammerspoon."
 [:event.kind.fs/file-change]
 (fn [file-change-event]
   (let [path (?. file-change-event :event-data :file-path)]
     (when (and (not reloading?)
                (not= nil path)
                (= ".hammerspoon/init.lua" (path:sub -21)))
       (set reloading? true)
       (notify.warn "Reloading...")
       (reload:start)))))


{}
