
(local {: mapcat : into : mapv : hash-set : disj : conj} (require :io.gitlab.andreyorst.cljlib.core))
(local {: add-event-handler} (require :lib.event-bus))


(comment example-behavior
  {:name :example-behavior
   :description "Some example behavior"
   :enabled? true
   :respond-to [:example-tag]
   :fn (fn [event] (print (fnl.view event)))})


(local behaviors-register {})

;; {source -> {tag -> #{behavior-names}}}
(local source-tag-to-behavior-map {})


(fn register-behavior [name desc tags f]
  "Register a behavior with its potential tags. Does not subscribe to any events.
   Use subscribe-behavior to activate for specific source+tag pairs."
  (let [behavior {:name name
                  :description desc
                  :enabled? true
                  :respond-to tags
                  :fn f}]
    (tset behaviors-register name behavior)))


;; TODO: Use keyword hierarchies and ancestor? checking for sources and tags
;;       This will enable hierarchical matching and cover wildcard matching feature
;; TODO: Add wildcard matching support (e.g., [:* tag] or [source :*])
(fn subscribe-behavior [behavior-name source tag]
  "Subscribe a behavior to respond to events from a specific source with a specific tag."
  (when (= nil (. behaviors-register behavior-name))
    (print (.. "[WARN] subscribe-behavior: behavior '" (tostring behavior-name) "' not found in registry")))
  (when (= nil (. source-tag-to-behavior-map source))
    (tset source-tag-to-behavior-map source {}))
  (when (= nil (. source-tag-to-behavior-map source tag))
    (tset source-tag-to-behavior-map source tag (hash-set)))
  (tset source-tag-to-behavior-map source tag
        (conj (. source-tag-to-behavior-map source tag) behavior-name)))


(fn unsubscribe-behavior [behavior-name source tag]
  "Unsubscribe a behavior from a specific source+tag pair."
  (let [behavior-set (?. source-tag-to-behavior-map source tag)]
    (when behavior-set
      (tset source-tag-to-behavior-map source tag
            (disj behavior-set behavior-name)))))


(fn get-behaviors-for-event [event]
  "Get all behaviors subscribed to this event's source+tags."
  (let [source event.origin
        tags event.event-tags]
    (->> tags
         (mapcat #(?. source-tag-to-behavior-map source $))
         (into (hash-set))
         (mapv (fn [name]
                 (let [behavior (. behaviors-register name)]
                   (when (= nil behavior)
                     (print (.. "[ERROR] get-behaviors-for-event: behavior '" (tostring name) "' not found in registry")))
                   behavior))))))


(add-event-handler
 (fn [event]
   (let [bs (get-behaviors-for-event event)]
     (each [_ behavior (pairs bs)]
       (when behavior
         ((. behavior :fn) event))))))


{: register-behavior
 : subscribe-behavior
 : unsubscribe-behavior}
