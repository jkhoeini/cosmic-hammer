# Cosmic Hammer Config (Sheaf)

A Hammerspoon configuration built on Sheaf — a pattern of composable
atoms (events, commands, traits, shapes, components, behaviors, tags,
subscriptions) glued into a system by subscriptions.

## Language

**Behavior invocation**:
One run of a behavior in response to one event. Bounded by that event —
it never outlives it. Commands sent during it execute synchronously.
_Avoid_: transaction (implies parking/awaiting async results)

**Conversation**:
A chain of behavior invocations linked by events, where an asynchronous
outcome (chooser selection, timer, watcher) re-enters as a new event
triggering the next invocation. The Sheaf way to express long-running
interactions.

**Definition**:
A timeless vocabulary entry — event, trait, shape, command,
event-source type, component type, behavior, hierarchy derivation.
Contributed by modules. Contains no instance configuration.

**Instantiation**:
A concrete configured occurrence of a definition in this system —
component instance, event-source instance, subscription, tag
attachment. Contributed by layers.
_Avoid_: instance config, wiring config (as separate notions)

**Params**:
Per-wiring, static, one-reader configuration carried by a
subscription and passed to the behavior. A choice, not a fact.
_Avoid_: config (too broad), options

**Input**:
Shared, live, many-reader context — component state resolved by
input-tag and shape at event time, passed read-only to a behavior.
A fact, not a choice.

**Effect type (of a behavior)**:
The set of commands a behavior declares. Fixed in the definition;
not parameterizable. Runtime selection among declared commands is
ordinary behavior logic.

**Module**:
A prospective bundle contributing definitions (vocabulary).
Mechanism undecided.

**Layer**:
A prospective bundle contributing instantiations (configuration).
Mechanism undecided.

**Builder**:
A pure function from a spec (data) to the Sheaf atoms it expands into
(data). Builders never touch runtime, registries, or `hs.*`.
_Avoid_: macro, framework (both imply hidden execution)

**Interpreter**:
The component of the engine that gives inert data meaning by executing
it (dispatcher for events, send-cmd for commands, assembler for specs).
Descriptions never execute themselves.
