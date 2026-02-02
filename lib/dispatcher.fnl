
;; lib/dispatcher.fnl
;; Routes events to subscribed behaviors.

(local {: into : mapv : hash-set : conj : filter} (require :io.gitlab.andreyorst.cljlib.core))
(local {: add-event-handler : event-hierarchy} (require :lib.event-bus))
(local {: behaviors-register : behavior-responds-to?} (require :lib.behavior-registry))
(local {: subscriptions-register} (require :lib.subscription-registry))
(local {: source-instance-exists?} (require :lib.source-registry))
(local {: ancestors} (require :lib.hierarchy))


(fn get-behaviors-for-source-event [source event-name]
  "Get behavior names for a source+event-name pair.
   Checks subscriptions for the source and all ancestor event-selectors.
   Filters to behaviors whose :respond-to includes the event-name (via isa?)."
  (let [event-selectors (conj (ancestors event-hierarchy event-name) event-name)
        source-subs (or (. subscriptions-register source) {})
        all-behavior-names (accumulate [result (hash-set)
                                        _ e (pairs event-selectors)]
                             (into result (or (. source-subs e) [])))]
    (filter (fn [name]
              (let [responds? (behavior-responds-to? name event-name)]
                (when (not responds?)
                  (print (.. "[ERROR] get-behaviors-for-source-event: behavior '"
                             (tostring name) "' does not respond to event '"
                             (tostring event-name) "'")))
                responds?))
            all-behavior-names)))


(fn get-behaviors-for-event [event]
  "Get all behaviors subscribed to this event's source+event-name."
  (let [source event.event-source
        event-name event.event-name]
    (when (not (source-instance-exists? source))
      (print (.. "[WARN] get-behaviors-for-event: unknown source instance '"
                 (tostring source) "'")))
    (let [behavior-names (get-behaviors-for-source-event source event-name)]
      (mapv (fn [name]
              (let [behavior (. behaviors-register name)]
                (when (= nil behavior)
                  (print (.. "[ERROR] get-behaviors-for-event: behavior '" (tostring name) "' not found in registry")))
                behavior))
            behavior-names))))


;; Register the dispatcher that routes events to subscribed behaviors
(add-event-handler
 :dispatcher/event-handler
 (fn [event]
   (let [bs (get-behaviors-for-event event)]
     (each [_ behavior (pairs bs)]
       (when behavior
         ((. behavior :fn) event))))))


{: get-behaviors-for-event}
