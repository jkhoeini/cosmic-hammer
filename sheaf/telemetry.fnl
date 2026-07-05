;; sheaf/telemetry.fnl
;; Thin adapter over the global `hs.opentelemetry` table.
;;
;; Engine modules import this single surface instead of scattering raw
;; `hs.opentelemetry` calls. Telemetry is runtime infrastructure, NOT a Sheaf
;; component/behavior/command/trait/shape/tag/subscription — this module
;; registers nothing in any registry.
;;
;; `hs.opentelemetry` is always available, so there are no availability guards
;; and no redaction here. Structured log emission is intentionally out of scope
;; (the OTel API exposes no explicit log-emit function; logs come from
;; `hs.logger`/`print` capture).

;; ============================================================================
;; Cached facades and instrument cache (created once at module load)
;; ============================================================================

(local tracer (hs.opentelemetry.tracer "sheaf"))
(local meter (hs.opentelemetry.meter "sheaf"))

;; metric-name → instrument, so each counter/histogram is created once per
;; metric name (via the meter), never per event.
(local instruments {})

(fn get-instrument [kind name]
  "Resolve-or-create the meter instrument of `kind` (:counter or :histogram)
   for metric `name`, caching it so it is built once per name."
  (or (. instruments name)
      (let [inst (if (= kind :counter) (: meter :counter name)
                     (= kind :histogram) (: meter :histogram name))]
        (tset instruments name inst)
        inst)))

;; ============================================================================
;; Public API
;; ============================================================================

(fn enabled? []
  "Return whether telemetry export is currently enabled. Hot per-event callers
   check this first to skip building attribute tables when disabled."
  (. (hs.opentelemetry.diagnostics) :enabled))

(fn with-span [name attrs f]
  "Run `f` inside a span named `name` with the given `attrs` attribute table.
   `f` receives the span object. Delegates to `hs.opentelemetry.withSpan`."
  (hs.opentelemetry.withSpan name {:attributes attrs} f))

(fn add-event! [span name attrs]
  "Add an event named `name` with `attrs` to `span`."
  (: span :addEvent name attrs))

(fn set-attrs! [span attrs]
  "Set each key/value in `attrs` as an attribute on `span`. The span object
   exposes only a single-attribute setter, so attributes are applied one by one."
  (when attrs
    (each [k v (pairs attrs)]
      (: span :setAttribute k v))))

(fn record-exception! [span err]
  "Record `err` as an exception on `span`."
  (: span :recordException (tostring err)))

(fn set-status! [span status]
  "Set the status code (e.g. \"ok\" or \"error\") on `span`."
  (: span :setStatus status))

(fn counter-add! [name value attrs]
  "Add `value` (an integer) to the counter named `name`, tagged with `attrs`."
  (: (get-instrument :counter name) :add value attrs))

(fn histogram-record! [name value attrs]
  "Record `value` (a double) into the histogram named `name`, tagged with `attrs`."
  (: (get-instrument :histogram name) :record value attrs))

(fn wrap [f]
  "Wrap `f` so it restores the current propagation context when later invoked
   (for coroutines / deferred callbacks). Passthrough to `hs.opentelemetry.wrap`."
  (hs.opentelemetry.wrap f))

(fn flush! [?timeout]
  "Flush buffered telemetry, guarding against flush errors/timeouts with pcall."
  (pcall hs.opentelemetry.flush ?timeout))

{: enabled?
 : with-span
 : add-event!
 : set-attrs!
 : record-exception!
 : set-status!
 : counter-add!
 : histogram-record!
 : wrap
 : flush!}
