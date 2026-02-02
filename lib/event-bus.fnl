(local {: some : seq} (require :lib.cljlib-shim))
(local {: make-hierarchy : descendants} (require :lib.hierarchy))


(comment example-event
  {:timestamp  0
   :event-name :window-move
   :event-source :windows-watcher
   :event-data {:window-id 123
                :x 10
                :y 20}})


;; {event-name -> {:description string :schema {field-name -> validator-fn}}}
(local events-register {})

;; Event hierarchy for event-kind relationships
(local event-hierarchy (make-hierarchy))

(fn define-event [event-name description schema]
  (when (not= nil (. events-register event-name))
    (error (.. "Event already registered: " (tostring event-name))))
  (tset events-register event-name {:description description :schema schema}))

(fn event-defined? [event-name]
  "Check if an event has been defined."
  (not= nil (. events-register event-name)))

(fn valid-event-selector? [selector]
  "Check if an event-selector is valid:
   - It's a defined event, OR
   - It has descendants that are defined events (it's an event-kind)"
  (or (event-defined? selector)
      (some event-defined? (seq (descendants event-hierarchy selector)))))


(local event-handlers {})

(fn add-event-handler [key handler]
  (when (not= nil (. event-handlers key))
    (error (.. "Event handler already registered: " (tostring key))))
  (tset event-handlers key handler))

(fn remove-event-handler [key]
  (tset event-handlers key nil))


(var processing? false)
(var events-queue [])

(fn process-events []
  (set processing? true)
  (while (< 0 (length events-queue))
    (let [events events-queue]
      (set events-queue [])
      (each [_ event (ipairs events)]
        (each [_ handler (pairs event-handlers)]
          (handler event)))))
  (set processing? false))


(fn dispatch-event [event-name event-source event-data]
  (when (= nil (. events-register event-name))
    (print (.. "[WARN] dispatch-event: event '" (tostring event-name) "' not registered")))
  (let [event {:timestamp (hs.timer.secondsSinceEpoch)
               : event-name : event-source : event-data}]
    (table.insert events-queue event)
    (when (not processing?) (process-events))))


(add-event-handler
 :event-bus/debug-handler
 (fn [event]
   (when (. _G :event-bus.debug-mode?)
     (print "got event" (hs.inspect event)))))


{: define-event
 : event-defined?
 : valid-event-selector?
 : event-hierarchy
 : add-event-handler
 : remove-event-handler
 : dispatch-event}
