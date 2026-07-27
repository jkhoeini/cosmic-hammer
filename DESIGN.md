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

Components are context-blind units with lifecycle. Behaviors are
rules that receive candidate targets and select which to act on.
Commands declare which traits they require on target components. Behaviors
may declare shaped component-state inputs they need. Tags select which
components participate as sources, targets, and inputs. Subscriptions
wire those tags to a behavior — the only place these roles meet.

## Atoms

### Event

A fact about something that happened.

- **name** — unique identifier (e.g., `:file-watcher.events/file-change`)
- **schema** — expected shape of event data
- **kind-hierarchy** — position in the event kind tree (enables hierarchical matching)

### Command

A named action that runs on a component.

- **name** — unique identifier (e.g., `:space-indicator.commands/update-menubar`)
- **schema** — expected parameters
- **requires-traits** — list of traits the target component must implement
- **fn** — receives the resolved component and params, returns new state.
  The dispatcher injects the component and captures the returned
  state — the command itself never touches the registry.

### Component

A concrete unit of functionality with lifecycle. Context-blind. Reusable.
Follows a type/instance split. Components subsume event sources — every
event source belongs to a component, and components create their source
instances as part of their lifecycle.

- **type** — a blueprint defining lifecycle (start/stop), config schema,
  state, event sources, and which traits it implements
- **instance** — a running component with config, mutable state, and
  zero or more running event source instances
- **kind** — position in the component kind hierarchy

Components do NOT own commands. Commands declare `:requires-traits`
to specify which components they can target. Tags select which
components participate in source, target, or input roles. Subscriptions
wire those tagged roles to behaviors.

#### Component Kind Hierarchy

Component types form a hierarchy using the same `lib/hierarchy.fnl`
infrastructure as events. This enables hierarchical selectors — a
command declaring `:operates-on [:component.kind/any]` can target any
component.

```
:component.kind/any
├── :component.kind/space-indicator
├── :component.kind/expose
├── :component.kind/emacs
├── :component.kind/reload-hammerspoon
└── ...
```

Types derive from kinds:

```
:component.type/space-indicator  derives from  :component.kind/space-indicator
:component.type/expose           derives from  :component.kind/expose
```

A component type is a blueprint: it defines lifecycle (start/stop) and
optionally declares which event source types it composes. When a component
starts, it creates its owned source instances automatically. When it stops,
owned sources are torn down first. This is how event sources fold into
components — no separate source management needed.

### Trait

A named state property. A trait can require multiple attributes using
per-attribute predicates, and may also include a predicate over the
whole state to express relationships between those attributes. Components
declare which traits they implement. Commands require traits on targets.

### Shape

A named logical composition of traits. A shape describes acceptable
component-state inputs as alternatives: each alternative is a set of
traits that must all hold. Shapes let behaviors ask for "state matching
this role" without binding to a specific component.

- **name** — unique identifier (e.g., `:shape/displayable`)
- **alts** — ordered list of alternatives (OR semantics between alts)
  - each alt has a `:name` and a `:traits` list (AND semantics within)
  - an alt with empty `:traits` always matches (useful as a fallback)
- **conformance** — `conforms?` tries each alt in order; first where
  all traits are satisfied wins. Returns the matched alt or nil.

### Behavior

A rule with logic that maps events to commands. Receives the set of
candidate target components (resolved by the dispatcher from the
subscription's target tag) and decides which to send commands to. May
also receive shaped input state from components selected by the
subscription's input tag.

- **name** — unique identifier
- **responds-to** — which event kinds trigger this behavior
- **commands** — aliases mapping to registered command names
- **inputs** — optional aliases mapping to shape names
- **fn** — the handler function

The handler receives the event, a set of candidate target components
(resolved by the dispatcher from the subscription's target tag, grouped
by command alias), a send-cmd function, optional input state keyed by
input alias, and optional per-wiring subscription params. The behavior
selects which candidates to act on and sends commands to them. For simple
1:1 cases it picks the first candidate. For fan-out, it iterates. For
context-dependent selection, it inspects event data, candidate state,
shaped inputs, or subscription params.

### Tag

A contextual label attached to component instances. Tags are the
primary wiring mechanism — they determine which component instances
play source, target, or input roles for a subscription. Tags are
assigned to instances, not to types or kinds.

### Subscription

The wiring between source components, behaviors, and target components.
Uses tags to select source, target, and optional input sets.

- **behavior** — which behavior to invoke
- **source** — tag selecting which components provide events
- **target** — tag selecting which components are command candidates
- **input** — optional tag selecting components whose state can satisfy
  the behavior's input shapes
- **params** — optional static choices supplied to this behavior invocation
  by this specific wiring

At event-time, the dispatcher:
1. Matches the event's source component against subscriptions by source tag
2. Resolves all components with the target tag as candidates
3. Groups candidates by command alias (filtered by `:requires-traits`)
4. Resolves input components by input tag and filters them by shape
5. Invokes the behavior with `(fn [event candidates send-cmd inputs params] ...)`

The dispatcher validates `:requires-traits` when the behavior calls
`send-cmd`, validates behavior inputs by shape, and captures returned
command state back on the target instance.

## Composition

Built bottom-up from orthogonal primitives:

```
Events, Commands, Traits, Shapes   (atoms — facts, actions, state contracts)
  → Components                     (runtime units — emit events, hold state)
    → Behaviors                    (rules: event + inputs → commands)
      → Tags                       (labels — select source, target, input sets)
        → Subscriptions            (wiring: tags → behavior)
          → System Map             (the complete value)
```

Each concept is independent. Commands declare `:requires-traits` for
affinity with component capabilities, but they never reference specific
instances. Shapes describe behavior input needs. Tags select which
components participate. Subscriptions wire tags to behaviors. The system
is the composition of these values.

## Event Flow

```
Component A (tagged :src) emits Event via owned source
    │
Subscription: source=:src, behavior=X, target=:tgt, input=:cfg, params={...}
    │
Dispatcher:
    │  1. Matches: A has tag :src → subscription fires
    │  2. Resolves behavior X
    │  3. Finds all components tagged :tgt → [C, D]
    │  4. Groups by command alias (filtered by :requires-traits)
    │     candidates = {:update-menubar [C D]}
    │  5. Finds components tagged :cfg whose state conforms to input shapes
    │  6. Builds send-cmd (validates :requires-traits, captures state)
    │
Behavior X: fn [event candidates send-cmd inputs params]
    │  (let [target (. candidates.update-menubar 1)]
    │    (send-cmd target :update-menubar {:active-spaces [1 3]}))
    │
Dispatcher captures returned state → updates target component
    ▼
```

## System Map

The complete value describing the running system:
component instance tree + subscriptions + tags.

The entire system is a value — inspectable, serializable, queryable.

## Key Properties

- Components don't know about each other
- Behaviors receive candidate targets and select via send-cmd
- Commands declare `:requires-traits` but never reference instances
- Behaviors declare shaped inputs but never own input components
- All commands run on a component — no standalone commands
- Event sources belong to components — no standalone source concept
- Subscriptions wire source, target, and input tags to behaviors
- Tags are the universal wiring mechanism for component roles
- Every concept is a simple, independent value
- The system is the composition of these values

## Principles

The governing principles behind the atoms. P1–P4 are settled; P5 is
directional — its shape is adopted, its mechanism is not. Decisions
derived from these principles are recorded in `docs/adr/`; the
vocabulary they produce lives in `CONTEXT.md`.

### P1. The system is a knowledge graph: facts and inference rules

Instances, state, tags, and occurred events are facts; behaviors are
inference rules; subscriptions are the join patterns wiring rules to
facts. Queryability, visualization, and datalog/persistence plans are
consequences of this ontology, not bolted-on features.

The graph has three strata (TBox/ABox/assertions, in RDF terms):

1. **Definitions** — timeless vocabulary: events, traits, shapes,
   commands, event-source types, component types, behaviors,
   hierarchy derivations.
2. **Instantiations** — configured occurrences: component instances,
   event-source instances, subscriptions, tag attachments.
3. **Runtime facts** — event occurrences, command sends, state
   changes; produced by the interpreter, never authored.

Corollary: never file a *choice* under *facts* or vice versa.
Configuration belongs in the wiring (subscription params, instance
config), not closed over in definitions or stored as component state;
fast-changing state belongs in components, not in tags or wiring.

### P2. Selection and contract are orthogonal

A tag ascribes a role — 0..n instances, runtime-mutable. Traits and
shapes carry the contract. This is a deliberate un-fusing of what
Effect-TS fuses into `Context.Tag` (identity + interface), and it is
what makes runtime re-wiring and fan-out possible. Identity is
relational: an untagged instance has no role — the dispatcher resolves
every role via tags, nothing else.

Known debt: no totality guarantee. Nothing verifies a subscription's
tags are ever provided or a selector has an emitter. Repaid at
assembly time by P5, not at compile time by types.

### P3. Behaviors are pure inference: coeffects in, effects out

A behavior is semantically `(event, candidates, inputs, params) →
commands`. Candidates, inputs, and params are **coeffects** — context
the rule requires, declared and injected, never fetched. A sent
command is a datum about a *requested* action; it does nothing by
itself. Behaviors are unit-testable as pure functions; command streams
are traceable, loggable, replayable.

The two context mechanisms split along the fact/choice line (P1):
inputs deliver shared, live, many-reader *facts* (component state,
shape-checked, fresh per event); subscription params deliver
per-wiring, static, one-reader *choices*. Commands are part of a
behavior's **effect type** — declared in the definition, never
parameterized from outside; runtime selection *among* the declared
commands is ordinary behavior logic. (ADR-0002)

### P4. Meaning lives in the interpreter

Every layer is inert data plus a small interpreter: events ← dispatcher,
command data ← executor, specs ← builders, (future) module maps ←
assembler. Descriptions never execute themselves. This is what
"everything is data" means operationally: malleability is the freedom
to swap interpreters (trace, dry-run, replay, visualize) because the
description layer never acts.

Current interpreter choices, which are strategies rather than
semantics: commands execute synchronously inside `send-cmd`; a
behavior invocation never outlives its triggering event; async
outcomes re-enter as new events, chaining invocations into
*conversations* (ADR-0001, forced by Hammerspoon's C-boundary
coroutine limitation).

Corollary (the ratchet): any higher-level framework is a pure builder
from spec-data to atom-data. Everything it generates must be
hand-writable in today's atoms; if the builder can't express something
as spec → atoms, an atom is missing — stop and reconsider the atoms.

### P5. Modules provide definitions; layers configure instantiations (directional)

The def/inst split of P1 implies two bundle mechanisms: **modules**
contribute definitions (vocabulary), **layers** contribute
instantiations (configuration). Both are static data — construction is
already reified as component-type start-fns in the registry, so
provides reference blueprints by name and cross-module refs are
symbolic, resolved by an assembler (Integrant-style), not closures
(Effect-Layer-style).

Assembly merges provides and checks every require against the union —
the system map becomes total-by-construction or fails at boot. This
repays P2's totality debt. Mechanism undecided; shape adopted now: new
specs carry provides/requires from day one.

## Open Questions

- **System map structure** — what defines parent-child relationships
  in the component instance tree? Explicit nesting in the system map,
  or derived?

- **Module/layer mechanism** (P5) — what exactly is in a module map,
  how are requires declared and checked, how do symbolic refs resolve?
  Tags currently have no definition mechanism at all — a module
  contributing a tag has nothing to register.

- **Keymap foundation** — a tailor-made keymap component, or a generic
  foundation (components + events + subscriptions) that layers
  configure into doom-like behavior? (See TODOs.org, Doom-style
  Keybinding Framework.)

## Inspirations

- **LightTable BOT** — behavior-object-tag architecture
- **Clojure / Integrant** — system as a value, declarative config
- **Emacs** — modes, hooks, keymaps as composable layers
- **Datomic** — facts, time, queryability
- **Linear algebra** — orthogonal decomposition of a system into independent basis vectors
- **Sheaf theory** — local data glued consistently into a global whole
