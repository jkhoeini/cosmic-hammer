# 0001 — Synchronous command execution; no coroutine-based effect handling

Hammerspoon (and CosmicHammer, which inherits this) suffers from Lua's
"attempt to yield across a C-call boundary" limitation: event callbacks
arrive through the C/Obj-C bridge, so coroutine-based suspension under
them is unreliable. Free-monad-style command dialogues (behavior yields a
command, interpreter resumes it with the result) are therefore not viable.

We decided: commands execute synchronously inside `send-cmd` during a
behavior invocation. A behavior invocation is bounded by its triggering
event and never outlives it. Asynchronous outcomes (chooser selections,
timers, watchers) re-enter the system as new events, chaining behavior
invocations into *conversations* rather than parking a suspended behavior
across a callback.

Considered and rejected: coroutine-yield `send-cmd` (free-monad
interpreter) — blocked by the C-boundary constraint; parked transactions
spanning async callbacks — would break the isolation that the sequential
event loop currently provides for free.
