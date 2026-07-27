# 0002 — Subscription :params for per-wiring configuration

Behaviors were closing over instance configuration at definition time
(e.g. nine switch-to-space behaviors differing only in a closed-over
`{:index i}`), exploding behavior definitions. We decided subscriptions
carry an optional `:params` table, threaded to the behavior fn as a 5th
argument (Lua ignores extra args, so existing 4-arg behaviors are
unaffected).

The complementarity rule that governs the two context mechanisms:
behavior **inputs** (via `:input-tag` + shapes) serve shared, live,
many-reader context — component state read fresh at each event.
Subscription **:params** serve per-wiring, static, one-reader
configuration — choices frozen in the wiring. Facts live in state;
choices live in wiring.

Considered and rejected: inputs-as-params (nine config components + nine
tags is a worse explosion, and files choices under facts); deriving
params from event data (couples the rule to the chord — rebinding
focus-left to another key would break the behavior); definition-time
closures (freezes layer choices into the definition stratum). Commands
remain part of a behavior's effect type and are not parameterizable via
subscriptions; runtime selection among the *declared* commands is
ordinary behavior logic (url-routing already does this).
