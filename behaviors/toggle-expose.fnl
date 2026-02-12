
;; behaviors/toggle-expose.fnl
;; Exports behavior data (pure, no registry dependency)

(local {: make-behavior} (require :lib.behavior-registry))


(local expose (hs.expose.new))


(local toggle-expose-behavior
  (make-behavior
   :expose.behaviors/toggle-expose
   "Toggle the Hammerspoon Expose window picker"
   [:event.kind.hotkey/pressed]
   (fn [event]
     (expose:toggleShow))))


{: toggle-expose-behavior}
