
(local {: mapcat : into : mapv : hash-set} (require :io.gitlab.andreyorst.cljlib.core))
(local {: add-event-handler} (require :events))


(comment example-behavior
  {:name :example-behavior
   :description "Some example behavior"
   :enabled? true
   :respond-to [:example-tag]
   :fn (fn [event] (print (fnl.view event)))})


(local behaviors-register {})
(local tag-to-behavior-map {})


(fn register-behavior [name desc tags f]
  (let [behavior {:name name
                  :description desc
                  :enabled? true
                  :respond-to tags
                  :fn f}]
    (tset behaviors-register name behavior)
    (each [_ tag (pairs tags)]
      (when (= nil (. tag-to-behavior-map tag))
        (tset tag-to-behavior-map tag []))
      (table.insert (. tag-to-behavior-map tag) name))))


(fn get-behaviors-for-tags [tags]
  (->> tags
       (mapcat #(. tag-to-behavior-map $))
       (into (hash-set))
       (mapv #(. behaviors-register $))))


(add-event-handler
 (fn [event]
   (let [bs (get-behaviors-for-tags event.event-tags)]
     (each [_ behavior (pairs bs)]
       (let [f (. behavior :fn)]
         (f event))))))


{: register-behavior}
