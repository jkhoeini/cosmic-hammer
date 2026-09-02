
;; commands/open-emacs.fnl
;; Command: open a new emacsclient frame

(local {: make-command} (require :sheaf.command-registry))

(local emacsclient-path
  (let [app (hs.application.find "Emacs")]
    (if app
        (-> app (: :path) (: :gsub "Emacs.app" "bin/emacsclient"))
        "/opt/homebrew/bin/emacsclient")))

;; emacsclient resolves the server socket at $XDG_RUNTIME_DIR/emacs/server
;; (falling back to $TMPDIR/emacs/server, then /tmp/emacs/server).  GUI apps
;; launched by launchd inherit neither XDG_RUNTIME_DIR nor TMPDIR, so the
;; socket is never found and the hotkey silently fails.  On macOS the per-user
;; temp dir (where the nix emacs daemon puts its socket) is available via
;; `getconf DARWIN_USER_TEMP_DIR` regardless of env, so use that as a last
;; resort and pass the path explicitly via --socket-name.
(fn resolve-server-socket []
  (let [xdg-runtime (os.getenv "XDG_RUNTIME_DIR")
        tmpdir (os.getenv "TMPDIR")]
    (if (or xdg-runtime tmpdir)
        (.. (string.gsub (or xdg-runtime tmpdir) "/+$" "") "/emacs/server")
        ;; launchd GUI context: neither var is set.  Ask the system for the
        ;; per-user temp dir, which is where the emacs daemon's socket lives.
        (let [handle (io.popen "getconf DARWIN_USER_TEMP_DIR 2>/dev/null")]
          (if handle
              (let [dir (handle:read "*l")]
                (handle:close)
                (if (and dir (not= dir ""))
                    (.. (string.gsub dir "/+$" "") "/emacs/server")
                    "/tmp/emacs/server"))
              "/tmp/emacs/server")))))

(local server-socket (resolve-server-socket))

(local open-emacs-command
  (make-command
   :emacs.commands/open-emacs
   "Open a new emacsclient frame"
   {:fn (fn [component params]
          (io.popen (.. "'" emacsclient-path "' --socket-name '" server-socket "' -n -c &"))
          (hs.timer.doAfter 0.3
            (fn []
              (let [app (hs.application.find "Emacs")]
                (when app (: app :activate)))))
          nil)}))

{: open-emacs-command}
