# Sheaf

A design pattern for composable desktop automation.

## Why "Sheaf"?

The name resonates at three levels:

1. **Mathematical (sheaf theory)** — A sheaf is a structure for building
   consistent global data from local pieces. Local data lives on
   independent regions; gluing conditions ensure they compose into a
   coherent whole. In this system, components are the local regions
   (each self-contained), and subscriptions are the gluing — they
   produce global behavior from locally-defined parts.

2. **Physical (sheaf of wheat)** — Independent stalks, each complete on
   its own, bound together without merging or losing identity. The
   binding (subscriptions) holds them together. The value (the system's
   behavior) emerges from the bundle, not from any single stalk.

3. **Software pattern** — Context-blind components wired by subscriptions
   into a coherent system. No component knows about any other. The
   global behavior is a property of the gluing, not the parts.

## Core Insight

Components are context-blind units. Behaviors are component-blind rules.
Subscriptions are the only concept that knows about both — they are the
wiring that creates a system from independent parts, shaped by tags.

## Atoms

### Event

A fact about something that happened.

- **name** — unique identifier (e.g., `:file-watcher.events/file-change`)
- **schema** — expected shape of event data
- **kind-hierarchy** — position in the event kind tree (enables hierarchical matching)

### Command

An action that can be invoked on a component.

- **name** — unique identifier (e.g., `:window-manager/move-left`)
- **schema** — expected parameters
- **implementation** — the function that executes the command

### Component

A concrete unit of functionality. Context-blind. Reusable.

- **sources** — emit events into the system
- **commands** — receive invocations from behaviors
- **state** — mutable internal state
- **config** — parameters that shape the component's behavior

Components don't know about each other.

### Behavior

A rule with logic that maps events to commands. Blind to which specific
components it's wired to — that's the subscription's job.

- **name** — unique identifier
- **responds-to** — which event kinds trigger this behavior
- **fn [event targets send-cmd!]** — the handler function

The handler receives:
- **event** — the event that triggered it
- **targets** — resolved target components (opaque handles, resolved by the subscription)
- **send-cmd!** — function to invoke commands on targets

A behavior can invoke zero or more commands, compute parameters
programmatically, and apply conditional logic.

### Tag

A contextual label attached to component instances. Inherited through
the component instance tree. Tags enable and disable subscriptions.

### Subscription

The only place where components, behaviors, and tags meet.

- **behavior** — which behavior to invoke
- **source-selector** — which component(s) provide the event
- **target-selector** — which component(s) receive commands
- **require-tags** — tags that must be present for this subscription to be active
- **exclude-tags** — tags that must be absent

## Composition

Built bottom-up from orthogonal primitives:

```
Events, Commands                   (atoms)
  → Components                     (bundle sources + commands + state)
    → Behaviors                    (rules: event-kind → commands)
      → Subscriptions + Tags       (wiring + context)
        → System Map               (the complete value)
```

Each concept is independent. The system is their composition.

## Event Flow

```
Component A (source)
    │ emits Event
    │
Subscription: source=A, target=[B,C], behavior=X, tags match?
    │
Behavior X: fn [event targets send-cmd!]
    │  examines event, decides what to do
    │  (send-cmd! target-b :some-command {:param value})
    │  (send-cmd! target-c :other-command {:computed (+ 1 2)})
    │
Components B, C receive commands
    ▼
```

## System Map

The complete value describing the running system:
component instance tree + subscriptions + tags.

The entire system is a value — inspectable, serializable, queryable.

## Key Properties

- Components don't know about each other
- Behaviors don't know about components
- Subscriptions are the only point of coupling
- Tags shape the active wiring contextually
- Every concept is a simple, independent value
- The system is the composition of these values

## Open Questions

- **Selection mechanism** — should subscriptions select sources/targets
  by component identity, or by more abstract criteria (available
  events/commands, tags)? Leaning toward component-level selection.

- **System map structure** — what defines parent-child relationships
  in the component instance tree? Explicit nesting in the system map,
  or derived?

- **Command execution model** — does `send-cmd!` execute synchronously?
  Can behaviors chain commands?

## Inspirations

- **LightTable BOT** — behavior-object-tag architecture
- **Clojure / Integrant** — system as a value, declarative config
- **Emacs** — modes, hooks, keymaps as composable layers
- **Datomic** — facts, time, queryability
- **Linear algebra** — orthogonal decomposition of a system into independent basis vectors
- **Sheaf theory** — local data glued consistently into a global whole
