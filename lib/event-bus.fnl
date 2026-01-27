(local fnl (require :fennel))
(local {: hash-set : conj} (require :io.gitlab.andreyorst.cljlib.core))


(comment example-event
  {:timestamp  0
   :event-name :window-move
   :origin     :windows-watcher
   :event-tags #{:some-tag :another-tag}
   :event-data {:window-id 123
                :x 10
                :y 20}})


;; {event-name -> #{tags}}
(local event-tags {})

(fn tag-event [event-name tag]
  (when (= nil (. event-tags event-name))
    (tset event-tags event-name (hash-set)))
  (tset event-tags event-name (conj (. event-tags event-name) tag)))


(local event-handlers [])

(fn add-event-handler [handler]
  (let [idx (+ 1 (length event-handlers))]
    (table.insert event-handlers handler)
    #(tset event-handlers idx nil)))


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


(fn dispatch-event [event-name origin event-data]
  (let [event {:timestamp (hs.timer.secondsSinceEpoch)
               : event-name : origin : event-data
               :event-tags (or (. event-tags event-name) (hash-set))}]
    (table.insert events-queue event)
    (when (not processing?) (process-events))))


(add-event-handler
 (fn [event]
   (when (. _G :event-bus.debug-mode?)
     (print "got event" (fnl.view event)))))


{: tag-event
 : add-event-handler
 : dispatch-event}
