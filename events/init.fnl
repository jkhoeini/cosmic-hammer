
;; events/init.fnl
;; Central event registry: event-kind hierarchy + all event definitions

(local {: string?} (require :io.gitlab.andreyorst.cljlib.core))
(local {: define-event : event-hierarchy} (require :lib.event-bus))
(local {: derive!} (require :lib.hierarchy))


;; ============================================================================
;; Event Kind Hierarchy
;; ============================================================================
;;
;; :event.kind/any                         ;; Root - all events derive from this
;; ├── :event.kind.fs/any                  ;; File system events
;; │   ├── :event.kind.fs/file-change
;; │   └── :event.kind.fs/file-move
;; │
;; ├── :event.kind.window/any              ;; Window events
;; │   ├── :event.kind.window/created
;; │   ├── :event.kind.window/destroyed
;; │   ├── :event.kind.window/focused
;; │   ├── :event.kind.window/unfocused
;; │   ├── :event.kind.window/moved
;; │   └── :event.kind.window/resized
;; │
;; ├── :event.kind.app/any                 ;; Application events
;; │   ├── :event.kind.app/launched
;; │   ├── :event.kind.app/terminated
;; │   ├── :event.kind.app/activated
;; │   ├── :event.kind.app/deactivated
;; │   └── :event.kind.app/hidden
;; │
;; ├── :event.kind.screen/any              ;; Display/screen events
;; │   ├── :event.kind.screen/added
;; │   ├── :event.kind.screen/removed
;; │   └── :event.kind.screen/layout-changed
;; │
;; ├── :event.kind.space/any               ;; Spaces/desktop events
;; │   └── :event.kind.space/changed
;; │
;; ├── :event.kind.system/any              ;; System events
;; │   ├── :event.kind.system/wake
;; │   ├── :event.kind.system/sleep
;; │   ├── :event.kind.system/screens-changed
;; │   └── :event.kind.system/session-lock
;; │
;; ├── :event.kind.hotkey/any              ;; Hotkey events
;; │   └── :event.kind.hotkey/pressed
;; │
;; ├── :event.kind.usb/any                 ;; USB device events
;; │   ├── :event.kind.usb/attached
;; │   └── :event.kind.usb/detached
;; │
;; ├── :event.kind.wifi/any                ;; WiFi events
;; │   └── :event.kind.wifi/changed
;; │
;; └── :event.kind.battery/any             ;; Battery events
;;     └── :event.kind.battery/changed


;; --- File System ---
(derive! event-hierarchy :event.kind.fs/any :event.kind/any)
(derive! event-hierarchy :event.kind.fs/file-change :event.kind.fs/any)
(derive! event-hierarchy :event.kind.fs/file-move :event.kind.fs/any)

;; --- Window ---
(derive! event-hierarchy :event.kind.window/any :event.kind/any)
(derive! event-hierarchy :event.kind.window/created :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/destroyed :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/focused :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/unfocused :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/moved :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/resized :event.kind.window/any)

;; --- Application ---
(derive! event-hierarchy :event.kind.app/any :event.kind/any)
(derive! event-hierarchy :event.kind.app/launched :event.kind.app/any)
(derive! event-hierarchy :event.kind.app/terminated :event.kind.app/any)
(derive! event-hierarchy :event.kind.app/activated :event.kind.app/any)
(derive! event-hierarchy :event.kind.app/deactivated :event.kind.app/any)
(derive! event-hierarchy :event.kind.app/hidden :event.kind.app/any)

;; --- Screen/Display ---
(derive! event-hierarchy :event.kind.screen/any :event.kind/any)
(derive! event-hierarchy :event.kind.screen/added :event.kind.screen/any)
(derive! event-hierarchy :event.kind.screen/removed :event.kind.screen/any)
(derive! event-hierarchy :event.kind.screen/layout-changed :event.kind.screen/any)

;; --- Spaces/Desktop ---
(derive! event-hierarchy :event.kind.space/any :event.kind/any)
(derive! event-hierarchy :event.kind.space/changed :event.kind.space/any)

;; --- System ---
(derive! event-hierarchy :event.kind.system/any :event.kind/any)
(derive! event-hierarchy :event.kind.system/wake :event.kind.system/any)
(derive! event-hierarchy :event.kind.system/sleep :event.kind.system/any)
(derive! event-hierarchy :event.kind.system/screens-changed :event.kind.system/any)
(derive! event-hierarchy :event.kind.system/session-lock :event.kind.system/any)

;; --- Hotkey ---
(derive! event-hierarchy :event.kind.hotkey/any :event.kind/any)
(derive! event-hierarchy :event.kind.hotkey/pressed :event.kind.hotkey/any)

;; --- USB ---
(derive! event-hierarchy :event.kind.usb/any :event.kind/any)
(derive! event-hierarchy :event.kind.usb/attached :event.kind.usb/any)
(derive! event-hierarchy :event.kind.usb/detached :event.kind.usb/any)

;; --- WiFi ---
(derive! event-hierarchy :event.kind.wifi/any :event.kind/any)
(derive! event-hierarchy :event.kind.wifi/changed :event.kind.wifi/any)

;; --- Battery ---
(derive! event-hierarchy :event.kind.battery/any :event.kind/any)
(derive! event-hierarchy :event.kind.battery/changed :event.kind.battery/any)


;; ============================================================================
;; Event Definitions
;; ============================================================================

;; --- File Watcher Events ---
(define-event :file-watcher.events/file-change
              "File change detected in watched directory"
              {:file-path string?})
(derive! event-hierarchy :file-watcher.events/file-change :event.kind.fs/file-change)


{}
