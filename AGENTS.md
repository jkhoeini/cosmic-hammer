# AGENTS.md - Coding Agent Guidelines

This is a **Hammerspoon configuration project** using **Fennel** (a Lisp that compiles to Lua). Originally cloned from [spacehammer](https://github.com/agzam/spacehammer/) but heavily modified with a data-oriented, event-driven architecture inspired by Clojure.

## Build Commands

```bash
# Compile all Fennel to Lua (required after any .fnl file changes)
./compile.sh

# What it does:
# 1. Compiles lib/cljlib-shim.fnl -> lib/cljlib-shim.lua
# 2. Compiles core.fnl -> init.lua (main entry point)

# Reload Hammerspoon after compilation
# Use Cmd+Ctrl+Q or call hs.reload() from the console
```

**Requirements:**
- [mise](https://mise.jdx.dev/) for tool management
- `deps` tool (installed via mise from deps.fnl project)

**No test framework is configured.** Testing is done manually via Hammerspoon console.

**No linter is configured.** Use Fennel compiler errors for feedback.

## Project Structure

```
.hammerspoon/
├── core.fnl              # Main entry point -> compiles to init.lua
├── init.lua              # COMPILED OUTPUT - DO NOT EDIT
├── compile.sh            # Build script
├── deps.fnl              # Fennel dependencies (fennel-cljlib)
├── config.fnl            # App keybindings and menus
├── lib/                  # Core library modules
│   ├── cljlib-shim.fnl   # Re-exports cljlib.core
│   ├── hierarchy.fnl     # Clojure-style keyword hierarchies
│   ├── event-bus.fnl     # Event dispatch system
│   ├── behavior-registry.fnl
│   ├── subscription-registry.fnl
│   ├── source-registry.fnl
│   └── dispatcher.fnl
├── events/init.fnl       # Event hierarchy and definitions
├── event_sources/        # Event source implementations
├── behaviors/            # Behavior implementations
└── *.fnl                 # Feature modules (windows, slack, chrome, etc.)
```

## Code Style Guidelines

### Imports

Always use destructuring imports at the top of the file:

```fennel
;; Destructuring imports (preferred)
(local {: some : seq : hash-set} (require :lib.cljlib-shim))
(local {: define-event : dispatch-event} (require :lib.event-bus))

;; Plain require for single-export modules
(local notify (require :notify))
```

### Naming Conventions

| Type | Convention | Examples |
|------|------------|----------|
| Functions | `kebab-case` | `define-behavior`, `dispatch-event` |
| Predicates | End with `?` | `event-defined?`, `empty?`, `isa?` |
| Mutating functions | End with `!` | `derive!`, `underive!` |
| Keywords | `:kebab-case` | `:window-move`, `:file-change` |
| Namespaced keywords | `:namespace/name` | `:event.kind.fs/file-change` |
| Optional parameters | Prefix with `?` | `?init-pairs`, `?config` |
| Internal registers | `*-register` suffix | `events-register`, `behavior-register` |

### Module Pattern

```fennel
;; Module docstring (optional)
"Module description here"

;; Imports at top
(local {: func1 : func2} (require :some-module))

;; Private state
(local internal-register {})
(var mutable-state false)

;; Private helper functions (not exported)
(fn private-helper [args]
  "Docstring describing the function."
  ...)

;; Public functions
(fn public-function [args]
  "Docstring describing the function."
  ...)

;; Export public API as table at end of file
{: public-function
 : another-public-fn}
```

### Comments

```fennel
;; Single-line comments use double semicolon

;; ============================================================================
;; Section headers use separator lines
;; ============================================================================

;; Use (comment ...) for example data structures
(comment example-event
  {:timestamp 0
   :event-name :window-move
   :event-data {:x 10 :y 20}})
```

### Error Handling

```fennel
;; Critical errors - use (error ...) to halt execution
(when (= child parent)
  (error "Cannot derive a keyword from itself"))

;; Non-fatal warnings - use (print "[WARN] ...")
(when (= nil (. events-register event-name))
  (print (.. "[WARN] dispatch-event: event '" (tostring event-name) "' not registered")))

;; Guard clauses with (when ...) for nil checks
(when child-entry
  (tset child-entry :parents (disj (. child-entry :parents) parent)))
```

### Cljlib Utilities (Clojure-style)

This project uses `fennel-cljlib` for Clojure-like data manipulation:

```fennel
(hash-set)              ; Create empty set
(conj set item)         ; Add item to set (returns new set)
(disj set item)         ; Remove item from set
(contains? set x)       ; Check membership
(into coll items)       ; Add all items to collection
(mapv f coll)           ; Map returning vector
(mapcat f coll)         ; Map and concatenate results
(some pred coll)        ; Find first truthy result
(seq coll)              ; Convert to sequence (nil if empty)
(empty? coll)           ; Check if empty
(assoc tbl k v)         ; Associate key-value in table
(string? x)             ; Type predicate
```

## Architecture Overview

This project follows a **data-oriented, event-driven architecture**:

1. **Event Sources** - Emit events (file watchers, app monitors, USB listeners)
2. **Events** - Named occurrences with structured data and hierarchical kinds
3. **Behaviors** - Named handlers that respond to events
4. **Subscriptions** - Connect behaviors to source+event pairs with filtering
5. **Hierarchies** - Enable hierarchical event matching (like Clojure multimethods)

### Key Concepts

- Events have **names** (`:fs/file-change`) and belong to **kinds** (`:event.kind/fs`)
- Hierarchies enable matching by kind: subscribe to `:event.kind/fs` to get all filesystem events
- Behaviors are pure functions that receive event data
- Subscriptions wire everything together declaratively

## Important Files

| File | Purpose |
|------|---------|
| `core.fnl` | Entry point, loads all modules |
| `lib/event-bus.fnl` | Core event dispatch system |
| `lib/hierarchy.fnl` | Clojure-style hierarchy for event matching |
| `lib/behavior-registry.fnl` | Behavior definition and lookup |
| `lib/subscription-registry.fnl` | Connects behaviors to events |
| `events/init.fnl` | All event kind definitions |
| `TODOs.org` | Project roadmap and task tracking |

## Common Patterns

### Defining an Event

```fennel
(define-event :fs/file-change
              "Emitted when a watched file changes"
              {:path "string" :flags "table"})
```

### Defining a Behavior

```fennel
(define-behavior :reload-on-change
                 "Reloads Hammerspoon when config files change"
                 [:fs/file-change]  ; events this behavior handles
                 (fn [event] ...))
```

### Creating a Hierarchy

```fennel
(local h (make-hierarchy [:child :parent
                          :grandchild :child]))
(isa? h :grandchild :parent)  ; => true
```

## Hammerspoon APIs

This runs in Hammerspoon's Lua environment. Common APIs:
- `hs.timer.secondsSinceEpoch` - Current timestamp
- `hs.inspect` - Pretty-print tables for debugging
- `hs.reload()` - Reload Hammerspoon config
- `hs.alert()` - Show on-screen alert
- `hs.notify` - System notifications

See [Hammerspoon API docs](https://www.hammerspoon.org/docs/) for full reference.
