
;; Menubar indicator showing active space on each monitor
;; Format: [2] [1] where each bracketed number is the active space per screen

(var menubar nil)

(fn get-active-spaces-str []
  "Returns a compact string showing active space per monitor, e.g. '3|5'"
  (let [parts {}
        spaces-layout (hs.spaces.allSpaces)
        active-spaces (hs.spaces.activeSpaces)]
    (var num-spaces 0)
    (each [_ screen (ipairs (hs.screen.allScreens))]
      (local screen-uuid (screen:getUUID))
      (local active-space (. active-spaces screen-uuid))
      (local screen-spaces (. spaces-layout screen-uuid))
      (each [i space (ipairs screen-spaces)]
        (when (and active-space (= active-space space))
          (table.insert parts (tostring (+ i num-spaces)))))
      (set num-spaces (+ num-spaces (length screen-spaces))))
    (table.concat parts "|")))

(fn update-menubar []
  "Update the menubar title with current active spaces"
  (when menubar
    (menubar:setTitle (get-active-spaces-str))))

(fn handle-space-switch [& rest]
  (update-menubar))

;; Create menubar item with autosave name so macOS remembers its position
(set menubar (hs.menubar.new true "cosmicHammerSpaceIndicator"))
(when menubar
  (menubar:setTitle (get-active-spaces-str)))

;; Watch for space changes
(local space-watcher (hs.spaces.watcher.new handle-space-switch))
(: space-watcher :start)

;; Watch for screen changes (monitors added/removed)
(local screen-watcher (hs.screen.watcher.new handle-space-switch))
(: screen-watcher :start)

;; TODO proper shortcut and configs
(local expose (hs.expose.new))
(hs.hotkey.bind :ctrl-cmd :e :Expose (fn [] (expose:toggleShow)))

{}
