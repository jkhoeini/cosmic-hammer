"Module for showing custom styled notifications using hs.drawing"

;; Duration in seconds for how long the notification is shown
(local notification-duration 10)

;; Margin from screen edge
(local margin 16)

;; Path to icons directory
(local icons-dir (.. (os.getenv "HOME") "/.hammerspoon/icons"))

;; Icon paths for each notification type
(local icon-paths
  {:info (.. icons-dir "/info.png")
   :warn (.. icons-dir "/warn.png")
   :error (.. icons-dir "/error.png")})

;; Header background colors for each notification type
(local header-colors
  {:info {:red 0.2 :green 0.4 :blue 0.6 :alpha 1}
   :warn {:red 0.7 :green 0.5 :blue 0.1 :alpha 1}
   :error {:red 0.7 :green 0.2 :blue 0.2 :alpha 1}})

;; Store active notification drawings for cleanup
(var active-notifications [])

(fn cleanup-notification [drawings timer-obj]
  "Clean up notification drawings and timer"
  (when timer-obj
    (: timer-obj :stop))
  (each [_ drawing (ipairs drawings)]
    (: drawing :delete)))

(fn show-notification [title type message]
  "Display a custom styled notification at bottom-right corner"
  (let [screen (hs.screen.mainScreen)
        frame (: screen :frame)
        icon-path (. icon-paths type)
        icon-image (hs.image.imageFromPath icon-path)
        header-color (or (. header-colors type) (. header-colors :info))
        
        ;; Font settings
        title-font "SF Pro Text Bold"
        message-font "SF Pro Text"
        font-size 14
        
        ;; Dimensions
        padding 12
        icon-size 20
        icon-padding 10
        notif-width 300
        header-height 40
        message-padding 12
        border-width 1
        
        ;; Calculate message height based on content
        message-size (hs.drawing.getTextDrawingSize 
                       message 
                       {:font message-font :size font-size})
        wrapped-lines (math.ceil (/ (. message-size :w) (- notif-width (* message-padding 2) (* border-width 2))))
        actual-message-height (* (. message-size :h) (math.max 1 wrapped-lines))
        message-height (+ actual-message-height (* message-padding 2))
        total-height (+ header-height message-height)
        
        ;; Position at bottom-right
        x (- (+ (. frame :x) (. frame :w)) notif-width margin)
        y (- (+ (. frame :y) (. frame :h)) total-height margin 50)  ;; 50px extra for dock
        
        ;; Create drawings array
        drawings []
        
        ;; Main container background (for rounded corners effect)
        container-rect (hs.drawing.rectangle 
                         {:x x :y y :w notif-width :h total-height})
        
        ;; Header background (colored based on type)
        header-rect (hs.drawing.rectangle 
                      {:x (+ x border-width) 
                       :y (+ y border-width) 
                       :w (- notif-width (* border-width 2)) 
                       :h (- header-height border-width)})
        
        ;; Message background (darker)
        message-rect (hs.drawing.rectangle 
                       {:x (+ x border-width) 
                        :y (+ y header-height) 
                        :w (- notif-width (* border-width 2)) 
                        :h (- message-height border-width)})
        
        ;; Icon image
        icon-drawing (when icon-image
                       (hs.drawing.image 
                         {:x (+ x icon-padding) 
                          :y (+ y (/ (- header-height icon-size) 2))
                          :w icon-size 
                          :h icon-size}
                         icon-image))
        
        ;; Header text (title only, icon is separate)
        text-x-offset (if icon-image (+ icon-padding icon-size 8) padding)
        header-text (hs.drawing.text 
                      {:x (+ x text-x-offset) 
                       :y (+ y 10) 
                       :w (- notif-width text-x-offset padding) 
                       :h 24}
                      title)
        
        ;; Message text
        message-text (hs.drawing.text 
                       {:x (+ x message-padding) 
                        :y (+ y header-height message-padding -2) 
                        :w (- notif-width (* message-padding 2)) 
                        :h actual-message-height}
                       message)]
    
    ;; Style container (border)
    (: container-rect :setFill true)
    (: container-rect :setFillColor {:white 0.25 :alpha 1})
    (: container-rect :setStroke false)
    (: container-rect :setRoundedRectRadii 10 10)
    
    ;; Style header background
    (: header-rect :setFill true)
    (: header-rect :setFillColor header-color)
    (: header-rect :setStroke false)
    (: header-rect :setRoundedRectRadii 8 8)
    
    ;; Style message background
    (: message-rect :setFill true)
    (: message-rect :setFillColor {:white 0.08 :alpha 0.98})
    (: message-rect :setStroke false)
    (: message-rect :setRoundedRectRadii 0 0)
    
    ;; Style header text
    (: header-text :setTextFont title-font)
    (: header-text :setTextSize 15)
    (: header-text :setTextColor {:white 1 :alpha 1})
    
    ;; Style message text
    (: message-text :setTextFont message-font)
    (: message-text :setTextSize font-size)
    (: message-text :setTextColor {:white 0.92 :alpha 1})
    
    ;; Show all drawings (order matters for layering)
    (: container-rect :show)
    (: header-rect :show)
    (: message-rect :show)
    (when icon-drawing (: icon-drawing :show))
    (: header-text :show)
    (: message-text :show)
    
    ;; Store drawings for cleanup
    (table.insert drawings container-rect)
    (table.insert drawings header-rect)
    (table.insert drawings message-rect)
    (when icon-drawing (table.insert drawings icon-drawing))
    (table.insert drawings header-text)
    (table.insert drawings message-text)
    
    ;; Set timer to clean up
    (let [timer-obj (hs.timer.doAfter 
                      notification-duration 
                      (fn [] (cleanup-notification drawings nil)))]
      
      ;; Store reference for potential manual cleanup
      (table.insert active-notifications {:drawings drawings :timer timer-obj}))))

(fn notify [title type message]
  "Display a styled notification.
   Parameters:
   - title: The notification title (shown bold at top with icon)
   - type: The notification type (:info, :warn, or :error)
   - message: The notification body message"
  (show-notification title type message))

(fn info [message]
  "Display an info notification with 'Cosmic Hammer' branding"
  (notify "Cosmic Hammer" :info message))

(fn warn [message]
  "Display a warning notification with 'Cosmic Hammer' branding"
  (notify "Cosmic Hammer" :warn message))

(fn error [message]
  "Display an error notification with 'Cosmic Hammer' branding"
  (notify "Cosmic Hammer" :error message))

(fn close-all []
  "Close all active notifications"
  (each [_ notif (ipairs active-notifications)]
    (cleanup-notification (. notif :drawings) (. notif :timer)))
  (set active-notifications []))

{: info
 : warn
 : error
 : close-all}
