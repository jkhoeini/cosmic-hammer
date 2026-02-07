
;; lib/event-loop.fnl
;; Event queue processing loop.
;;
;; Provides timer-based event processing that drains the event queue.
;; The event-registry is passed in, keeping this module stateless except for the timer.

(var event-loop-timer nil)
(var current-registry nil)


(fn process-event! [registry]
  "Process one event from the queue.
   Pops the first event and runs it through all handlers.
   Returns true if an event was processed, false if queue was empty."
  (if (< 0 (length registry.queue))
      (let [event (table.remove registry.queue 1)]
        (each [_ handler (pairs registry.handlers)]
          (handler event))
        true)
      false))


(fn start-event-loop! [registry]
  "Start timer-based event processing loop.
   Timer fires every 10ms and drains the queue completely."
  (set current-registry registry)
  (when event-loop-timer
    (event-loop-timer:stop))
  (set event-loop-timer
       (hs.timer.new 0.01
                     (fn []
                       (while (process-event! current-registry)
                         nil))))
  (event-loop-timer:start)
  (print "[INFO] Event loop started"))


(fn stop-event-loop! []
  "Stop the event processing loop."
  (when event-loop-timer
    (event-loop-timer:stop)
    (set event-loop-timer nil)
    (set current-registry nil)
    (print "[INFO] Event loop stopped")))


{: process-event!
 : start-event-loop!
 : stop-event-loop!}
