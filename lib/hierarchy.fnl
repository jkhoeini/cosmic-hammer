
;; Keyword hierarchy system inspired by Clojure's hierarchy functions.
;; Enables hierarchical relationships between keywords for flexible dispatch.

(import-macros {: when-let} :io.gitlab.andreyorst.cljlib.core)
(local {: hash-set : conj : disj : contains? : into : mapcat} (require :io.gitlab.andreyorst.cljlib.core))


;; {child -> #{parents}}
(local parents-map {})

;; {parent -> #{children}} - reverse mapping for efficient descendants lookup
(local children-map {})


(fn derive [child parent]
  "Establish a parent/child relationship. Makes `child` derive from `parent`.
   Returns nil."
  (when (= child parent)
    (error "Cannot derive a keyword from itself"))
  ;; Update parents-map
  (when (= nil (. parents-map child))
    (tset parents-map child (hash-set)))
  (tset parents-map child (conj (. parents-map child) parent))
  ;; Update children-map (reverse mapping)
  (when (= nil (. children-map parent))
    (tset children-map parent (hash-set)))
  (tset children-map parent (conj (. children-map parent) child))
  nil)


(fn underive [child parent]
  "Remove a parent/child relationship.
   Returns nil."
  ;; Update parents-map
  (when-let [parent-set (. parents-map child)]
    (tset parents-map child (disj parent-set parent)))
  ;; Update children-map (reverse mapping)
  (when-let [child-set (. children-map parent)]
    (tset children-map parent (disj child-set child)))
  nil)


(fn parents [tag]
  "Get the immediate parents of `tag`. Returns a hash-set."
  (or (. parents-map tag) (hash-set)))


(fn children [tag]
  "Get the immediate children of `tag`. Returns a hash-set."
  (or (. children-map tag) (hash-set)))


(fn ancestors [tag]
  "Get all ancestors of `tag` (transitive closure of parents).
   Returns a hash-set."
  (let [ps (parents tag)]
    (if (= 0 (length ps))
        ps
        (into ps (mapcat ancestors ps)))))


(fn descendants [tag]
  "Get all descendants of `tag` (transitive closure of children).
   Returns a hash-set."
  (let [cs (children tag)]
    (if (= 0 (length cs))
        cs
        (into cs (mapcat descendants cs)))))


(fn isa? [child parent]
  "Returns true if `child` equals `parent`, or if `child` derives from `parent`
   either directly or through ancestor chain.
   Uses BFS traversal with short-circuit on match."
  (if (= child parent)
      true
      (let [visited (hash-set)
            queue [child]]
        (var found false)
        (while (and (not found) (< 0 (length queue)))
          (let [current (table.remove queue 1)
                current-parents (parents current)]
            (each [p (pairs current-parents) &until found]
              (if (= p parent)
                  (set found true)
                  (when (not (contains? visited p))
                    (conj visited p)
                    (table.insert queue p))))))
        found)))


{: derive
 : underive
 : parents
 : children
 : ancestors
 : descendants
 : isa?}
