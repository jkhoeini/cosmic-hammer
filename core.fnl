;; First thing to do: Clear console.
(hs.console.clearConsole)


(local spoons (require :spoons))
(local active-space-indicator (require :active-space-indicator))
(local window-ops (require :window-ops))
(local file-watchers (require :file-watchers))

(set hs.hints.style :vimperator)
(set hs.hints.showTitleThresh 4)
(set hs.hints.titleMaxSize 10)
(set hs.hints.fontSize 30)
(set hs.window.animationDuration 0.0)

(hs.grid.setMargins [0 0])
(hs.grid.setGrid "3x2")

;; TODO cliInstall doesn't work due to priviledges. For now I've linked manually
(hs.ipc.cliInstall) ; ensure CLI installed


;; Last thing to do: alert that the config is loaded
(hs.alert "Config is loaded successfully!")


{}
