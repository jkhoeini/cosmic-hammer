
;; lib/dispatcher.fnl
;; Routes events to subscribed behaviors.

(local {: mapv : filter : seq} (require :lib.cljlib-shim))
(local {: add-event-handler} (require :lib.event-bus))
(local {: behaviors-register : behavior-responds-to?} (require :lib.behavior-registry))
(local {: get-subscribed-behaviors} (require :lib.subscription-registry))
(local {: source-instance-exists?} (require :lib.source-registry))


(fn get-behaviors-for-event [event]
  "Get all behaviors for this event, resolved from registry."
  (when (not (source-instance-exists? event.event-source))
    (print (.. "[WARN] get-behaviors-for-event: unknown source instance '"
               (tostring event.event-source) "'")))
  (let [behavior-names (or (get-subscribed-behaviors event.event-source event.event-name) [])
        ;; Filter to behaviors that actually respond to this event-name
        valid-names (filter (fn [name]
                              (let [responds? (behavior-responds-to? name event.event-name)]
                                (when (not responds?)
                                  (print (.. "[ERROR] get-behaviors-for-event: behavior '"
                                             (tostring name) "' does not respond to event '"
                                             (tostring event.event-name) "'")))
                                responds?))
                            behavior-names)]
    (mapv (fn [name]
            (let [behavior (. behaviors-register name)]
              (when (= nil behavior)
                (print (.. "[ERROR] get-behaviors-for-event: behavior '"
                           (tostring name) "' not found in registry")))
              behavior))
          (or (seq valid-names) []))))


;; Register the dispatcher that routes events to subscribed behaviors
(add-event-handler
 :dispatcher/event-handler
 (fn [event]
   (let [bs (get-behaviors-for-event event)]
     (each [_ behavior (pairs bs)]
       (when behavior
         ((. behavior :fn) event))))))


{: get-behaviors-for-event}
