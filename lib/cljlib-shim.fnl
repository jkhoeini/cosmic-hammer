;; lib/cljlib-shim.fnl
;; Shim that re-exports all of cljlib.core.
;; Compiled to Lua with all dependencies bundled.
;; The require is the last expression, so its return value (the core table) is exported.

(require :io.gitlab.andreyorst.cljlib.core)
