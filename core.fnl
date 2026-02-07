;; First thing to do: Clear console.
(hs.console.clearConsole)

;; Debug mode for event-bus logging
(tset _G :event-bus.debug-mode? false)

;; TODO cliInstall doesn't work due to priviledges. For now I've linked manually
(hs.ipc.cliInstall) ; ensure CLI installed


(set hs.window.animationDuration 0.0)


(local spoons (require :spoons))
(local active-space-indicator (require :active-space-indicator))
(local notify (require :notify))

;; Load events first (creates registry), then event sources, then behaviors
(local {: event-registry} (require :events))
(require :event_sources)
(require :behaviors)

;; Register event handlers (side effect when dispatcher is required)
(require :lib.dispatcher)

;; Start event loop
(local {: start-event-loop!} (require :lib.event-loop))
(start-event-loop! event-registry)


(notify.warn "Reload Succeeded")

{}
