hs.console.clearConsole()
_G["event-bus.debug-mode?"] = false
hs.ipc.cliInstall()
hs.window.animationDuration = 0.0
local spoons
package.preload["spoons"] = package.preload["spoons"] or function(...)
  local _local_1_ = require("lib.cljlib-shim")
  local contains_3f = _local_1_["contains?"]
  local loaded_spoons
  do
    local tbl_26_ = {}
    local i_27_ = 0
    for i, spoon in ipairs(hs.spoons.list()) do
      local val_28_ = spoon.name
      if (nil ~= val_28_) then
        i_27_ = (i_27_ + 1)
        tbl_26_[i_27_] = val_28_
      else
      end
    end
    loaded_spoons = tbl_26_
  end
  local function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
  end
  local function exec(...)
    local rst = {...}
    return hs.execute(table.concat(rst, " "), true)
  end
  if not contains_3f(loaded_spoons, "SpoonInstall") then
    local tmpdir1 = exec("mktemp -d")
    local tmpdir = trim(tmpdir1)
    local outfile = (tmpdir .. "/SpoonInstall.spoon.zip")
    exec("curl -fsSL https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip -o", outfile)
    exec("cd", tmpdir, ";", "unzip SpoonInstall.spoon.zip -d ~/.hammerspoon/Spoons/")
    exec("rm -rf ", tmpdir)
  else
  end
  hs.loadSpoon("SpoonInstall")
  local function use_spoon(spoon_name, opts)
    return spoon.SpoonInstall:andUse(spoon_name, opts)
  end
  use_spoon("Calendar", {})
  use_spoon("CircleClock", {})
  use_spoon("ClipboardTool", {start = true})
  use_spoon("Emojis", {})
  local function toggle_emojis()
    if spoon.Emojis.chooser:isVisible() then
      return spoon.Emojis.chooser:hide()
    else
      return spoon.Emojis.chooser:show()
    end
  end
  use_spoon("HSKeybindings", {})
  local hammerspoonKeybindingsIsShown = false
  local function toggleShowKeybindings()
    hammerspoonKeybindingsIsShown = not hammerspoonKeybindingsIsShown
    if hammerspoonKeybindingsIsShown then
      return spoon.HSKeybindings:show()
    else
      return spoon.HSKeybindings:hide()
    end
  end
  use_spoon("KSheet", {})
  spoon.SpoonInstall.repos.PaperWM = {url = "https://github.com/mogenson/PaperWM.spoon", desc = "PaperWM.spoon repository", branch = "release"}
  local paper_wm
  local function _6_(_241)
    return _241:bindHotkeys(_241.default_hotkeys)
  end
  paper_wm = use_spoon("PaperWM", {repo = "PaperWM", config = {window_gap = 35, screen_margin = 16, window_ratios = {0.3125, 0.421875, 0.625, 0.84375}}, fn = _6_, start = true})
  return {}
end
spoons = require("spoons")
local active_space_indicator
package.preload["active-space-indicator"] = package.preload["active-space-indicator"] or function(...)
  local menubar = nil
  local function get_active_spaces_str()
    local parts = {}
    local spaces_layout = hs.spaces.allSpaces()
    local active_spaces = hs.spaces.activeSpaces()
    local num_spaces = 0
    for _, screen in ipairs(hs.screen.allScreens()) do
      local screen_uuid = screen:getUUID()
      local active_space = active_spaces[screen_uuid]
      local screen_spaces = spaces_layout[screen_uuid]
      for i, space in ipairs(screen_spaces) do
        if (active_space and (active_space == space)) then
          table.insert(parts, tostring((i + num_spaces)))
        else
        end
      end
      num_spaces = (num_spaces + #screen_spaces)
    end
    return table.concat(parts, "|")
  end
  local function update_menubar()
    if menubar then
      return menubar:setTitle(get_active_spaces_str())
    else
      return nil
    end
  end
  local function handle_space_switch(...)
    local rest = {...}
    return update_menubar()
  end
  menubar = hs.menubar.new(true, "cosmicHammerSpaceIndicator")
  if menubar then
    menubar:setTitle(get_active_spaces_str())
  else
  end
  local space_watcher = hs.spaces.watcher.new(handle_space_switch)
  space_watcher:start()
  local screen_watcher = hs.screen.watcher.new(handle_space_switch)
  screen_watcher:start()
  local expose = hs.expose.new()
  local function _10_()
    return expose:toggleShow()
  end
  hs.hotkey.bind("ctrl-cmd", "e", "Expose", _10_)
  return {}
end
active_space_indicator = require("active-space-indicator")
local notify
package.preload["notify"] = package.preload["notify"] or function(...)
  local notification_duration = 30
  local margin = 64
  local stack_gap = 8
  local icons_dir = (os.getenv("HOME") .. "/.hammerspoon/icons")
  local icon_paths = {info = (icons_dir .. "/info.png"), warn = (icons_dir .. "/warn.png"), error = (icons_dir .. "/error.png")}
  local header_colors = {info = {red = 0.2, green = 0.4, blue = 0.6, alpha = 1}, warn = {red = 0.7, green = 0.5, blue = 0.1, alpha = 1}, error = {red = 0.7, green = 0.2, blue = 0.2, alpha = 1}}
  local active_notifications = {}
  local function move_notification_up(notif, offset)
    for _, drawing in ipairs(notif.drawings) do
      local current_frame = drawing:frame()
      local new_y = (current_frame.y - offset)
      drawing:setFrame({x = current_frame.x, y = new_y, w = current_frame.w, h = current_frame.h})
    end
    return nil
  end
  local function push_existing_notifications_up(new_height)
    local offset = (new_height + stack_gap)
    for _, notif in ipairs(active_notifications) do
      move_notification_up(notif, offset)
    end
    return nil
  end
  local function remove_notification(notif)
    if notif.timer then
      notif.timer:stop()
    else
    end
    for _, drawing in ipairs(notif.drawings) do
      drawing:delete()
    end
    local idx = nil
    for i, n in ipairs(active_notifications) do
      if (n == notif) then
        idx = i
      else
      end
    end
    if idx then
      return table.remove(active_notifications, idx)
    else
      return nil
    end
  end
  local function show_notification(title, type, message)
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    local icon_path = icon_paths[type]
    local icon_image = hs.image.imageFromPath(icon_path)
    local header_color = (header_colors[type] or header_colors.info)
    local title_font = "SF Pro Text Bold"
    local message_font = "SF Pro Text"
    local font_size = 14
    local outer_padding = 8
    local section_gap = 8
    local inner_padding = 8
    local icon_size = 18
    local icon_padding = 10
    local notif_width = 300
    local header_height = 36
    local message_padding = 12
    local close_btn_size = 18
    local close_btn_margin = 8
    local message_size = hs.drawing.getTextDrawingSize(message, {font = message_font, size = font_size})
    local wrapped_lines = math.ceil((message_size.w / (notif_width - (message_padding * 2) - (outer_padding * 2))))
    local actual_message_height = (message_size.h * math.max(1, wrapped_lines))
    local message_height = (actual_message_height + (message_padding * 2))
    local total_height = ((outer_padding * 2) + header_height + section_gap + message_height)
    local x = ((frame.x + frame.w) - notif_width - margin)
    local y = ((frame.y + frame.h) - total_height - margin - 50)
    push_existing_notifications_up(total_height)
    local drawings = {}
    local container_rect = hs.drawing.rectangle({x = x, y = y, w = notif_width, h = total_height})
    local header_rect = hs.drawing.rectangle({x = (x + outer_padding), y = (y + outer_padding), w = (notif_width - (outer_padding * 2)), h = header_height})
    local message_rect = hs.drawing.rectangle({x = (x + outer_padding), y = (y + outer_padding + header_height + section_gap), w = (notif_width - (outer_padding * 2)), h = message_height})
    local icon_drawing
    if icon_image then
      icon_drawing = hs.drawing.image({x = (x + outer_padding + icon_padding), y = (y + outer_padding + ((header_height - icon_size) / 2)), w = icon_size, h = icon_size}, icon_image)
    else
      icon_drawing = nil
    end
    local text_height = 18
    local text_x_offset
    if icon_image then
      text_x_offset = (outer_padding + icon_padding + icon_size + 8)
    else
      text_x_offset = (outer_padding + inner_padding)
    end
    local header_text = hs.drawing.text({x = (x + text_x_offset), y = (y + outer_padding + ((header_height - text_height) / 2)), w = (notif_width - text_x_offset - inner_padding - close_btn_size - close_btn_margin - outer_padding), h = text_height}, title)
    local message_text = hs.drawing.text({x = (x + outer_padding + message_padding), y = (y + outer_padding + header_height + section_gap + message_padding), w = (notif_width - (outer_padding * 2) - (message_padding * 2)), h = actual_message_height}, message)
    local close_btn_x = ((x + notif_width) - close_btn_size - close_btn_margin - outer_padding)
    local close_btn_y = (y + outer_padding + ((header_height - close_btn_size) / 2))
    local close_btn = hs.drawing.text({x = close_btn_x, y = close_btn_y, w = close_btn_size, h = close_btn_size}, "\195\151")
    container_rect:setFill(true)
    container_rect:setFillColor({white = 0.12, alpha = 0.98})
    container_rect:setStroke(true)
    container_rect:setStrokeWidth(1)
    container_rect:setStrokeColor({white = 0.25, alpha = 1})
    container_rect:setRoundedRectRadii(12, 12)
    header_rect:setFill(true)
    header_rect:setFillColor(header_color)
    header_rect:setStroke(false)
    header_rect:setRoundedRectRadii(8, 8)
    message_rect:setFill(true)
    message_rect:setFillColor({white = 0.06, alpha = 1})
    message_rect:setStroke(false)
    message_rect:setRoundedRectRadii(8, 8)
    header_text:setTextFont(title_font)
    header_text:setTextSize(14)
    header_text:setTextColor({white = 1, alpha = 1})
    message_text:setTextFont(message_font)
    message_text:setTextSize(font_size)
    message_text:setTextColor({white = 0.9, alpha = 1})
    close_btn:setTextFont("SF Pro Text")
    close_btn:setTextSize(16)
    close_btn:setTextColor({white = 1, alpha = 0.6})
    container_rect:show()
    header_rect:show()
    message_rect:show()
    if icon_drawing then
      icon_drawing:show()
    else
    end
    header_text:show()
    message_text:show()
    close_btn:show()
    table.insert(drawings, container_rect)
    table.insert(drawings, header_rect)
    table.insert(drawings, message_rect)
    if icon_drawing then
      table.insert(drawings, icon_drawing)
    else
    end
    table.insert(drawings, header_text)
    table.insert(drawings, message_text)
    table.insert(drawings, close_btn)
    local notif = {drawings = drawings, height = total_height, timer = nil}
    close_btn:setBehaviorByLabels({"canvasClickable"})
    local function _18_()
      return remove_notification(notif)
    end
    close_btn:setClickCallback(_18_)
    local function _19_()
      return remove_notification(notif)
    end
    notif["timer"] = hs.timer.doAfter(notification_duration, _19_)
    return table.insert(active_notifications, notif)
  end
  local function notify(title, type, message)
    return show_notification(title, type, message)
  end
  local function info(message)
    return notify("Cosmic Hammer", "info", message)
  end
  local function warn(message)
    return notify("Cosmic Hammer", "warn", message)
  end
  local function error(message)
    return notify("Cosmic Hammer", "error", message)
  end
  local function close_all()
    for _, notif in ipairs(active_notifications) do
      if notif.timer then
        notif.timer:stop()
      else
      end
      for _0, drawing in ipairs(notif.drawings) do
        drawing:delete()
      end
    end
    active_notifications = {}
    return nil
  end
  return {info = info, warn = warn, error = error, ["close-all"] = close_all}
end
notify = require("notify")
package.preload["events"] = package.preload["events"] or function(...)
  local _local_21_ = require("lib.cljlib-shim")
  local string_3f = _local_21_["string?"]
  local _local_53_ = require("lib.event-bus")
  local define_event = _local_53_["define-event"]
  local event_hierarchy = _local_53_["event-hierarchy"]
  local _local_54_ = require("lib.hierarchy")
  local derive_21 = _local_54_["derive!"]
  derive_21(event_hierarchy, "event.kind.fs/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.fs/file-change", "event.kind.fs/any")
  derive_21(event_hierarchy, "event.kind.fs/file-move", "event.kind.fs/any")
  derive_21(event_hierarchy, "event.kind.window/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.window/created", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/destroyed", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/focused", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/unfocused", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/moved", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/resized", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.app/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.app/launched", "event.kind.app/any")
  derive_21(event_hierarchy, "event.kind.app/terminated", "event.kind.app/any")
  derive_21(event_hierarchy, "event.kind.app/activated", "event.kind.app/any")
  derive_21(event_hierarchy, "event.kind.app/deactivated", "event.kind.app/any")
  derive_21(event_hierarchy, "event.kind.app/hidden", "event.kind.app/any")
  derive_21(event_hierarchy, "event.kind.screen/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.screen/added", "event.kind.screen/any")
  derive_21(event_hierarchy, "event.kind.screen/removed", "event.kind.screen/any")
  derive_21(event_hierarchy, "event.kind.screen/layout-changed", "event.kind.screen/any")
  derive_21(event_hierarchy, "event.kind.space/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.space/changed", "event.kind.space/any")
  derive_21(event_hierarchy, "event.kind.system/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.system/wake", "event.kind.system/any")
  derive_21(event_hierarchy, "event.kind.system/sleep", "event.kind.system/any")
  derive_21(event_hierarchy, "event.kind.system/screens-changed", "event.kind.system/any")
  derive_21(event_hierarchy, "event.kind.system/session-lock", "event.kind.system/any")
  derive_21(event_hierarchy, "event.kind.hotkey/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.hotkey/pressed", "event.kind.hotkey/any")
  derive_21(event_hierarchy, "event.kind.usb/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.usb/attached", "event.kind.usb/any")
  derive_21(event_hierarchy, "event.kind.usb/detached", "event.kind.usb/any")
  derive_21(event_hierarchy, "event.kind.wifi/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.wifi/changed", "event.kind.wifi/any")
  derive_21(event_hierarchy, "event.kind.battery/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.battery/changed", "event.kind.battery/any")
  define_event("file-watcher.events/file-change", "File change detected in watched directory", {["file-path"] = string_3f})
  derive_21(event_hierarchy, "file-watcher.events/file-change", "event.kind.fs/file-change")
  return {}
end
package.preload["lib.event-bus"] = package.preload["lib.event-bus"] or function(...)
  local _local_22_ = require("lib.cljlib-shim")
  local some = _local_22_.some
  local seq = _local_22_.seq
  local _local_46_ = require("lib.hierarchy")
  local make_hierarchy = _local_46_["make-hierarchy"]
  local descendants = _local_46_.descendants
  --[[ example-event {:event-data {:window-id 123 :x 10 :y 20} :event-name "window-move" :event-source "windows-watcher" :timestamp 0} ]]
  local events_register = {}
  local event_hierarchy = make_hierarchy()
  local function define_event(event_name, description, schema)
    if (nil ~= events_register[event_name]) then
      error(("Event already registered: " .. tostring(event_name)))
    else
    end
    events_register[event_name] = {description = description, schema = schema}
    return nil
  end
  local function event_defined_3f(event_name)
    return (nil ~= events_register[event_name])
  end
  local function valid_event_selector_3f(selector)
    return (event_defined_3f(selector) or some(event_defined_3f, seq(descendants(event_hierarchy, selector))))
  end
  local event_handlers = {}
  local function add_event_handler(key, handler)
    if (nil ~= event_handlers[key]) then
      error(("Event handler already registered: " .. tostring(key)))
    else
    end
    event_handlers[key] = handler
    return nil
  end
  local function remove_event_handler(key)
    event_handlers[key] = nil
    return nil
  end
  local processing_3f = false
  local events_queue = {}
  local function process_events()
    processing_3f = true
    while (0 < #events_queue) do
      local events = events_queue
      events_queue = {}
      for _, event in ipairs(events) do
        for _0, handler in pairs(event_handlers) do
          handler(event)
        end
      end
    end
    processing_3f = false
    return nil
  end
  local function dispatch_event(event_name, event_source, event_data)
    if (nil == events_register[event_name]) then
      print(("[WARN] dispatch-event: event '" .. tostring(event_name) .. "' not registered"))
    else
    end
    local event = {timestamp = hs.timer.secondsSinceEpoch(), ["event-name"] = event_name, ["event-source"] = event_source, ["event-data"] = event_data}
    table.insert(events_queue, event)
    if not processing_3f then
      return process_events()
    else
      return nil
    end
  end
  local function _51_(event)
    if _G["event-bus.debug-mode?"] then
      return print("got event", hs.inspect(event))
    else
      return nil
    end
  end
  add_event_handler("event-bus/debug-handler", _51_)
  return {["define-event"] = define_event, ["event-defined?"] = event_defined_3f, ["valid-event-selector?"] = valid_event_selector_3f, ["event-hierarchy"] = event_hierarchy, ["add-event-handler"] = add_event_handler, ["remove-event-handler"] = remove_event_handler, ["dispatch-event"] = dispatch_event}
end
package.preload["lib.hierarchy"] = package.preload["lib.hierarchy"] or function(...)
  local _local_23_ = require("lib.cljlib-shim")
  local hash_set = _local_23_["hash-set"]
  local conj = _local_23_.conj
  local disj = _local_23_.disj
  local contains_3f = _local_23_["contains?"]
  local into = _local_23_.into
  local mapcat = _local_23_.mapcat
  local empty_3f = _local_23_["empty?"]
  local seq = _local_23_.seq
  local function ensure_entry(h, tag)
    if (nil == h[tag]) then
      h[tag] = {parents = hash_set(), children = hash_set()}
      return nil
    else
      return nil
    end
  end
  local function parents(h, tag)
    local _26_
    do
      local t_25_ = h
      if (nil ~= t_25_) then
        t_25_ = t_25_[tag]
      else
      end
      if (nil ~= t_25_) then
        t_25_ = t_25_.parents
      else
      end
      _26_ = t_25_
    end
    return (_26_ or hash_set())
  end
  local function children(h, tag)
    local _30_
    do
      local t_29_ = h
      if (nil ~= t_29_) then
        t_29_ = t_29_[tag]
      else
      end
      if (nil ~= t_29_) then
        t_29_ = t_29_.children
      else
      end
      _30_ = t_29_
    end
    return (_30_ or hash_set())
  end
  local function ancestors(h, tag)
    local ps = parents(h, tag)
    if empty_3f(ps) then
      return ps
    else
      local function _33_(_241)
        return ancestors(h, _241)
      end
      return into(ps, mapcat(_33_, seq(ps)))
    end
  end
  local function descendants(h, tag)
    local cs = children(h, tag)
    if empty_3f(cs) then
      return cs
    else
      local function _35_(_241)
        return descendants(h, _241)
      end
      return into(cs, mapcat(_35_, seq(cs)))
    end
  end
  local function isa_3f(h, child, parent)
    if (child == parent) then
      return true
    else
      local visited = hash_set()
      local queue = {child}
      local found = false
      while (not found and (0 < #queue)) do
        local current = table.remove(queue, 1)
        local current_parents = parents(h, current)
        for p in pairs(current_parents) do
          if found then break end
          if (p == parent) then
            found = true
          else
            if not contains_3f(visited, p) then
              conj(visited, p)
              table.insert(queue, p)
            else
            end
          end
        end
      end
      return found
    end
  end
  local function derive_21(h, child, parent)
    if (child == parent) then
      error("Cannot derive a keyword from itself")
    else
    end
    if isa_3f(h, parent, child) then
      error(("Cycle detected: " .. tostring(parent) .. " already derives from " .. tostring(child)))
    else
    end
    ensure_entry(h, child)
    ensure_entry(h, parent)
    h[child]["parents"] = conj(h[child].parents, parent)
    h[parent]["children"] = conj(h[parent].children, child)
    return h
  end
  local function underive_21(h, child, parent)
    do
      local child_entry = h[child]
      if child_entry then
        child_entry["parents"] = disj(child_entry.parents, parent)
      else
      end
    end
    do
      local parent_entry = h[parent]
      if parent_entry then
        parent_entry["children"] = disj(parent_entry.children, child)
      else
      end
    end
    return h
  end
  local function make_hierarchy(_3finit_pairs)
    local h = {}
    if _3finit_pairs then
      for i = 1, #_3finit_pairs, 2 do
        local child = _3finit_pairs[i]
        local parent = _3finit_pairs[(i + 1)]
        if (child and parent) then
          derive_21(h, child, parent)
        else
        end
      end
    else
    end
    return h
  end
  return {["make-hierarchy"] = make_hierarchy, ["derive!"] = derive_21, ["underive!"] = underive_21, parents = parents, children = children, ancestors = ancestors, descendants = descendants, ["isa?"] = isa_3f}
end
require("events")
package.preload["event_sources"] = package.preload["event_sources"] or function(...)
  local _local_63_ = require("lib.source-registry")
  local start_event_source = _local_63_["start-event-source"]
  require("event_sources.file-watcher")
  start_event_source("event-source.file-watcher/config-dir", "event-source.type/file-watcher", {path = hs.configdir})
  return {}
end
package.preload["lib.source-registry"] = package.preload["lib.source-registry"] or function(...)
  local _local_55_ = require("lib.event-bus")
  local dispatch_event = _local_55_["dispatch-event"]
  local source_types_register = {}
  local source_instances_register = {}
  local function define_source_type(type_name, description, opts)
    if (nil ~= source_types_register[type_name]) then
      error(("Source type already registered: " .. tostring(type_name)))
    else
    end
    if (nil == opts["start-fn"]) then
      error(("Source type must have a :start-fn: " .. tostring(type_name)))
    else
    end
    source_types_register[type_name] = {description = description, ["config-schema"] = (opts["config-schema"] or {}), emits = (opts.emits or {}), ["start-fn"] = opts["start-fn"], ["stop-fn"] = opts["stop-fn"]}
    return nil
  end
  local function source_type_defined_3f(type_name)
    return (nil ~= source_types_register[type_name])
  end
  local function get_source_type(type_name)
    return source_types_register[type_name]
  end
  local function source_instance_exists_3f(instance_name)
    return (nil ~= source_instances_register[instance_name])
  end
  local function get_source_instance(instance_name)
    return source_instances_register[instance_name]
  end
  local function start_event_source(instance_name, type_name, config)
    if source_instance_exists_3f(instance_name) then
      error(("Source instance already exists: " .. tostring(instance_name)))
    else
    end
    local source_type = get_source_type(type_name)
    if (nil == source_type) then
      error(("Source type not found: " .. tostring(type_name)))
    else
    end
    local self = {name = instance_name, type = type_name, config = (config or {})}
    local emit
    local function _60_(event_name, event_data)
      return dispatch_event(event_name, instance_name, event_data)
    end
    emit = _60_
    local state = source_type["start-fn"](self, emit)
    source_instances_register[instance_name] = {type = type_name, config = (config or {}), state = state}
    return print(("[INFO] Started source instance: " .. tostring(instance_name)))
  end
  local function stop_event_source(instance_name)
    local instance = get_source_instance(instance_name)
    if (nil == instance) then
      print(("[WARN] stop-event-source: instance not found: " .. tostring(instance_name)))
      return nil
    else
    end
    local source_type = get_source_type(instance.type)
    if source_type["stop-fn"] then
      source_type["stop-fn"](instance.state)
    else
    end
    source_instances_register[instance_name] = nil
    return print(("[INFO] Stopped source instance: " .. tostring(instance_name)))
  end
  local function stop_all_event_sources()
    for instance_name, _ in pairs(source_instances_register) do
      stop_event_source(instance_name)
    end
    return nil
  end
  local function list_source_types()
    local names = {}
    for name, _ in pairs(source_types_register) do
      table.insert(names, name)
    end
    return names
  end
  local function list_source_instances()
    local names = {}
    for name, _ in pairs(source_instances_register) do
      table.insert(names, name)
    end
    return names
  end
  return {["source-types-register"] = source_types_register, ["source-instances-register"] = source_instances_register, ["define-source-type"] = define_source_type, ["source-type-defined?"] = source_type_defined_3f, ["get-source-type"] = get_source_type, ["source-instance-exists?"] = source_instance_exists_3f, ["get-source-instance"] = get_source_instance, ["start-event-source"] = start_event_source, ["stop-event-source"] = stop_event_source, ["stop-all-event-sources"] = stop_all_event_sources, ["list-source-types"] = list_source_types, ["list-source-instances"] = list_source_instances}
end
package.preload["event_sources.file-watcher"] = package.preload["event_sources.file-watcher"] or function(...)
  local _local_64_ = require("lib.cljlib-shim")
  local mapv = _local_64_.mapv
  local assoc = _local_64_.assoc
  local string_3f = _local_64_["string?"]
  local _local_65_ = require("lib.source-registry")
  local define_source_type = _local_65_["define-source-type"]
  local function start_file_watcher(self, emit)
    local path = self.config.path
    local handler
    local function _66_(files, attrs)
      local evs
      local function _67_(_241, _242)
        return assoc(_241, "file-path", _242)
      end
      evs = mapv(_67_, attrs, files)
      for _, ev in ipairs(evs) do
        emit("file-watcher.events/file-change", ev)
      end
      return nil
    end
    handler = _66_
    local watcher = hs.pathwatcher.new(path, handler)
    watcher:start()
    return watcher
  end
  local function stop_file_watcher(state)
    if state then
      return state:stop()
    else
      return nil
    end
  end
  define_source_type("event-source.type/file-watcher", "Watches a directory for file changes", {["config-schema"] = {path = string_3f}, emits = {"file-watcher.events/file-change"}, ["start-fn"] = start_file_watcher, ["stop-fn"] = stop_file_watcher})
  return {}
end
require("event_sources")
package.preload["behaviors"] = package.preload["behaviors"] or function(...)
  require("behaviors.reload-hammerspoon")
  require("behaviors.compile-fennel")
  local _local_104_ = require("lib.subscription-registry")
  local define_subscription = _local_104_["define-subscription"]
  define_subscription("sub/reload-on-config-change", {description = "Reload Hammerspoon when init.lua changes", behavior = "reload-hammerspoon.behaviors/reload-hammerspoon", ["source-selector"] = "event-source.file-watcher/config-dir", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription("sub/compile-on-fnl-change", {description = "Recompile Fennel when .fnl files change", behavior = "compile-fennel.behaviors/compile-fennel", ["source-selector"] = "event-source.file-watcher/config-dir", ["event-selector"] = "event.kind.fs/file-change"})
  return {}
end
package.preload["behaviors.reload-hammerspoon"] = package.preload["behaviors.reload-hammerspoon"] or function(...)
  local _local_75_ = require("lib.behavior-registry")
  local define_behavior = _local_75_["define-behavior"]
  local notify = require("notify")
  local reloading_3f = false
  local reload = hs.timer.delayed.new(0.5, hs.reload)
  local function _76_(file_change_event)
    local path
    do
      local t_77_ = file_change_event
      if (nil ~= t_77_) then
        t_77_ = t_77_["event-data"]
      else
      end
      if (nil ~= t_77_) then
        t_77_ = t_77_["file-path"]
      else
      end
      path = t_77_
    end
    if (not reloading_3f and (nil ~= path) and (".hammerspoon/init.lua" == path:sub(-21))) then
      reloading_3f = true
      notify.warn("Reloading...")
      return reload:start()
    else
      return nil
    end
  end
  define_behavior("reload-hammerspoon.behaviors/reload-hammerspoon", "When init.lua changes, reload hammerspoon.", {"event.kind.fs/file-change"}, _76_)
  return {}
end
package.preload["lib.behavior-registry"] = package.preload["lib.behavior-registry"] or function(...)
  local _local_69_ = require("lib.cljlib-shim")
  local some = _local_69_.some
  local _local_70_ = require("lib.event-bus")
  local valid_event_selector_3f = _local_70_["valid-event-selector?"]
  local event_hierarchy = _local_70_["event-hierarchy"]
  local _local_71_ = require("lib.hierarchy")
  local isa_3f = _local_71_["isa?"]
  local behaviors_register = {}
  local function define_behavior(name, desc, event_selectors, f)
    for _, selector in ipairs(event_selectors) do
      if not valid_event_selector_3f(selector) then
        print(("[WARN] define-behavior: event-selector '" .. tostring(selector) .. "' in behavior '" .. tostring(name) .. "' has no matching defined events"))
      else
      end
    end
    local behavior = {name = name, description = desc, ["respond-to"] = event_selectors, fn = f}
    behaviors_register[name] = behavior
    return nil
  end
  local function behavior_responds_to_3f(behavior_name, event_name)
    local behavior = behaviors_register[behavior_name]
    if (nil == behavior) then
      return false
    else
      local function _73_(_241)
        return isa_3f(event_hierarchy, event_name, _241)
      end
      return some(_73_, behavior["respond-to"])
    end
  end
  return {["behaviors-register"] = behaviors_register, ["define-behavior"] = define_behavior, ["behavior-responds-to?"] = behavior_responds_to_3f}
end
package.preload["behaviors.compile-fennel"] = package.preload["behaviors.compile-fennel"] or function(...)
  local _local_81_ = require("lib.behavior-registry")
  local define_behavior = _local_81_["define-behavior"]
  local function _82_(file_change_event)
    local path
    do
      local t_83_ = file_change_event
      if (nil ~= t_83_) then
        t_83_ = t_83_["event-data"]
      else
      end
      if (nil ~= t_83_) then
        t_83_ = t_83_["file-path"]
      else
      end
      path = t_83_
    end
    if ((nil ~= path) and (".fnl" == path:sub(-4))) then
      return print(hs.execute("./compile.sh", true))
    else
      return nil
    end
  end
  define_behavior("compile-fennel.behaviors/compile-fennel", "Watch fennel files in hammerspoon folder and recompile them.", {"event.kind.fs/file-change"}, _82_)
  return {}
end
package.preload["lib.subscription-registry"] = package.preload["lib.subscription-registry"] or function(...)
  local _local_87_ = require("lib.cljlib-shim")
  local hash_set = _local_87_["hash-set"]
  local conj = _local_87_.conj
  local disj = _local_87_.disj
  local into = _local_87_.into
  local seq = _local_87_.seq
  local filter = _local_87_.filter
  local _local_88_ = require("lib.event-bus")
  local valid_event_selector_3f = _local_88_["valid-event-selector?"]
  local event_hierarchy = _local_88_["event-hierarchy"]
  local _local_89_ = require("lib.behavior-registry")
  local behaviors_register = _local_89_["behaviors-register"]
  local _local_90_ = require("lib.source-registry")
  local source_instance_exists_3f = _local_90_["source-instance-exists?"]
  local _local_91_ = require("lib.hierarchy")
  local ancestors = _local_91_.ancestors
  local subscriptions_register = {}
  local subscriptions_index = {}
  local function index_add_21(subscription)
    local source = subscription["source-selector"]
    local event = subscription["event-selector"]
    local behavior = subscription.behavior
    if (nil == subscriptions_index[source]) then
      subscriptions_index[source] = {}
    else
    end
    if (nil == subscriptions_index[source][event]) then
      subscriptions_index[source][event] = hash_set()
    else
    end
    subscriptions_index[source][event] = conj(subscriptions_index[source][event], behavior)
    return nil
  end
  local function index_remove_21(subscription)
    local source = subscription["source-selector"]
    local event = subscription["event-selector"]
    local behavior = subscription.behavior
    local behavior_set
    do
      local t_94_ = subscriptions_index
      if (nil ~= t_94_) then
        t_94_ = t_94_[source]
      else
      end
      if (nil ~= t_94_) then
        t_94_ = t_94_[event]
      else
      end
      behavior_set = t_94_
    end
    if behavior_set then
      subscriptions_index[source][event] = disj(behavior_set, behavior)
      return nil
    else
      return nil
    end
  end
  local function validate_required_field_21(name, opts, field)
    if (nil == opts[field]) then
      return error(("define-subscription " .. tostring(name) .. ": missing required field " .. tostring(field)))
    else
      return nil
    end
  end
  local function validate_subscription_21(name, opts)
    validate_required_field_21(name, opts, "description")
    validate_required_field_21(name, opts, "behavior")
    validate_required_field_21(name, opts, "event-selector")
    validate_required_field_21(name, opts, "source-selector")
    if (nil ~= subscriptions_register[name]) then
      error(("Subscription already defined: " .. tostring(name)))
    else
    end
    if (nil == behaviors_register[opts.behavior]) then
      error(("define-subscription " .. tostring(name) .. ": behavior not found: " .. tostring(opts.behavior)))
    else
    end
    if not source_instance_exists_3f(opts["source-selector"]) then
      error(("define-subscription " .. tostring(name) .. ": source instance not found: " .. tostring(opts["source-selector"])))
    else
    end
    if not valid_event_selector_3f(opts["event-selector"]) then
      return error(("define-subscription " .. tostring(name) .. ": invalid event-selector: " .. tostring(opts["event-selector"])))
    else
      return nil
    end
  end
  local function define_subscription(name, opts)
    validate_subscription_21(name, opts)
    local subscription = {name = name, description = opts.description, behavior = opts.behavior, ["event-selector"] = opts["event-selector"], ["source-selector"] = opts["source-selector"], ["require-tags"] = (opts["require-tags"] or {}), ["exclude-tags"] = (opts["exclude-tags"] or {})}
    subscriptions_register[name] = subscription
    index_add_21(subscription)
    return print(("[INFO] Defined subscription: " .. tostring(name)))
  end
  local function remove_subscription(name)
    local subscription = subscriptions_register[name]
    if (nil == subscription) then
      error(("Subscription not found: " .. tostring(name)))
    else
    end
    index_remove_21(subscription)
    subscriptions_register[name] = nil
    return print(("[INFO] Removed subscription: " .. tostring(name)))
  end
  local function get_subscription(name)
    return subscriptions_register[name]
  end
  local function list_subscriptions()
    local names = {}
    for name, _ in pairs(subscriptions_register) do
      table.insert(names, name)
    end
    return names
  end
  local function subscription_defined_3f(name)
    return (nil ~= subscriptions_register[name])
  end
  local function get_subscribed_behaviors(source, event_name)
    local event_selectors = conj(ancestors(event_hierarchy, event_name), event_name)
    local source_subs = (subscriptions_index[source] or {})
    local all_behavior_names
    do
      local result = hash_set()
      for _, e in pairs(event_selectors) do
        result = into(result, (source_subs[e] or {}))
      end
      all_behavior_names = result
    end
    return seq(all_behavior_names)
  end
  return {["subscriptions-register"] = subscriptions_register, ["define-subscription"] = define_subscription, ["remove-subscription"] = remove_subscription, ["get-subscription"] = get_subscription, ["list-subscriptions"] = list_subscriptions, ["subscription-defined?"] = subscription_defined_3f, ["get-subscribed-behaviors"] = get_subscribed_behaviors}
end
require("behaviors")
package.preload["lib.dispatcher"] = package.preload["lib.dispatcher"] or function(...)
  local _local_105_ = require("lib.cljlib-shim")
  local mapv = _local_105_.mapv
  local filter = _local_105_.filter
  local seq = _local_105_.seq
  local _local_106_ = require("lib.event-bus")
  local add_event_handler = _local_106_["add-event-handler"]
  local _local_107_ = require("lib.behavior-registry")
  local behaviors_register = _local_107_["behaviors-register"]
  local behavior_responds_to_3f = _local_107_["behavior-responds-to?"]
  local _local_108_ = require("lib.subscription-registry")
  local get_subscribed_behaviors = _local_108_["get-subscribed-behaviors"]
  local _local_109_ = require("lib.source-registry")
  local source_instance_exists_3f = _local_109_["source-instance-exists?"]
  local function get_behaviors_for_event(event)
    if not source_instance_exists_3f(event["event-source"]) then
      print(("[WARN] get-behaviors-for-event: unknown source instance '" .. tostring(event["event-source"]) .. "'"))
    else
    end
    local behavior_names = (get_subscribed_behaviors(event["event-source"], event["event-name"]) or {})
    local valid_names
    local function _111_(name)
      local responds_3f = behavior_responds_to_3f(name, event["event-name"])
      if not responds_3f then
        print(("[ERROR] get-behaviors-for-event: behavior '" .. tostring(name) .. "' does not respond to event '" .. tostring(event["event-name"]) .. "'"))
      else
      end
      return responds_3f
    end
    valid_names = filter(_111_, behavior_names)
    local function _113_(name)
      local behavior = behaviors_register[name]
      if (nil == behavior) then
        print(("[ERROR] get-behaviors-for-event: behavior '" .. tostring(name) .. "' not found in registry"))
      else
      end
      return behavior
    end
    return mapv(_113_, (seq(valid_names) or {}))
  end
  local function _115_(event)
    local bs = get_behaviors_for_event(event)
    for _, behavior in pairs(bs) do
      if behavior then
        behavior.fn(event)
      else
      end
    end
    return nil
  end
  add_event_handler("dispatcher/event-handler", _115_)
  return {["get-behaviors-for-event"] = get_behaviors_for_event}
end
require("lib.dispatcher")
notify.warn("Reload Succeeded")
return {}
