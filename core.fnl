;; First thing to do: Clear console.
(hs.console.clearConsole)


(local spoons (require :spoons))
(local active-space-indicator (require :active-space-indicator))
(local file-watchers (require :file-watchers))

(set hs.window.animationDuration 0.0)

;; TODO cliInstall doesn't work due to priviledges. For now I've linked manually
(hs.ipc.cliInstall) ; ensure CLI installed


;; Last thing to do: alert that the config is loaded
(hs.alert "Config is loaded successfully!")


{}
