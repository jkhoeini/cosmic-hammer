
(local {: bind-global-keys
        : unbind-global-keys} (require :lib.bind))

(local bindings
       (bind-global-keys
        [{:mods [:alt]
          :key :space
          :action "lib.modal:activate-modal"}
         {:mods [:cmd :alt]
          :key :n
          :action "app-switcher:next-app"}
         {:mods [:cmd :alt]
          :key :p
          :action "app-switcher:prev-app"}
         {:mods [:cmd :ctrl]
          :key "`"
          :action hs.toggleConsole}
         {:mods [:cmd :ctrl]
          :key :o
          :action "emacs:edit-with-emacs"}]))

(fn unbind-keys []
  (unbind-global-keys bindings))

{: unbind-keys}
