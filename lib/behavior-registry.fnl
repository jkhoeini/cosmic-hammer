(local {: into : mapv : hash-set : disj : conj : filter : some} (require :io.gitlab.andreyorst.cljlib.core))
(local {: add-event-handler : event-defined?} (require :lib.event-bus))
(local {: ancestors : descendants : isa?} (require :lib.hierarchy))


(local behaviors-register {})

(fn valid-event-selector? [selector]
  "Check if an event-selector is valid:
   - It's a defined event, OR
   - It has descendants that are defined events (it's an event-kind)"
  (or (event-defined? selector)
      (some event-defined? (descendants selector))))

(fn define-behavior [name desc event-selectors f]
  "Register a behavior with its event-selectors (event-names or ancestors).
   Does not subscribe to any events.
   Use subscribe to activate for specific source+event-selector pairs."
  ;; Validate event-selectors
  (each [_ selector (ipairs event-selectors)]
    (when (not (valid-event-selector? selector))
      (print (.. "[WARN] define-behavior: event-selector '"
                 (tostring selector) "' in behavior '"
                 (tostring name) "' has no matching defined events"))))
  (let [behavior {:name name
                  :description desc
                  :respond-to event-selectors
                  :fn f}]
    (tset behaviors-register name behavior)))


;; {source -> {event-selector -> #{behavior-names}}}
(local subscriptions-register {})

;; TODO: consider accepting a set of event-selectors for more flexibility
(fn subscribe [behavior-name source event-selector]
  "Subscribe a behavior to respond to events matching event-selector.
   event-selector can be a specific event-name or an ancestor (e.g. :event.kind/any)."
  (when (= nil (. behaviors-register behavior-name))
    (print (.. "[WARN] subscribe: behavior '" (tostring behavior-name) "' not found in registry")))
  (when (not (valid-event-selector? event-selector))
    (print (.. "[WARN] subscribe: event-selector '" (tostring event-selector)
               "' has no matching defined events")))
  (when (= nil (. subscriptions-register source))
    (tset subscriptions-register source {}))
  (when (= nil (. subscriptions-register source event-selector))
    (tset subscriptions-register source event-selector (hash-set)))
  (tset subscriptions-register source event-selector
        (conj (. subscriptions-register source event-selector) behavior-name)))


(fn unsubscribe [behavior-name source event-selector]
  "Unsubscribe a behavior from a specific source+event-selector pair."
  (let [behavior-set (?. subscriptions-register source event-selector)]
    (when behavior-set
      (tset subscriptions-register source event-selector
            (disj behavior-set behavior-name)))))


(fn behavior-responds-to? [behavior-name event-name]
  "Check if behavior's :respond-to selectors match the given event-name (via isa?)."
  (let [behavior (. behaviors-register behavior-name)]
    (if (= nil behavior)
        false
        (some #(isa? event-name $) (. behavior :respond-to)))))


(fn get-behaviors-for-source-event [source event-name]
  "Get behavior names for a source+event-name pair, including ancestors of both.
   Filters to behaviors whose :respond-to includes the event-name (via isa?)."
  (let [sources (conj (ancestors source) source)
        event-selectors (conj (ancestors event-name) event-name)
        all-behavior-names (accumulate [result (hash-set)
                                        _ s (pairs sources)]
                             (accumulate [r result
                                          _ e (pairs event-selectors)]
                               (into r (or (?. subscriptions-register s e) []))))]
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
        event-name event.event-name
        behavior-names (get-behaviors-for-source-event source event-name)]
    (mapv (fn [name]
            (let [behavior (. behaviors-register name)]
              (when (= nil behavior)
                (print (.. "[ERROR] get-behaviors-for-event: behavior '" (tostring name) "' not found in registry")))
              behavior))
          behavior-names)))


;; TODO: consider pausing for global source/event-selector/behavior or
;; specific subscription
(add-event-handler
 :behavior-registry/dispatcher
 (fn [event]
   (let [bs (get-behaviors-for-event event)]
     (each [_ behavior (pairs bs)]
       (when behavior
         ((. behavior :fn) event))))))


{: define-behavior
 : subscribe
 : unsubscribe}
