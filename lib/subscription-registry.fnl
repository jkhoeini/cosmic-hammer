
;; lib/subscription-registry.fnl
;; Manages subscription definitions - connections between behaviors and source+event pairs.
;;
;; A subscription is a first-class named entity:
;;   {:name        :sub/my-subscription
;;    :description "Human-readable description"
;;    :behavior    :my-behavior
;;    :event-selector  :event.kind/something
;;    :source-selector :my-source
;;    :require-tags []   ; placeholder for future
;;    :exclude-tags []}  ; placeholder for future

(local {: hash-set : conj : disj : into : seq : filter} (require :lib.cljlib-shim))
(local {: event-registry} (require :events))
(local {: valid-event-selector?} (require :lib.event-registry))
(local {: behavior-defined?} (require :lib.behavior-registry))
(local {: source-registry} (require :event_sources))
(local {: source-instance-exists?} (require :lib.source-registry))
(local {: ancestors} (require :lib.hierarchy))


;; Primary storage: subscription name -> subscription data
(local subscriptions-register {})

;; Performance index (internal): source -> event-selector -> #{behavior-names}
(local subscriptions-index {})


;; ============================================================================
;; Index Management (internal)
;; ============================================================================

(fn index-add! [subscription]
  "Add subscription's behavior to the index."
  (let [source subscription.source-selector
        event subscription.event-selector
        behavior subscription.behavior]
    (when (= nil (. subscriptions-index source))
      (tset subscriptions-index source {}))
    (when (= nil (. subscriptions-index source event))
      (tset subscriptions-index source event (hash-set)))
    (tset subscriptions-index source event
          (conj (. subscriptions-index source event) behavior))))


(fn index-remove! [subscription]
  "Remove subscription's behavior from the index."
  (let [source subscription.source-selector
        event subscription.event-selector
        behavior subscription.behavior
        behavior-set (?. subscriptions-index source event)]
    (when behavior-set
      (tset subscriptions-index source event
            (disj behavior-set behavior)))))


;; ============================================================================
;; Validation
;; ============================================================================

(fn validate-required-field! [name opts field]
  "Validate that a required field exists in opts. Errors if missing."
  (when (= nil (. opts field))
    (error (.. "define-subscription " (tostring name)
               ": missing required field " (tostring field)))))


(fn validate-subscription! [name opts]
  "Validate all subscription requirements. Errors on failure."
  ;; Check required fields
  (validate-required-field! name opts :description)
  (validate-required-field! name opts :behavior)
  (validate-required-field! name opts :event-selector)
  (validate-required-field! name opts :source-selector)
  
  ;; Check name is unique
  (when (not= nil (. subscriptions-register name))
    (error (.. "Subscription already defined: " (tostring name))))
  
  ;; Check behavior exists (lazy require to avoid circular dependency)
  (let [{: behavior-registry} (require :behaviors)]
    (when (not (behavior-defined? behavior-registry opts.behavior))
      (error (.. "define-subscription " (tostring name)
                 ": behavior not found: " (tostring opts.behavior)))))
  
  ;; Check source exists
  (when (not (source-instance-exists? source-registry opts.source-selector))
    (error (.. "define-subscription " (tostring name)
               ": source instance not found: " (tostring opts.source-selector))))
  
  ;; Check event-selector is valid
  (when (not (valid-event-selector? event-registry opts.event-selector))
    (error (.. "define-subscription " (tostring name)
               ": invalid event-selector: " (tostring opts.event-selector)))))


;; ============================================================================
;; Public API
;; ============================================================================

(fn define-subscription [name opts]
  "Define a named subscription connecting a behavior to source+events.
   opts:
     :description     - human-readable description (required)
     :behavior        - behavior name to invoke (required)
     :event-selector  - event name or kind to match (required)
     :source-selector - event source name to match (required)
     :require-tags    - tags source must have (optional, placeholder)
     :exclude-tags    - tags source must NOT have (optional, placeholder)"
  (validate-subscription! name opts)
  (let [subscription {:name name
                      :description opts.description
                      :behavior opts.behavior
                      :event-selector opts.event-selector
                      :source-selector opts.source-selector
                      :require-tags (or opts.require-tags [])
                      :exclude-tags (or opts.exclude-tags [])}]
    (tset subscriptions-register name subscription)
    (index-add! subscription)
    (print (.. "[INFO] Defined subscription: " (tostring name)))))


(fn remove-subscription [name]
  "Remove a subscription by name. Errors if subscription does not exist."
  (let [subscription (. subscriptions-register name)]
    (when (= nil subscription)
      (error (.. "Subscription not found: " (tostring name))))
    (index-remove! subscription)
    (tset subscriptions-register name nil)
    (print (.. "[INFO] Removed subscription: " (tostring name)))))


(fn get-subscription [name]
  "Get subscription data by name. Returns nil if not found."
  (. subscriptions-register name))


(fn list-subscriptions []
  "List all subscription names."
  (let [names []]
    (each [name _ (pairs subscriptions-register)]
      (table.insert names name))
    names))


(fn subscription-defined? [name]
  "Check if a subscription exists."
  (not= nil (. subscriptions-register name)))


(fn get-subscribed-behaviors [source event-name]
  "Get behavior names subscribed to this source+event.
   Checks subscriptions for the source and all ancestor event-selectors.
   Returns a sequence of behavior names (may contain duplicates if same
   behavior subscribed via multiple selectors)."
  (let [event-selectors (conj (ancestors event-registry.hierarchy event-name) event-name)
        source-subs (or (. subscriptions-index source) {})
        all-behavior-names (accumulate [result (hash-set)
                                        _ e (pairs event-selectors)]
                             (into result (or (. source-subs e) [])))]
    (seq all-behavior-names)))


{: subscriptions-register
 : define-subscription
 : remove-subscription
 : get-subscription
 : list-subscriptions
 : subscription-defined?
 : get-subscribed-behaviors}
