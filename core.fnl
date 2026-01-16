;; First thing to do: Clear console.
(hs.console.clearConsole)

;; Load notify first and show reload starting
(local notify (require :notify))
(set _G.my_notif notify)
(notify.warn "Reload Started")

(local spoons (require :spoons))
(local active-space-indicator (require :active-space-indicator))
(local file-watchers (require :file-watchers))

(set hs.window.animationDuration 0.0)

;; TODO cliInstall doesn't work due to priviledges. For now I've linked manually
(hs.ipc.cliInstall) ; ensure CLI installed


;; Last thing to do: notify that the config reload succeeded
(notify.warn "Reload Succeeded")


{}
