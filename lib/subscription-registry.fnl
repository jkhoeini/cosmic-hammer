
;; lib/subscription-registry.fnl
;; Manages subscriptions connecting behaviors to source+event-selector pairs.

(local {: hash-set : disj : conj} (require :lib.cljlib-shim))
(local {: valid-event-selector?} (require :lib.event-bus))
(local {: behaviors-register} (require :lib.behavior-registry))
(local {: source-instance-exists?} (require :lib.source-registry))


;; {source -> {event-selector -> #{behavior-names}}}
(local subscriptions-register {})


(fn subscribe [behavior-name source event-selector]
  "Subscribe a behavior to respond to events matching event-selector.
   event-selector can be a specific event-name or an ancestor (e.g. :event.kind/any)."
  (when (= nil (. behaviors-register behavior-name))
    (print (.. "[WARN] subscribe: behavior '" (tostring behavior-name) "' not found in registry")))
  (when (not (source-instance-exists? source))
    (print (.. "[WARN] subscribe: source instance '" (tostring source) "' not found")))
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


{: subscriptions-register
 : subscribe
 : unsubscribe}
