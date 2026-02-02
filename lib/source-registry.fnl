
;; lib/source-registry.fnl
;; Manages event source types and instances.
;;
;; A source type is a blueprint: it defines what config is needed and how to start/stop.
;; A source instance is a running source with a specific config.
;;
;; Naming convention:
;;   Type:     :event-source.type/file-watcher
;;   Instance: :event-source.file-watcher/config-dir

(local {: dispatch-event} (require :lib.event-bus))


;; {type-name -> {:description string :config-schema table :emits [event-name] :start-fn fn :stop-fn fn}}
(local source-types-register {})

;; {instance-name -> {:type type-name :config table :state any}}
(local source-instances-register {})


(fn define-source-type [type-name description opts]
  "Define a new event source type.
   opts:
     :config-schema - table describing expected config shape (for documentation/validation)
     :emits - list of event names this source can emit
     :start-fn - (fn [self emit] ...) -> state - called to start the source
     :stop-fn - (fn [state] ...) - called to stop the source (optional)"
  (when (not= nil (. source-types-register type-name))
    (error (.. "Source type already registered: " (tostring type-name))))
  (when (= nil opts.start-fn)
    (error (.. "Source type must have a :start-fn: " (tostring type-name))))
  (tset source-types-register type-name
        {:description description
         :config-schema (or opts.config-schema {})
         :emits (or opts.emits [])
         :start-fn opts.start-fn
         :stop-fn opts.stop-fn}))


(fn source-type-defined? [type-name]
  "Check if a source type has been defined."
  (not= nil (. source-types-register type-name)))


(fn get-source-type [type-name]
  "Get a source type definition by name."
  (. source-types-register type-name))


(fn source-instance-exists? [instance-name]
  "Check if a source instance exists."
  (not= nil (. source-instances-register instance-name)))


(fn get-source-instance [instance-name]
  "Get a source instance by name."
  (. source-instances-register instance-name))


(fn start-event-source [instance-name type-name config]
  "Start a new instance of an event source type.
   instance-name: unique name for this instance (e.g. :event-source.file-watcher/config-dir)
   type-name: the source type to instantiate (e.g. :event-source.type/file-watcher)
   config: configuration for this instance"
  (when (source-instance-exists? instance-name)
    (error (.. "Source instance already exists: " (tostring instance-name))))
  (let [source-type (get-source-type type-name)]
    (when (= nil source-type)
      (error (.. "Source type not found: " (tostring type-name))))
    (let [self {:name instance-name
                :type type-name
                :config (or config {})}
          ;; Create an emit function that dispatches with this instance as source
          emit (fn [event-name event-data]
                 (dispatch-event event-name instance-name event-data))
          ;; Call start-fn to get state
          state (source-type.start-fn self emit)]
      (tset source-instances-register instance-name
            {:type type-name
             :config (or config {})
             :state state})
      (print (.. "[INFO] Started source instance: " (tostring instance-name))))))


(fn stop-event-source [instance-name]
  "Stop a running event source instance."
  (let [instance (get-source-instance instance-name)]
    (when (= nil instance)
      (print (.. "[WARN] stop-event-source: instance not found: " (tostring instance-name)))
      (lua "return nil"))
    (let [source-type (get-source-type instance.type)]
      (when source-type.stop-fn
        (source-type.stop-fn instance.state))
      (tset source-instances-register instance-name nil)
      (print (.. "[INFO] Stopped source instance: " (tostring instance-name))))))


(fn stop-all-event-sources []
  "Stop all running event source instances."
  (each [instance-name _ (pairs source-instances-register)]
    (stop-event-source instance-name)))


(fn list-source-types []
  "List all registered source type names."
  (let [names []]
    (each [name _ (pairs source-types-register)]
      (table.insert names name))
    names))


(fn list-source-instances []
  "List all running source instance names."
  (let [names []]
    (each [name _ (pairs source-instances-register)]
      (table.insert names name))
    names))


{: source-types-register
 : source-instances-register
 : define-source-type
 : source-type-defined?
 : get-source-type
 : source-instance-exists?
 : get-source-instance
 : start-event-source
 : stop-event-source
 : stop-all-event-sources
 : list-source-types
 : list-source-instances}
