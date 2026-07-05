
;; components/reload-hammerspoon.fnl
;; Component type: Hammerspoon config reloader with debounce timer

(local {: make-component-type} (require :sheaf.component-registry))

(local reload-hammerspoon-type
  (make-component-type
   :component.type/reload-hammerspoon
   "Hammerspoon config reloader with debounce timer"
   {:traits [:trait/has-delayed-timer]
    :start-fn (fn [config]
                ;; Flush telemetry before reloading. pcall guards the flush so a
                ;; flush failure or timeout can never prevent hs.reload from running.
                {:timer (hs.timer.delayed.new 0.5
                                              (fn []
                                                (pcall hs.opentelemetry.flush 2)
                                                (hs.reload)))
                 :reloading? false})
    :stop-fn (fn [state]
               (state.timer:stop))}))

{: reload-hammerspoon-type}
