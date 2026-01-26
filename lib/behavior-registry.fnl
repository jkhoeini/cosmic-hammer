
(local {: mapcat : into : mapv : hash-set} (require :io.gitlab.andreyorst.cljlib.core))
(local {: add-event-handler} (require :lib.event-bus))


(comment example-behavior
  {:name :example-behavior
   :description "Some example behavior"
   :enabled? true
   :respond-to [:example-tag]
   :fn (fn [event] (print (fnl.view event)))})


(local behaviors-register {})

;; {source -> {tag -> [behavior-names]}}
;; TODO: Use hash-set instead of list for behavior names for robustness
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
;; TODO: Add unsubscribe-behavior function
(fn subscribe-behavior [behavior-name source tag]
  "Subscribe a behavior to respond to events from a specific source with a specific tag."
  ;; TODO: Log warning if behavior-name not in behaviors-register
  (when (= nil (. source-tag-to-behavior-map source))
    (tset source-tag-to-behavior-map source {}))
  (when (= nil (. source-tag-to-behavior-map source tag))
    (tset source-tag-to-behavior-map source tag []))
  (table.insert (. source-tag-to-behavior-map source tag) behavior-name))


(fn get-behaviors-for-event [event]
  "Get all behaviors subscribed to this event's source+tags."
  (let [source event.origin
        tags event.event-tags]
    (->> tags
         (mapcat #(?. source-tag-to-behavior-map source $))
         (into (hash-set))
         (mapv (fn [name]
                 ;; TODO: Log error if behavior not found in behaviors-register
                 (. behaviors-register name))))))


(add-event-handler
 (fn [event]
   (let [bs (get-behaviors-for-event event)]
     (each [_ behavior (pairs bs)]
       (when behavior
         ((. behavior :fn) event))))))


{: register-behavior
 : subscribe-behavior}
