
(local {: apps-filter} (require :apps-filter))


(fn calc-thumbnail-size []
  "Calculates the height of thumbnail in pixels based on the screen size
  @TODO Make this advisable when #102 lands"
  (let [screen (hs.screen.mainScreen)
        {: h} (: screen :currentMode)]
    (/ h 2)))

(var switcher
     (hs.window.switcher.new
      apps-filter
      {:textSize 12
       :showTitles false
       :showThumbnails false
       :showSelectedTitle true
       :selectedThumbnailSize (calc-thumbnail-size)
       :backgroundColor [0 0 0 0]}))

(fn prev-app []
  "Open the fancy hammerspoon window switcher and move the cursor to the previous
  app.
  Runs side-effects
  Returns nil"
  (switcher:previous))

(fn next-app []
  "Open the fancy hammerspoon window switcher and move the cursor to next app.
  Runs side-effects
  Returns nil"
  (switcher:next))

{: prev-app
 : next-app}
 
