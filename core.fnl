;; First thing to do: Clear console.
(hs.console.clearConsole)

;; TODO cliInstall doesn't work due to priviledges. For now I've linked manually
(hs.ipc.cliInstall) ; ensure CLI installed


(set hs.window.animationDuration 0.0)


(local spoons (require :spoons))
(local active-space-indicator (require :active-space-indicator))
(local notify (require :notify))

;; Load events first, then behaviors
(require :events)
(require :behaviors)


(notify.warn "Reload Succeeded")

{}
