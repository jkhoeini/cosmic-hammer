(local fnl (require :fennel))
(local {: hash-set : conj} (require :io.gitlab.andreyorst.cljlib.core))
(local {: derive} (require :lib.hierarchy))


(comment example-event
  {:timestamp  0
   :event-name :window-move
   :event-source :windows-watcher
   :event-tags #{:some-tag :another-tag}
   :event-data {:window-id 123
                :x 10
                :y 20}})


;; {event-name -> {:description string :schema {field-name -> validator-fn}}}
(local event-registry {})

(fn register-event [event-name description schema]
  (when (not= nil (. event-registry event-name))
    (error (.. "Event already registered: " (tostring event-name))))
  (tset event-registry event-name {:description description :schema schema})
  (derive event-name :event/any))


;; {event-name -> #{tags}}
(local event-tags {})

(fn tag-event [event-name tag]
  (when (= nil (. event-registry event-name))
    (print (.. "[WARN] tag-event: event '" (tostring event-name) "' not registered")))
  (when (= nil (. event-tags event-name))
    (tset event-tags event-name (hash-set)))
  (tset event-tags event-name (conj (. event-tags event-name) tag))
  (derive tag :tag/any))


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
  (when (= nil (. event-registry event-name))
    (print (.. "[WARN] dispatch-event: event '" (tostring event-name) "' not registered")))
  (let [event {:timestamp (hs.timer.secondsSinceEpoch)
               : event-name : event-source : event-data
               :event-tags (or (. event-tags event-name) (hash-set))}]
    (table.insert events-queue event)
    (when (not processing?) (process-events))))


(add-event-handler
 :event-bus/debug-handler
 (fn [event]
   (when (. _G :event-bus.debug-mode?)
     (print "got event" (fnl.view event)))))


{: register-event
 : tag-event
 : add-event-handler
 : remove-event-handler
 : dispatch-event}
