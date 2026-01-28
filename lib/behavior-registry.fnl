(local {: mapcat : into : mapv : hash-set : disj : conj} (require :io.gitlab.andreyorst.cljlib.core))
(local {: add-event-handler} (require :lib.event-bus))
(local {: ancestors} (require :lib.hierarchy))


(local behaviors-register {})

(fn register-behavior [name desc tags f]
  "Register a behavior with its potential tags. Does not subscribe to any events.
   Use subscribe-behavior to activate for specific source+tag pairs."
  (let [behavior {:name name
                  :description desc
                  :respond-to tags
                  :fn f}]
    (tset behaviors-register name behavior)))


;; {source -> {tag -> #{behavior-names}}}
(local source-tag-to-behavior-map {})

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


(fn get-behaviors-for-source-tag [source tag]
  "Get behavior names for a source+tag pair, including ancestors of both."
  (let [sources (conj (ancestors source) source)
        tags (conj (ancestors tag) tag)]
    (accumulate [result (hash-set)
                 _ s (ipairs sources)]
      (accumulate [r result
                   _ t (ipairs tags)]
        (into r (or (?. source-tag-to-behavior-map s t) []))))))


(fn get-behaviors-for-event [event]
  "Get all behaviors subscribed to this event's source+tags."
  (let [source event.event-source
        tags event.event-tags]
    (->> tags
         (mapcat #(get-behaviors-for-source-tag source $))
         (into (hash-set))
         (mapv (fn [name]
                 (let [behavior (. behaviors-register name)]
                   (when (= nil behavior)
                     (print (.. "[ERROR] get-behaviors-for-event: behavior '" (tostring name) "' not found in registry")))
                   behavior))))))


;; TODO: concider pausing for global source/tag/behavior or
;; specific subscription
(add-event-handler
 :behavior-registry/dispatcher
 (fn [event]
   (let [bs (get-behaviors-for-event event)]
     (each [_ behavior (pairs bs)]
       (when behavior
         ((. behavior :fn) event))))))


{: register-behavior
 : subscribe-behavior
 : unsubscribe-behavior}
