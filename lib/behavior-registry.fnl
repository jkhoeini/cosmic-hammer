
;; lib/behavior-registry.fnl
;; Manages behavior definitions.

(local {: some} (require :io.gitlab.andreyorst.cljlib.core))
(local {: valid-event-selector? : event-hierarchy} (require :lib.event-bus))
(local {: isa?} (require :lib.hierarchy))


(local behaviors-register {})


(fn define-behavior [name desc event-selectors f]
  "Register a behavior with its event-selectors (event-names or ancestors).
   Does not subscribe to any events.
   Use subscribe to activate for specific source+event-selector pairs."
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


(fn behavior-responds-to? [behavior-name event-name]
  "Check if behavior's :respond-to selectors match the given event-name (via isa?)."
  (let [behavior (. behaviors-register behavior-name)]
    (if (= nil behavior)
        false
        (some #(isa? event-hierarchy event-name $) (. behavior :respond-to)))))


{: behaviors-register
 : define-behavior
 : behavior-responds-to?}
