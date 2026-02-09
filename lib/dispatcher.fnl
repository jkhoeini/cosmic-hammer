
;; lib/dispatcher.fnl
;; Behavior routing for events.
;;
;; This module provides the logic for routing events to subscribed behaviors.
;; Registers handlers as a side effect when required.

(local {: mapv : filter : seq} (require :lib.cljlib-shim))
(local {: event-registry} (require :events))
(local {: add-event-handler!} (require :lib.event-registry))
(local {: behavior-responds-to? : get-behavior} (require :lib.behavior-registry))
(local {: get-subscribed-behaviors} (require :lib.subscription-registry))
(local {: source-registry} (require :event_sources))
(local {: source-instance-exists?} (require :lib.source-registry))


(fn get-behaviors-for-event [behavior-registry subscription-registry event]
  "Get all behaviors for this event, resolved from registry."
  (when (not (source-instance-exists? source-registry event.event-source))
    (print (.. "[WARN] get-behaviors-for-event: unknown source instance '"
               (tostring event.event-source) "'")))
  (let [behavior-names (or (get-subscribed-behaviors subscription-registry event.event-source event.event-name) [])
        ;; Filter to behaviors that actually respond to this event-name
        valid-names (filter (fn [name]
                              (let [responds? (behavior-responds-to? behavior-registry name event.event-name)]
                                (when (not responds?)
                                  (print (.. "[ERROR] get-behaviors-for-event: behavior '"
                                             (tostring name) "' does not respond to event '"
                                             (tostring event.event-name) "'")))
                                responds?))
                            behavior-names)]
    (mapv (fn [name]
            (let [behavior (get-behavior behavior-registry name)]
              (when (= nil behavior)
                (print (.. "[ERROR] get-behaviors-for-event: behavior '"
                           (tostring name) "' not found in registry")))
              behavior))
          (or (seq valid-names) []))))


;; Register handlers (side effect at require time)
(add-event-handler! event-registry :dispatcher/behavior-router
                    (fn [event]
                      ;; Lazy require to avoid circular dependency
                      (let [{: behavior-registry} (require :behaviors)
                            {: subscription-registry} (require :subscriptions)
                            bs (get-behaviors-for-event behavior-registry subscription-registry event)]
                        (each [_ behavior (pairs bs)]
                          (when behavior
                            ((. behavior :fn) event))))))

(add-event-handler! event-registry :dispatcher/debug-handler
                    (fn [event]
                      (when (. _G :event-bus.debug-mode?)
                        (print "got event" (hs.inspect event)))))


{}
