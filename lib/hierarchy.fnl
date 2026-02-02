
;; Keyword hierarchy system inspired by Clojure's hierarchy functions.
;; Enables hierarchical relationships between keywords for flexible dispatch.
;;
;; Hierarchies are explicit data structures passed to all functions.
;; Use make-hierarchy to create a new hierarchy instance.
;;
;; Data structure shape:
;; {:keyword {:parents #{:parent1 :parent2} :children #{:child1 :child2}}}

(local {: hash-set : conj : disj : contains? : into : mapcat : empty? : seq} (require :lib.cljlib-shim))


(fn ensure-entry [h tag]
  "Ensure tag has an entry in hierarchy. Mutates h."
  (when (= nil (. h tag))
    (tset h tag {:parents (hash-set) :children (hash-set)})))


(fn parents [h tag]
  "Get the immediate parents of `tag` in hierarchy `h`. Returns a hash-set."
  (or (?. h tag :parents) (hash-set)))


(fn children [h tag]
  "Get the immediate children of `tag` in hierarchy `h`. Returns a hash-set."
  (or (?. h tag :children) (hash-set)))


(fn ancestors [h tag]
  "Get all ancestors of `tag` in hierarchy `h` (transitive closure of parents).
   Returns a hash-set."
  (let [ps (parents h tag)]
    (if (empty? ps)
        ps
        (into ps (mapcat #(ancestors h $) (seq ps))))))


(fn descendants [h tag]
  "Get all descendants of `tag` in hierarchy `h` (transitive closure of children).
   Returns a hash-set."
  (let [cs (children h tag)]
    (if (empty? cs)
        cs
        (into cs (mapcat #(descendants h $) (seq cs))))))


(fn isa? [h child parent]
  "Returns true if `child` equals `parent`, or if `child` derives from `parent`
   in hierarchy `h`, either directly or through ancestor chain.
   Uses BFS traversal with short-circuit on match."
  (if (= child parent)
      true
      (let [visited (hash-set)
            queue [child]]
        (var found false)
        (while (and (not found) (< 0 (length queue)))
          (let [current (table.remove queue 1)
                current-parents (parents h current)]
            (each [p (pairs current-parents) &until found]
              (if (= p parent)
                  (set found true)
                  (when (not (contains? visited p))
                    (conj visited p)
                    (table.insert queue p))))))
        found)))


(fn derive! [h child parent]
  "Establish a parent/child relationship in hierarchy `h`.
   Makes `child` derive from `parent`.
   Mutates `h` and returns `h`."
  (when (= child parent)
    (error "Cannot derive a keyword from itself"))
  (when (isa? h parent child)
    (error (.. "Cycle detected: " (tostring parent) " already derives from " (tostring child))))
  (ensure-entry h child)
  (ensure-entry h parent)
  (tset h child :parents (conj (. h child :parents) parent))
  (tset h parent :children (conj (. h parent :children) child))
  h)


(fn underive! [h child parent]
  "Remove a parent/child relationship in hierarchy `h`.
   Mutates `h` and returns `h`."
  (let [child-entry (. h child)]
    (when child-entry
      (tset child-entry :parents (disj (. child-entry :parents) parent))))
  (let [parent-entry (. h parent)]
    (when parent-entry
      (tset parent-entry :children (disj (. parent-entry :children) child))))
  h)


(fn make-hierarchy [?init-pairs]
  "Create a new hierarchy.
   Optional init-pairs is a sequential table [child1 parent1 child2 parent2 ...]
   specifying initial derive relationships."
  (let [h {}]
    (when ?init-pairs
      (for [i 1 (length ?init-pairs) 2]
        (let [child (. ?init-pairs i)
              parent (. ?init-pairs (+ i 1))]
          (when (and child parent)
            (derive! h child parent)))))
    h))


{: make-hierarchy
 : derive!
 : underive!
 : parents
 : children
 : ancestors
 : descendants
 : isa?}
