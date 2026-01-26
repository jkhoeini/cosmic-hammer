hs.console.clearConsole()
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
    local function _8_()
      return remove_notification(notif)
    end
    close_btn:setClickCallback(_8_)
    local function _9_()
      return remove_notification(notif)
    end
    notif["timer"] = hs.timer.doAfter(notification_duration, _9_)
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
_G.my_notif = notify
notify.warn("Reload Started")
local spoons
package.preload["spoons"] = package.preload["spoons"] or function(...)
  local _local_1551_ = require("io.gitlab.andreyorst.cljlib.core")
  local contains_3f = _local_1551_["contains?"]
  local fnl = require("fennel")
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
  local function _1556_(_241)
    return _241:bindHotkeys(_241.default_hotkeys)
  end
  paper_wm = use_spoon("PaperWM", {repo = "PaperWM", config = {window_gap = 35, screen_margin = 16, window_ratios = {0.3125, 0.421875, 0.625, 0.84375}}, fn = _1556_, start = true})
  return {}
end
package.preload["io.gitlab.andreyorst.cljlib.core"] = package.preload["io.gitlab.andreyorst.cljlib.core"] or function(...)
  local function _11_()
    return "#<namespace: core>"
  end
  --[[ "MIT License
  
  Copyright (c) 2022 Andrey Listopadov
  
  Permission is hereby granted‚ free of charge‚ to any person obtaining a copy
  of this software and associated documentation files (the “Software”)‚ to deal
  in the Software without restriction‚ including without limitation the rights
  to use‚ copy‚ modify‚ merge‚ publish‚ distribute‚ sublicense‚ and/or sell
  copies of the Software‚ and to permit persons to whom the Software is
  furnished to do so‚ subject to the following conditions：
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED “AS IS”‚ WITHOUT WARRANTY OF ANY KIND‚ EXPRESS OR
  IMPLIED‚ INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY‚
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM‚ DAMAGES OR OTHER
  LIABILITY‚ WHETHER IN AN ACTION OF CONTRACT‚ TORT OR OTHERWISE‚ ARISING FROM‚
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE." ]]
  local _local_848_ = {setmetatable({}, {__fennelview = _11_, __name = "namespace"}), require("io.gitlab.andreyorst.lazy-seq"), require("io.gitlab.andreyorst.itable"), require("io.gitlab.andreyorst.reduced"), require("io.gitlab.andreyorst.inst"), require("io.gitlab.andreyorst.async")}, nil
  local core = _local_848_[1]
  local lazy = _local_848_[2]
  local itable = _local_848_[3]
  local rdc = _local_848_[4]
  local lua_inst = _local_848_[5]
  local a = _local_848_[6]
  core.__VERSION = "0.1.239"
  local function unpack_2a(x, ...)
    if core["seq?"](x) then
      return lazy.unpack(x)
    else
      return itable.unpack(x, ...)
    end
  end
  local function pack_2a(...)
    local tmp_9_ = {...}
    tmp_9_["n"] = select("#", ...)
    return tmp_9_
  end
  local function pairs_2a(t)
    local case_850_ = getmetatable(t)
    if ((_G.type(case_850_) == "table") and (nil ~= case_850_.__pairs)) then
      local p = case_850_.__pairs
      return p(t)
    else
      local _ = case_850_
      return pairs(t)
    end
  end
  local function ipairs_2a(t)
    local case_852_ = getmetatable(t)
    if ((_G.type(case_852_) == "table") and (nil ~= case_852_.__ipairs)) then
      local i = case_852_.__ipairs
      return i(t)
    else
      local _ = case_852_
      return ipairs(t)
    end
  end
  local function length_2a(t)
    local case_854_ = getmetatable(t)
    if ((_G.type(case_854_) == "table") and (nil ~= case_854_.__len)) then
      local l = case_854_.__len
      return l(t)
    else
      local _ = case_854_
      return #t
    end
  end
  local apply
  do
    local v_27_auto
    local function apply0(...)
      local case_857_ = select("#", ...)
      if (case_857_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "apply"))
      elseif (case_857_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "apply"))
      elseif (case_857_ == 2) then
        local f, args = ...
        return f(unpack_2a(args))
      elseif (case_857_ == 3) then
        local f, a0, args = ...
        return f(a0, unpack_2a(args))
      elseif (case_857_ == 4) then
        local f, a0, b, args = ...
        return f(a0, b, unpack_2a(args))
      elseif (case_857_ == 5) then
        local f, a0, b, c, args = ...
        return f(a0, b, c, unpack_2a(args))
      else
        local _ = case_857_
        local _let_858_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_858_.list
        local _let_859_ = list_38_auto(...)
        local f = _let_859_[1]
        local a0 = _let_859_[2]
        local b = _let_859_[3]
        local c = _let_859_[4]
        local d = _let_859_[5]
        local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_859_, 6)
        local flat_args = {}
        local len = (length_2a(args) - 1)
        for i = 1, len do
          flat_args[i] = args[i]
        end
        for i, a1 in pairs_2a(args[(len + 1)]) do
          flat_args[(i + len)] = a1
        end
        return f(a0, b, c, d, unpack_2a(flat_args))
      end
    end
    v_27_auto = apply0
    core["apply"] = v_27_auto
    apply = v_27_auto
  end
  local add
  do
    local v_27_auto
    local function add0(...)
      local case_861_ = select("#", ...)
      if (case_861_ == 0) then
        return 0
      elseif (case_861_ == 1) then
        local a0 = ...
        return a0
      elseif (case_861_ == 2) then
        local a0, b = ...
        return (a0 + b)
      elseif (case_861_ == 3) then
        local a0, b, c = ...
        return (a0 + b + c)
      elseif (case_861_ == 4) then
        local a0, b, c, d = ...
        return (a0 + b + c + d)
      else
        local _ = case_861_
        local _let_862_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_862_.list
        local _let_863_ = list_38_auto(...)
        local a0 = _let_863_[1]
        local b = _let_863_[2]
        local c = _let_863_[3]
        local d = _let_863_[4]
        local rest = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_863_, 5)
        return apply(add0, (a0 + b + c + d), rest)
      end
    end
    v_27_auto = add0
    core["add"] = v_27_auto
    add = v_27_auto
  end
  local sub
  do
    local v_27_auto
    local function sub0(...)
      local case_865_ = select("#", ...)
      if (case_865_ == 0) then
        return 0
      elseif (case_865_ == 1) then
        local a0 = ...
        return ( - a0)
      elseif (case_865_ == 2) then
        local a0, b = ...
        return (a0 - b)
      elseif (case_865_ == 3) then
        local a0, b, c = ...
        return (a0 - b - c)
      elseif (case_865_ == 4) then
        local a0, b, c, d = ...
        return (a0 - b - c - d)
      else
        local _ = case_865_
        local _let_866_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_866_.list
        local _let_867_ = list_38_auto(...)
        local a0 = _let_867_[1]
        local b = _let_867_[2]
        local c = _let_867_[3]
        local d = _let_867_[4]
        local rest = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_867_, 5)
        return apply(sub0, (a0 - b - c - d), rest)
      end
    end
    v_27_auto = sub0
    core["sub"] = v_27_auto
    sub = v_27_auto
  end
  local mul
  do
    local v_27_auto
    local function mul0(...)
      local case_869_ = select("#", ...)
      if (case_869_ == 0) then
        return 1
      elseif (case_869_ == 1) then
        local a0 = ...
        return a0
      elseif (case_869_ == 2) then
        local a0, b = ...
        return (a0 * b)
      elseif (case_869_ == 3) then
        local a0, b, c = ...
        return (a0 * b * c)
      elseif (case_869_ == 4) then
        local a0, b, c, d = ...
        return (a0 * b * c * d)
      else
        local _ = case_869_
        local _let_870_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_870_.list
        local _let_871_ = list_38_auto(...)
        local a0 = _let_871_[1]
        local b = _let_871_[2]
        local c = _let_871_[3]
        local d = _let_871_[4]
        local rest = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_871_, 5)
        return apply(mul0, (a0 * b * c * d), rest)
      end
    end
    v_27_auto = mul0
    core["mul"] = v_27_auto
    mul = v_27_auto
  end
  local div
  do
    local v_27_auto
    local function div0(...)
      local case_873_ = select("#", ...)
      if (case_873_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "div"))
      elseif (case_873_ == 1) then
        local a0 = ...
        return (1 / a0)
      elseif (case_873_ == 2) then
        local a0, b = ...
        return (a0 / b)
      elseif (case_873_ == 3) then
        local a0, b, c = ...
        return (a0 / b / c)
      elseif (case_873_ == 4) then
        local a0, b, c, d = ...
        return (a0 / b / c / d)
      else
        local _ = case_873_
        local _let_874_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_874_.list
        local _let_875_ = list_38_auto(...)
        local a0 = _let_875_[1]
        local b = _let_875_[2]
        local c = _let_875_[3]
        local d = _let_875_[4]
        local rest = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_875_, 5)
        return apply(div0, (a0 / b / c / d), rest)
      end
    end
    v_27_auto = div0
    core["div"] = v_27_auto
    div = v_27_auto
  end
  local le
  do
    local v_27_auto
    local function le0(...)
      local case_877_ = select("#", ...)
      if (case_877_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "le"))
      elseif (case_877_ == 1) then
        local _ = ...
        return true
      elseif (case_877_ == 2) then
        local a0, b = ...
        return (a0 <= b)
      else
        local _ = case_877_
        local _let_878_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_878_.list
        local _let_879_ = list_38_auto(...)
        local a0 = _let_879_[1]
        local b = _let_879_[2]
        local _let_880_ = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_879_, 3)
        local c = _let_880_[1]
        local d = _let_880_[2]
        local more = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_880_, 3)
        if (a0 <= b) then
          if d then
            return apply(le0, b, c, d, more)
          else
            return (b <= c)
          end
        else
          return false
        end
      end
    end
    v_27_auto = le0
    core["le"] = v_27_auto
    le = v_27_auto
  end
  local lt
  do
    local v_27_auto
    local function lt0(...)
      local case_884_ = select("#", ...)
      if (case_884_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "lt"))
      elseif (case_884_ == 1) then
        local _ = ...
        return true
      elseif (case_884_ == 2) then
        local a0, b = ...
        return (a0 < b)
      else
        local _ = case_884_
        local _let_885_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_885_.list
        local _let_886_ = list_38_auto(...)
        local a0 = _let_886_[1]
        local b = _let_886_[2]
        local _let_887_ = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_886_, 3)
        local c = _let_887_[1]
        local d = _let_887_[2]
        local more = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_887_, 3)
        if (a0 < b) then
          if d then
            return apply(lt0, b, c, d, more)
          else
            return (b < c)
          end
        else
          return false
        end
      end
    end
    v_27_auto = lt0
    core["lt"] = v_27_auto
    lt = v_27_auto
  end
  local ge
  do
    local v_27_auto
    local function ge0(...)
      local case_891_ = select("#", ...)
      if (case_891_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "ge"))
      elseif (case_891_ == 1) then
        local _ = ...
        return true
      elseif (case_891_ == 2) then
        local a0, b = ...
        return (a0 >= b)
      else
        local _ = case_891_
        local _let_892_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_892_.list
        local _let_893_ = list_38_auto(...)
        local a0 = _let_893_[1]
        local b = _let_893_[2]
        local _let_894_ = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_893_, 3)
        local c = _let_894_[1]
        local d = _let_894_[2]
        local more = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_894_, 3)
        if (a0 >= b) then
          if d then
            return apply(ge0, b, c, d, more)
          else
            return (b >= c)
          end
        else
          return false
        end
      end
    end
    v_27_auto = ge0
    core["ge"] = v_27_auto
    ge = v_27_auto
  end
  local gt
  do
    local v_27_auto
    local function gt0(...)
      local case_898_ = select("#", ...)
      if (case_898_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "gt"))
      elseif (case_898_ == 1) then
        local _ = ...
        return true
      elseif (case_898_ == 2) then
        local a0, b = ...
        return (a0 > b)
      else
        local _ = case_898_
        local _let_899_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_899_.list
        local _let_900_ = list_38_auto(...)
        local a0 = _let_900_[1]
        local b = _let_900_[2]
        local _let_901_ = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_900_, 3)
        local c = _let_901_[1]
        local d = _let_901_[2]
        local more = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_901_, 3)
        if (a0 > b) then
          if d then
            return apply(gt0, b, c, d, more)
          else
            return (b > c)
          end
        else
          return false
        end
      end
    end
    v_27_auto = gt0
    core["gt"] = v_27_auto
    gt = v_27_auto
  end
  local inc
  do
    local v_27_auto
    local function inc0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "inc"))
        else
        end
      end
      return (x + 1)
    end
    v_27_auto = inc0
    core["inc"] = v_27_auto
    inc = v_27_auto
  end
  local dec
  do
    local v_27_auto
    local function dec0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "dec"))
        else
        end
      end
      return (x - 1)
    end
    v_27_auto = dec0
    core["dec"] = v_27_auto
    dec = v_27_auto
  end
  local class
  do
    local v_27_auto
    local function class0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "class"))
        else
        end
      end
      local case_908_ = type(x)
      if (case_908_ == "table") then
        local case_909_ = getmetatable(x)
        if ((_G.type(case_909_) == "table") and (nil ~= case_909_["cljlib/type"])) then
          local t = case_909_["cljlib/type"]
          return t
        else
          local _ = case_909_
          return "table"
        end
      elseif (nil ~= case_908_) then
        local t = case_908_
        return t
      else
        return nil
      end
    end
    v_27_auto = class0
    core["class"] = v_27_auto
    class = v_27_auto
  end
  local constantly
  do
    local v_27_auto
    local function constantly0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "constantly"))
        else
        end
      end
      local function _913_()
        return x
      end
      return _913_
    end
    v_27_auto = constantly0
    core["constantly"] = v_27_auto
    constantly = v_27_auto
  end
  local complement
  do
    local v_27_auto
    local function complement0(...)
      local f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "complement"))
        else
        end
      end
      local function fn_915_(...)
        local case_916_ = select("#", ...)
        if (case_916_ == 0) then
          return not f()
        elseif (case_916_ == 1) then
          local a0 = ...
          return not f(a0)
        elseif (case_916_ == 2) then
          local a0, b = ...
          return not f(a0, b)
        else
          local _ = case_916_
          local _let_917_ = require("io.gitlab.andreyorst.cljlib.core")
          local list_38_auto = _let_917_.list
          local _let_918_ = list_38_auto(...)
          local a0 = _let_918_[1]
          local b = _let_918_[2]
          local cs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_918_, 3)
          return not apply(f, a0, b, cs)
        end
      end
      return fn_915_
    end
    v_27_auto = complement0
    core["complement"] = v_27_auto
    complement = v_27_auto
  end
  local identity
  do
    local v_27_auto
    local function identity0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "identity"))
        else
        end
      end
      return x
    end
    v_27_auto = identity0
    core["identity"] = v_27_auto
    identity = v_27_auto
  end
  local comp
  do
    local v_27_auto
    local function comp0(...)
      local case_921_ = select("#", ...)
      if (case_921_ == 0) then
        return identity
      elseif (case_921_ == 1) then
        local f = ...
        return f
      elseif (case_921_ == 2) then
        local f, g = ...
        local function fn_922_(...)
          local case_923_ = select("#", ...)
          if (case_923_ == 0) then
            return f(g())
          elseif (case_923_ == 1) then
            local x = ...
            return f(g(x))
          elseif (case_923_ == 2) then
            local x, y = ...
            return f(g(x, y))
          elseif (case_923_ == 3) then
            local x, y, z = ...
            return f(g(x, y, z))
          else
            local _ = case_923_
            local _let_924_ = require("io.gitlab.andreyorst.cljlib.core")
            local list_38_auto = _let_924_.list
            local _let_925_ = list_38_auto(...)
            local x = _let_925_[1]
            local y = _let_925_[2]
            local z = _let_925_[3]
            local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_925_, 4)
            return f(apply(g, x, y, z, args))
          end
        end
        return fn_922_
      else
        local _ = case_921_
        local _let_927_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_927_.list
        local _let_928_ = list_38_auto(...)
        local f = _let_928_[1]
        local g = _let_928_[2]
        local fs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_928_, 3)
        return core.reduce(comp0, core.cons(f, core.cons(g, fs)))
      end
    end
    v_27_auto = comp0
    core["comp"] = v_27_auto
    comp = v_27_auto
  end
  local eq
  do
    local v_27_auto
    local function eq0(...)
      local case_930_ = select("#", ...)
      if (case_930_ == 0) then
        return true
      elseif (case_930_ == 1) then
        local _ = ...
        return true
      elseif (case_930_ == 2) then
        local a0, b = ...
        if rawequal(a0, b) then
          return true
        elseif ((a0 == b) and (b == a0)) then
          return true
        else
          local _931_ = type(a0)
          if (("table" == _931_) and (_931_ == type(b))) then
            local res, count_a = true, 0
            for k, v in pairs_2a(a0) do
              if not res then break end
              local function _932_(...)
                local res0, done = nil, nil
                for k_2a, v0 in pairs_2a(b) do
                  if done then break end
                  if eq0(k_2a, k) then
                    res0, done = v0, true
                  else
                  end
                end
                return res0
              end
              res = eq0(v, _932_(...))
              count_a = (count_a + 1)
            end
            if res then
              local count_b
              do
                local res0 = 0
                for _, _0 in pairs_2a(b) do
                  res0 = (res0 + 1)
                end
                count_b = res0
              end
              res = (count_a == count_b)
            else
            end
            return res
          else
            return false
          end
        end
      else
        local _ = case_930_
        local _let_936_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_936_.list
        local _let_937_ = list_38_auto(...)
        local a0 = _let_937_[1]
        local b = _let_937_[2]
        local cs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_937_, 3)
        return (eq0(a0, b) and apply(eq0, b, cs))
      end
    end
    v_27_auto = eq0
    core["eq"] = v_27_auto
    eq = v_27_auto
  end
  local function deep_index(tbl, key)
    local res = nil
    for k, v in pairs_2a(tbl) do
      if res then break end
      if eq(k, key) then
        res = v
      else
        res = nil
      end
    end
    return res
  end
  local function deep_newindex(tbl, key, val)
    local done = false
    if ("table" == type(key)) then
      for k, _ in pairs_2a(tbl) do
        if done then break end
        if eq(k, key) then
          rawset(tbl, k, val)
          done = true
        else
        end
      end
    else
    end
    if not done then
      return rawset(tbl, key, val)
    else
      return nil
    end
  end
  local memoize
  do
    local v_27_auto
    local function memoize0(...)
      local f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "memoize"))
        else
        end
      end
      local memo = setmetatable({}, {__index = deep_index})
      local function fn_944_(...)
        local _let_945_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_945_.list
        local _let_946_ = list_38_auto(...)
        local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_946_, 1)
        local case_947_ = memo[args]
        if (nil ~= case_947_) then
          local res = case_947_
          return unpack_2a(res, 1, res.n)
        else
          local _ = case_947_
          local res = pack_2a(f(...))
          memo[args] = res
          return unpack_2a(res, 1, res.n)
        end
      end
      return fn_944_
    end
    v_27_auto = memoize0
    core["memoize"] = v_27_auto
    memoize = v_27_auto
  end
  local deref
  do
    local v_27_auto
    local function deref0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "deref"))
        else
        end
      end
      local case_950_ = getmetatable(x)
      if ((_G.type(case_950_) == "table") and (nil ~= case_950_["cljlib/deref"])) then
        local f = case_950_["cljlib/deref"]
        return f(x)
      else
        local _ = case_950_
        return error("object doesn't implement cljlib/deref metamethod", 2)
      end
    end
    v_27_auto = deref0
    core["deref"] = v_27_auto
    deref = v_27_auto
  end
  local empty
  do
    local v_27_auto
    local function empty0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "empty"))
        else
        end
      end
      local case_953_ = getmetatable(x)
      if ((_G.type(case_953_) == "table") and (nil ~= case_953_["cljlib/empty"])) then
        local f = case_953_["cljlib/empty"]
        return f()
      else
        local _ = case_953_
        local case_954_ = type(x)
        if (case_954_ == "table") then
          return {}
        elseif (case_954_ == "string") then
          return ""
        else
          local _0 = case_954_
          return error(("don't know how to create empty variant of type " .. _0))
        end
      end
    end
    v_27_auto = empty0
    core["empty"] = v_27_auto
    empty = v_27_auto
  end
  local nil_3f
  do
    local v_27_auto
    local function nil_3f0(...)
      local case_957_ = select("#", ...)
      if (case_957_ == 0) then
        return true
      elseif (case_957_ == 1) then
        local x = ...
        return (x == nil)
      else
        local _ = case_957_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "nil?"))
      end
    end
    v_27_auto = nil_3f0
    core["nil?"] = v_27_auto
    nil_3f = v_27_auto
  end
  local zero_3f
  do
    local v_27_auto
    local function zero_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "zero?"))
        else
        end
      end
      return (x == 0)
    end
    v_27_auto = zero_3f0
    core["zero?"] = v_27_auto
    zero_3f = v_27_auto
  end
  local pos_3f
  do
    local v_27_auto
    local function pos_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "pos?"))
        else
        end
      end
      return (x > 0)
    end
    v_27_auto = pos_3f0
    core["pos?"] = v_27_auto
    pos_3f = v_27_auto
  end
  local neg_3f
  do
    local v_27_auto
    local function neg_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "neg?"))
        else
        end
      end
      return (x < 0)
    end
    v_27_auto = neg_3f0
    core["neg?"] = v_27_auto
    neg_3f = v_27_auto
  end
  local even_3f
  do
    local v_27_auto
    local function even_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "even?"))
        else
        end
      end
      return ((x % 2) == 0)
    end
    v_27_auto = even_3f0
    core["even?"] = v_27_auto
    even_3f = v_27_auto
  end
  local odd_3f
  do
    local v_27_auto
    local function odd_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "odd?"))
        else
        end
      end
      return not even_3f(x)
    end
    v_27_auto = odd_3f0
    core["odd?"] = v_27_auto
    odd_3f = v_27_auto
  end
  local string_3f
  do
    local v_27_auto
    local function string_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "string?"))
        else
        end
      end
      return (type(x) == "string")
    end
    v_27_auto = string_3f0
    core["string?"] = v_27_auto
    string_3f = v_27_auto
  end
  local boolean_3f
  do
    local v_27_auto
    local function boolean_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "boolean?"))
        else
        end
      end
      return (type(x) == "boolean")
    end
    v_27_auto = boolean_3f0
    core["boolean?"] = v_27_auto
    boolean_3f = v_27_auto
  end
  local true_3f
  do
    local v_27_auto
    local function true_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "true?"))
        else
        end
      end
      return (x == true)
    end
    v_27_auto = true_3f0
    core["true?"] = v_27_auto
    true_3f = v_27_auto
  end
  local false_3f
  do
    local v_27_auto
    local function false_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "false?"))
        else
        end
      end
      return (x == false)
    end
    v_27_auto = false_3f0
    core["false?"] = v_27_auto
    false_3f = v_27_auto
  end
  local int_3f
  do
    local v_27_auto
    local function int_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "int?"))
        else
        end
      end
      return ((type(x) == "number") and (x == math.floor(x)))
    end
    v_27_auto = int_3f0
    core["int?"] = v_27_auto
    int_3f = v_27_auto
  end
  local pos_int_3f
  do
    local v_27_auto
    local function pos_int_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "pos-int?"))
        else
        end
      end
      return (int_3f(x) and pos_3f(x))
    end
    v_27_auto = pos_int_3f0
    core["pos-int?"] = v_27_auto
    pos_int_3f = v_27_auto
  end
  local neg_int_3f
  do
    local v_27_auto
    local function neg_int_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "neg-int?"))
        else
        end
      end
      return (int_3f(x) and neg_3f(x))
    end
    v_27_auto = neg_int_3f0
    core["neg-int?"] = v_27_auto
    neg_int_3f = v_27_auto
  end
  local double_3f
  do
    local v_27_auto
    local function double_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "double?"))
        else
        end
      end
      return ((type(x) == "number") and (x ~= math.floor(x)))
    end
    v_27_auto = double_3f0
    core["double?"] = v_27_auto
    double_3f = v_27_auto
  end
  local empty_3f
  do
    local v_27_auto
    local function empty_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "empty?"))
        else
        end
      end
      local case_973_ = type(x)
      if (case_973_ == "table") then
        local case_974_ = getmetatable(x)
        if ((_G.type(case_974_) == "table") and (case_974_["cljlib/type"] == "seq")) then
          return nil_3f(core.seq(x))
        elseif ((case_974_ == nil) or ((_G.type(case_974_) == "table") and (case_974_["cljlib/type"] == nil))) then
          local next_2a = pairs_2a(x)
          return (next_2a(x) == nil)
        else
          return nil
        end
      elseif (case_973_ == "string") then
        return (x == "")
      elseif (case_973_ == "nil") then
        return true
      else
        local _ = case_973_
        return error("empty?: unsupported collection")
      end
    end
    v_27_auto = empty_3f0
    core["empty?"] = v_27_auto
    empty_3f = v_27_auto
  end
  local not_empty
  do
    local v_27_auto
    local function not_empty0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "not-empty"))
        else
        end
      end
      if not empty_3f(x) then
        return x
      else
        return nil
      end
    end
    v_27_auto = not_empty0
    core["not-empty"] = v_27_auto
    not_empty = v_27_auto
  end
  local map_3f
  do
    local v_27_auto
    local function map_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "map?"))
        else
        end
      end
      if ("table" == type(x)) then
        local case_980_ = getmetatable(x)
        if ((_G.type(case_980_) == "table") and (case_980_["cljlib/type"] == "hash-map")) then
          return true
        elseif ((_G.type(case_980_) == "table") and (case_980_["cljlib/type"] == "sorted-map")) then
          return true
        elseif ((case_980_ == nil) or ((_G.type(case_980_) == "table") and (case_980_["cljlib/type"] == nil))) then
          local len = length_2a(x)
          local nxt, t, k = pairs_2a(x)
          local function _981_(...)
            if (len == 0) then
              return k
            else
              return len
            end
          end
          return (nil ~= nxt(t, _981_(...)))
        else
          local _ = case_980_
          return false
        end
      else
        return false
      end
    end
    v_27_auto = map_3f0
    core["map?"] = v_27_auto
    map_3f = v_27_auto
  end
  local vector_3f
  do
    local v_27_auto
    local function vector_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "vector?"))
        else
        end
      end
      if ("table" == type(x)) then
        local case_985_ = getmetatable(x)
        if ((_G.type(case_985_) == "table") and (case_985_["cljlib/type"] == "vector")) then
          return true
        elseif ((case_985_ == nil) or ((_G.type(case_985_) == "table") and (case_985_["cljlib/type"] == nil))) then
          local len = length_2a(x)
          local nxt, t, k = pairs_2a(x)
          local function _986_(...)
            if (len == 0) then
              return k
            else
              return len
            end
          end
          if (nil ~= nxt(t, _986_(...))) then
            return false
          elseif (len > 0) then
            return true
          else
            return false
          end
        else
          local _ = case_985_
          return false
        end
      else
        return false
      end
    end
    v_27_auto = vector_3f0
    core["vector?"] = v_27_auto
    vector_3f = v_27_auto
  end
  local set_3f
  do
    local v_27_auto
    local function set_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "set?"))
        else
        end
      end
      local case_991_ = getmetatable(x)
      if ((_G.type(case_991_) == "table") and (case_991_["cljlib/type"] == "hash-set")) then
        return true
      else
        local _ = case_991_
        return false
      end
    end
    v_27_auto = set_3f0
    core["set?"] = v_27_auto
    set_3f = v_27_auto
  end
  local seq_3f
  do
    local v_27_auto
    local function seq_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "seq?"))
        else
        end
      end
      return lazy["seq?"](x)
    end
    v_27_auto = seq_3f0
    core["seq?"] = v_27_auto
    seq_3f = v_27_auto
  end
  local some_3f
  do
    local v_27_auto
    local function some_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "some?"))
        else
        end
      end
      return (x ~= nil)
    end
    v_27_auto = some_3f0
    core["some?"] = v_27_auto
    some_3f = v_27_auto
  end
  local function vec__3etransient(immutable)
    local function _995_(vec)
      local len = #vec
      local function _996_(_, i)
        if (i <= len) then
          return vec[i]
        else
          return nil
        end
      end
      local function _998_()
        return len
      end
      local function _999_()
        return error("can't `conj` onto transient vector, use `conj!`")
      end
      local function _1000_()
        return error("can't `assoc` onto transient vector, use `assoc!`")
      end
      local function _1001_()
        return error("can't `dissoc` onto transient vector, use `dissoc!`")
      end
      local function _1002_(tvec, v)
        len = (len + 1)
        tvec[len] = v
        return tvec
      end
      local function _1003_(tvec, ...)
        do
          local len0 = #tvec
          for i = 1, select("#", ...), 2 do
            local k, v = select(i, ...)
            if ((1 <= i) and (i <= len0)) then
              tvec[i] = v
            else
              error(("index " .. i .. " is out of bounds"))
            end
          end
        end
        return tvec
      end
      local function _1005_(tvec)
        if (len == 0) then
          return error("transient vector is empty", 2)
        else
          local val = table.remove(tvec)
          len = (len - 1)
          return tvec
        end
      end
      local function _1007_()
        return error("can't `dissoc!` with a transient vector")
      end
      local function _1008_(tvec)
        local v
        do
          local tbl_26_ = {}
          local i_27_ = 0
          for i = 1, len do
            local val_28_ = tvec[i]
            if (nil ~= val_28_) then
              i_27_ = (i_27_ + 1)
              tbl_26_[i_27_] = val_28_
            else
            end
          end
          v = tbl_26_
        end
        while (len > 0) do
          table.remove(tvec)
          len = (len - 1)
        end
        local function _1010_()
          return error("attempt to use transient after it was persistet")
        end
        local function _1011_()
          return error("attempt to use transient after it was persistet")
        end
        setmetatable(tvec, {__index = _1010_, __newindex = _1011_})
        return immutable(itable(v))
      end
      return setmetatable({}, {__index = _996_, __len = _998_, ["cljlib/type"] = "transient", ["cljlib/conj"] = _999_, ["cljlib/assoc"] = _1000_, ["cljlib/dissoc"] = _1001_, ["cljlib/conj!"] = _1002_, ["cljlib/assoc!"] = _1003_, ["cljlib/pop!"] = _1005_, ["cljlib/dissoc!"] = _1007_, ["cljlib/persistent!"] = _1008_})
    end
    return _995_
  end
  local function vec_2a(v, len)
    do
      local case_1012_ = getmetatable(v)
      if (nil ~= case_1012_) then
        local mt = case_1012_
        mt["__len"] = constantly((len or length_2a(v)))
        mt["cljlib/type"] = "vector"
        mt["cljlib/editable"] = true
        local function _1013_(t, v0)
          local len0 = length_2a(t)
          return vec_2a(itable.assoc(t, (len0 + 1), v0), (len0 + 1))
        end
        mt["cljlib/conj"] = _1013_
        local function _1014_(t)
          local len0 = (length_2a(t) - 1)
          local coll = {}
          if (len0 < 0) then
            error("can't pop empty vector", 2)
          else
          end
          for i = 1, len0 do
            coll[i] = t[i]
          end
          return vec_2a(itable(coll), len0)
        end
        mt["cljlib/pop"] = _1014_
        local function _1016_()
          return vec_2a(itable({}))
        end
        mt["cljlib/empty"] = _1016_
        mt["cljlib/transient"] = vec__3etransient(vec_2a)
        local function _1017_(coll, view, inspector, indent)
          if empty_3f(coll) then
            return "[]"
          else
            local lines
            do
              local tbl_26_ = {}
              local i_27_ = 0
              for i = 1, length_2a(coll) do
                local val_28_ = (" " .. view(coll[i], inspector, indent))
                if (nil ~= val_28_) then
                  i_27_ = (i_27_ + 1)
                  tbl_26_[i_27_] = val_28_
                else
                end
              end
              lines = tbl_26_
            end
            lines[1] = ("[" .. string.gsub((lines[1] or ""), "^%s+", ""))
            lines[#lines] = (lines[#lines] .. "]")
            return lines
          end
        end
        mt["__fennelview"] = _1017_
      elseif (case_1012_ == nil) then
        vec_2a(setmetatable(v, {}))
      else
      end
    end
    return v
  end
  local vec
  do
    local v_27_auto
    local function vec0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "vec"))
        else
        end
      end
      if empty_3f(coll) then
        return vec_2a(itable({}), 0)
      elseif vector_3f(coll) then
        return vec_2a(itable(coll), length_2a(coll))
      elseif "else" then
        local packed = lazy.pack(core.seq(coll))
        local len = packed.n
        local _1022_
        do
          packed["n"] = nil
          _1022_ = packed
        end
        return vec_2a(itable(_1022_, {["fast-index?"] = true}), len)
      else
        return nil
      end
    end
    v_27_auto = vec0
    core["vec"] = v_27_auto
    vec = v_27_auto
  end
  local vector
  do
    local v_27_auto
    local function vector0(...)
      local _let_1024_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1024_.list
      local _let_1025_ = list_38_auto(...)
      local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1025_, 1)
      return vec(args)
    end
    v_27_auto = vector0
    core["vector"] = v_27_auto
    vector = v_27_auto
  end
  local nth
  do
    local v_27_auto
    local function nth0(...)
      local case_1027_ = select("#", ...)
      if (case_1027_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "nth"))
      elseif (case_1027_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "nth"))
      elseif (case_1027_ == 2) then
        local coll, i = ...
        if vector_3f(coll) then
          if ((i < 1) or (length_2a(coll) < i)) then
            return error(string.format("index %d is out of bounds", i))
          else
            return coll[i]
          end
        elseif string_3f(coll) then
          return nth0(vec(coll), i)
        elseif seq_3f(coll) then
          return nth0(vec(coll), i)
        elseif "else" then
          return error("expected an indexed collection")
        else
          return nil
        end
      elseif (case_1027_ == 3) then
        local coll, i, not_found = ...
        assert(int_3f(i), "expected an integer key")
        if vector_3f(coll) then
          return (coll[i] or not_found)
        elseif string_3f(coll) then
          return nth0(vec(coll), i, not_found)
        elseif seq_3f(coll) then
          return nth0(vec(coll), i, not_found)
        elseif "else" then
          return error("expected an indexed collection")
        else
          return nil
        end
      else
        local _ = case_1027_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "nth"))
      end
    end
    v_27_auto = nth0
    core["nth"] = v_27_auto
    nth = v_27_auto
  end
  local seq_2a
  local function seq_2a0(...)
    local x = ...
    do
      local cnt_54_auto = select("#", ...)
      if (1 ~= cnt_54_auto) then
        error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "seq*"))
      else
      end
    end
    do
      local case_1033_ = getmetatable(x)
      if (nil ~= case_1033_) then
        local mt = case_1033_
        mt["cljlib/type"] = "seq"
        local function _1034_(s, v)
          return core.cons(v, s)
        end
        mt["cljlib/conj"] = _1034_
        local function _1035_()
          return core.list()
        end
        mt["cljlib/empty"] = _1035_
      else
      end
    end
    return x
  end
  seq_2a = seq_2a0
  local seq
  do
    local v_27_auto
    local function seq0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "seq"))
        else
        end
      end
      local function _1039_(...)
        local case_1038_ = getmetatable(coll)
        if ((_G.type(case_1038_) == "table") and (nil ~= case_1038_["cljlib/seq"])) then
          local f = case_1038_["cljlib/seq"]
          return f(coll)
        else
          local _ = case_1038_
          if lazy["seq?"](coll) then
            return lazy.seq(coll)
          elseif map_3f(coll) then
            return lazy.map(vec, coll)
          elseif "else" then
            return lazy.seq(coll)
          else
            return nil
          end
        end
      end
      return seq_2a(_1039_(...))
    end
    v_27_auto = seq0
    core["seq"] = v_27_auto
    seq = v_27_auto
  end
  local rseq
  do
    local v_27_auto
    local function rseq0(...)
      local rev = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "rseq"))
        else
        end
      end
      return seq_2a(lazy.rseq(rev))
    end
    v_27_auto = rseq0
    core["rseq"] = v_27_auto
    rseq = v_27_auto
  end
  local lazy_seq_2a
  do
    local v_27_auto
    local function lazy_seq_2a0(...)
      local f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "lazy-seq*"))
        else
        end
      end
      return seq_2a(lazy["lazy-seq*"](f))
    end
    v_27_auto = lazy_seq_2a0
    core["lazy-seq*"] = v_27_auto
    lazy_seq_2a = v_27_auto
  end
  local first
  do
    local v_27_auto
    local function first0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "first"))
        else
        end
      end
      return lazy.first(seq(coll))
    end
    v_27_auto = first0
    core["first"] = v_27_auto
    first = v_27_auto
  end
  local rest
  do
    local v_27_auto
    local function rest0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "rest"))
        else
        end
      end
      return seq_2a(lazy.rest(seq(coll)))
    end
    v_27_auto = rest0
    core["rest"] = v_27_auto
    rest = v_27_auto
  end
  local next_2a
  local function next_2a0(...)
    local s = ...
    do
      local cnt_54_auto = select("#", ...)
      if (1 ~= cnt_54_auto) then
        error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "next*"))
      else
      end
    end
    return seq_2a(lazy.next(s))
  end
  next_2a = next_2a0
  do
    core["next"] = next_2a
  end
  local count
  do
    local v_27_auto
    local function count0(...)
      local s = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "count"))
        else
        end
      end
      local case_1048_ = getmetatable(s)
      if ((_G.type(case_1048_) == "table") and (case_1048_["cljlib/type"] == "vector")) then
        return length_2a(s)
      else
        local _ = case_1048_
        return lazy.count(s)
      end
    end
    v_27_auto = count0
    core["count"] = v_27_auto
    count = v_27_auto
  end
  local cons
  do
    local v_27_auto
    local function cons0(...)
      local head, tail = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "cons"))
        else
        end
      end
      return seq_2a(lazy.cons(head, tail))
    end
    v_27_auto = cons0
    core["cons"] = v_27_auto
    cons = v_27_auto
  end
  local function list(...)
    return seq_2a(lazy.list(...))
  end
  core.list = list
  local list_2a
  do
    local v_27_auto
    local function list_2a0(...)
      local _let_1051_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1051_.list
      local _let_1052_ = list_38_auto(...)
      local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1052_, 1)
      return seq_2a(apply(lazy["list*"], args))
    end
    v_27_auto = list_2a0
    core["list*"] = v_27_auto
    list_2a = v_27_auto
  end
  local last
  do
    local v_27_auto
    local function last0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "last"))
        else
        end
      end
      local case_1054_ = next_2a(coll)
      if (nil ~= case_1054_) then
        local coll_2a = case_1054_
        return last0(coll_2a)
      else
        local _ = case_1054_
        return first(coll)
      end
    end
    v_27_auto = last0
    core["last"] = v_27_auto
    last = v_27_auto
  end
  local butlast
  do
    local v_27_auto
    local function butlast0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "butlast"))
        else
        end
      end
      return seq(lazy["drop-last"](coll))
    end
    v_27_auto = butlast0
    core["butlast"] = v_27_auto
    butlast = v_27_auto
  end
  local map
  do
    local v_27_auto
    local function map0(...)
      local case_1057_ = select("#", ...)
      if (case_1057_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "map"))
      elseif (case_1057_ == 1) then
        local f = ...
        local function fn_1058_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1058_"))
            else
            end
          end
          local function fn_1060_(...)
            local case_1061_ = select("#", ...)
            if (case_1061_ == 0) then
              return rf()
            elseif (case_1061_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1061_ == 2) then
              local result, input = ...
              return rf(result, f(input))
            else
              local _ = case_1061_
              local _let_1062_ = require("io.gitlab.andreyorst.cljlib.core")
              local list_38_auto = _let_1062_.list
              local _let_1063_ = list_38_auto(...)
              local result = _let_1063_[1]
              local input = _let_1063_[2]
              local inputs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1063_, 3)
              return rf(result, apply(f, input, inputs))
            end
          end
          return fn_1060_
        end
        return fn_1058_
      elseif (case_1057_ == 2) then
        local f, coll = ...
        return seq_2a(lazy.map(f, coll))
      else
        local _ = case_1057_
        local _let_1065_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1065_.list
        local _let_1066_ = list_38_auto(...)
        local f = _let_1066_[1]
        local coll = _let_1066_[2]
        local colls = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1066_, 3)
        return seq_2a(apply(lazy.map, f, coll, colls))
      end
    end
    v_27_auto = map0
    core["map"] = v_27_auto
    map = v_27_auto
  end
  local mapv
  do
    local v_27_auto
    local function mapv0(...)
      local case_1069_ = select("#", ...)
      if (case_1069_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "mapv"))
      elseif (case_1069_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "mapv"))
      elseif (case_1069_ == 2) then
        local f, coll = ...
        return core["persistent!"](core.transduce(map(f), core["conj!"], core.transient(vector()), coll))
      else
        local _ = case_1069_
        local _let_1070_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1070_.list
        local _let_1071_ = list_38_auto(...)
        local f = _let_1071_[1]
        local coll = _let_1071_[2]
        local colls = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1071_, 3)
        return vec(apply(map, f, coll, colls))
      end
    end
    v_27_auto = mapv0
    core["mapv"] = v_27_auto
    mapv = v_27_auto
  end
  local map_indexed
  do
    local v_27_auto
    local function map_indexed0(...)
      local case_1073_ = select("#", ...)
      if (case_1073_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "map-indexed"))
      elseif (case_1073_ == 1) then
        local f = ...
        local function fn_1074_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1074_"))
            else
            end
          end
          local i = -1
          local function fn_1076_(...)
            local case_1077_ = select("#", ...)
            if (case_1077_ == 0) then
              return rf()
            elseif (case_1077_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1077_ == 2) then
              local result, input = ...
              i = (i + 1)
              return rf(result, f(i, input))
            else
              local _ = case_1077_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1076_"))
            end
          end
          return fn_1076_
        end
        return fn_1074_
      elseif (case_1073_ == 2) then
        local f, coll = ...
        return seq_2a(lazy["map-indexed"](f, coll))
      else
        local _ = case_1073_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "map-indexed"))
      end
    end
    v_27_auto = map_indexed0
    core["map-indexed"] = v_27_auto
    map_indexed = v_27_auto
  end
  local mapcat
  do
    local v_27_auto
    local function mapcat0(...)
      local case_1080_ = select("#", ...)
      if (case_1080_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "mapcat"))
      elseif (case_1080_ == 1) then
        local f = ...
        return comp(map(f), core.cat)
      else
        local _ = case_1080_
        local _let_1081_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1081_.list
        local _let_1082_ = list_38_auto(...)
        local f = _let_1082_[1]
        local colls = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1082_, 2)
        return seq_2a(apply(lazy.mapcat, f, colls))
      end
    end
    v_27_auto = mapcat0
    core["mapcat"] = v_27_auto
    mapcat = v_27_auto
  end
  local filter
  do
    local v_27_auto
    local function filter0(...)
      local case_1084_ = select("#", ...)
      if (case_1084_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "filter"))
      elseif (case_1084_ == 1) then
        local pred = ...
        local function fn_1085_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1085_"))
            else
            end
          end
          local function fn_1087_(...)
            local case_1088_ = select("#", ...)
            if (case_1088_ == 0) then
              return rf()
            elseif (case_1088_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1088_ == 2) then
              local result, input = ...
              if pred(input) then
                return rf(result, input)
              else
                return result
              end
            else
              local _ = case_1088_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1087_"))
            end
          end
          return fn_1087_
        end
        return fn_1085_
      elseif (case_1084_ == 2) then
        local pred, coll = ...
        return seq_2a(lazy.filter(pred, coll))
      else
        local _ = case_1084_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "filter"))
      end
    end
    v_27_auto = filter0
    core["filter"] = v_27_auto
    filter = v_27_auto
  end
  local filterv
  do
    local v_27_auto
    local function filterv0(...)
      local pred, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "filterv"))
        else
        end
      end
      return vec(filter(pred, coll))
    end
    v_27_auto = filterv0
    core["filterv"] = v_27_auto
    filterv = v_27_auto
  end
  local every_3f
  do
    local v_27_auto
    local function every_3f0(...)
      local pred, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "every?"))
        else
        end
      end
      return lazy["every?"](pred, coll)
    end
    v_27_auto = every_3f0
    core["every?"] = v_27_auto
    every_3f = v_27_auto
  end
  local some
  do
    local v_27_auto
    local function some0(...)
      local pred, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "some"))
        else
        end
      end
      return lazy["some?"](pred, coll)
    end
    v_27_auto = some0
    core["some"] = v_27_auto
    some = v_27_auto
  end
  local not_any_3f
  do
    local v_27_auto
    local function not_any_3f0(...)
      local pred, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "not-any?"))
        else
        end
      end
      local function _1096_(_241)
        return not pred(_241)
      end
      return some(_1096_, coll)
    end
    v_27_auto = not_any_3f0
    core["not-any?"] = v_27_auto
    not_any_3f = v_27_auto
  end
  local range
  do
    local v_27_auto
    local function range0(...)
      local case_1097_ = select("#", ...)
      if (case_1097_ == 0) then
        return seq_2a(lazy.range())
      elseif (case_1097_ == 1) then
        local upper = ...
        return seq_2a(lazy.range(upper))
      elseif (case_1097_ == 2) then
        local lower, upper = ...
        return seq_2a(lazy.range(lower, upper))
      elseif (case_1097_ == 3) then
        local lower, upper, step = ...
        return seq_2a(lazy.range(lower, upper, step))
      else
        local _ = case_1097_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "range"))
      end
    end
    v_27_auto = range0
    core["range"] = v_27_auto
    range = v_27_auto
  end
  local concat
  do
    local v_27_auto
    local function concat0(...)
      local _let_1099_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1099_.list
      local _let_1100_ = list_38_auto(...)
      local colls = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1100_, 1)
      return seq_2a(apply(lazy.concat, colls))
    end
    v_27_auto = concat0
    core["concat"] = v_27_auto
    concat = v_27_auto
  end
  local reverse
  do
    local v_27_auto
    local function reverse0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "reverse"))
        else
        end
      end
      return seq_2a(lazy.reverse(coll))
    end
    v_27_auto = reverse0
    core["reverse"] = v_27_auto
    reverse = v_27_auto
  end
  local take
  do
    local v_27_auto
    local function take0(...)
      local case_1102_ = select("#", ...)
      if (case_1102_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "take"))
      elseif (case_1102_ == 1) then
        local n = ...
        local function fn_1103_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1103_"))
            else
            end
          end
          local n0 = n
          local function fn_1105_(...)
            local case_1106_ = select("#", ...)
            if (case_1106_ == 0) then
              return rf()
            elseif (case_1106_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1106_ == 2) then
              local result, input = ...
              local result0
              if (0 < n0) then
                result0 = rf(result, input)
              else
                result0 = result
              end
              n0 = (n0 - 1)
              if not (0 < n0) then
                return core["ensure-reduced"](result0)
              else
                return result0
              end
            else
              local _ = case_1106_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1105_"))
            end
          end
          return fn_1105_
        end
        return fn_1103_
      elseif (case_1102_ == 2) then
        local n, coll = ...
        return seq_2a(lazy.take(n, coll))
      else
        local _ = case_1102_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "take"))
      end
    end
    v_27_auto = take0
    core["take"] = v_27_auto
    take = v_27_auto
  end
  local take_while
  do
    local v_27_auto
    local function take_while0(...)
      local case_1111_ = select("#", ...)
      if (case_1111_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "take-while"))
      elseif (case_1111_ == 1) then
        local pred = ...
        local function fn_1112_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1112_"))
            else
            end
          end
          local function fn_1114_(...)
            local case_1115_ = select("#", ...)
            if (case_1115_ == 0) then
              return rf()
            elseif (case_1115_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1115_ == 2) then
              local result, input = ...
              if pred(input) then
                return rf(result, input)
              else
                return core.reduced(result)
              end
            else
              local _ = case_1115_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1114_"))
            end
          end
          return fn_1114_
        end
        return fn_1112_
      elseif (case_1111_ == 2) then
        local pred, coll = ...
        return seq_2a(lazy["take-while"](pred, coll))
      else
        local _ = case_1111_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "take-while"))
      end
    end
    v_27_auto = take_while0
    core["take-while"] = v_27_auto
    take_while = v_27_auto
  end
  local drop
  do
    local v_27_auto
    local function drop0(...)
      local case_1119_ = select("#", ...)
      if (case_1119_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "drop"))
      elseif (case_1119_ == 1) then
        local n = ...
        local function fn_1120_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1120_"))
            else
            end
          end
          local nv = n
          local function fn_1122_(...)
            local case_1123_ = select("#", ...)
            if (case_1123_ == 0) then
              return rf()
            elseif (case_1123_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1123_ == 2) then
              local result, input = ...
              local n0 = nv
              nv = (nv - 1)
              if pos_3f(n0) then
                return result
              else
                return rf(result, input)
              end
            else
              local _ = case_1123_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1122_"))
            end
          end
          return fn_1122_
        end
        return fn_1120_
      elseif (case_1119_ == 2) then
        local n, coll = ...
        return seq_2a(lazy.drop(n, coll))
      else
        local _ = case_1119_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "drop"))
      end
    end
    v_27_auto = drop0
    core["drop"] = v_27_auto
    drop = v_27_auto
  end
  local drop_while
  do
    local v_27_auto
    local function drop_while0(...)
      local case_1127_ = select("#", ...)
      if (case_1127_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "drop-while"))
      elseif (case_1127_ == 1) then
        local pred = ...
        local function fn_1128_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1128_"))
            else
            end
          end
          local dv = true
          local function fn_1130_(...)
            local case_1131_ = select("#", ...)
            if (case_1131_ == 0) then
              return rf()
            elseif (case_1131_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1131_ == 2) then
              local result, input = ...
              local drop_3f = dv
              if (drop_3f and pred(input)) then
                return result
              else
                dv = nil
                return rf(result, input)
              end
            else
              local _ = case_1131_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1130_"))
            end
          end
          return fn_1130_
        end
        return fn_1128_
      elseif (case_1127_ == 2) then
        local pred, coll = ...
        return seq_2a(lazy["drop-while"](pred, coll))
      else
        local _ = case_1127_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "drop-while"))
      end
    end
    v_27_auto = drop_while0
    core["drop-while"] = v_27_auto
    drop_while = v_27_auto
  end
  local drop_last
  do
    local v_27_auto
    local function drop_last0(...)
      local case_1135_ = select("#", ...)
      if (case_1135_ == 0) then
        return seq_2a(lazy["drop-last"]())
      elseif (case_1135_ == 1) then
        local coll = ...
        return seq_2a(lazy["drop-last"](coll))
      elseif (case_1135_ == 2) then
        local n, coll = ...
        return seq_2a(lazy["drop-last"](n, coll))
      else
        local _ = case_1135_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "drop-last"))
      end
    end
    v_27_auto = drop_last0
    core["drop-last"] = v_27_auto
    drop_last = v_27_auto
  end
  local take_last
  do
    local v_27_auto
    local function take_last0(...)
      local n, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "take-last"))
        else
        end
      end
      return seq_2a(lazy["take-last"](n, coll))
    end
    v_27_auto = take_last0
    core["take-last"] = v_27_auto
    take_last = v_27_auto
  end
  local take_nth
  do
    local v_27_auto
    local function take_nth0(...)
      local case_1138_ = select("#", ...)
      if (case_1138_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "take-nth"))
      elseif (case_1138_ == 1) then
        local n = ...
        local function fn_1139_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1139_"))
            else
            end
          end
          local iv = -1
          local function fn_1141_(...)
            local case_1142_ = select("#", ...)
            if (case_1142_ == 0) then
              return rf()
            elseif (case_1142_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1142_ == 2) then
              local result, input = ...
              iv = (iv + 1)
              if (0 == (iv % n)) then
                return rf(result, input)
              else
                return result
              end
            else
              local _ = case_1142_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1141_"))
            end
          end
          return fn_1141_
        end
        return fn_1139_
      elseif (case_1138_ == 2) then
        local n, coll = ...
        return seq_2a(lazy["take-nth"](n, coll))
      else
        local _ = case_1138_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "take-nth"))
      end
    end
    v_27_auto = take_nth0
    core["take-nth"] = v_27_auto
    take_nth = v_27_auto
  end
  local split_at
  do
    local v_27_auto
    local function split_at0(...)
      local n, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "split-at"))
        else
        end
      end
      return vec(lazy["split-at"](n, coll))
    end
    v_27_auto = split_at0
    core["split-at"] = v_27_auto
    split_at = v_27_auto
  end
  local split_with
  do
    local v_27_auto
    local function split_with0(...)
      local pred, coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "split-with"))
        else
        end
      end
      return vec(lazy["split-with"](pred, coll))
    end
    v_27_auto = split_with0
    core["split-with"] = v_27_auto
    split_with = v_27_auto
  end
  local nthrest
  do
    local v_27_auto
    local function nthrest0(...)
      local coll, n = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "nthrest"))
        else
        end
      end
      return seq_2a(lazy.nthrest(coll, n))
    end
    v_27_auto = nthrest0
    core["nthrest"] = v_27_auto
    nthrest = v_27_auto
  end
  local nthnext
  do
    local v_27_auto
    local function nthnext0(...)
      local coll, n = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "nthnext"))
        else
        end
      end
      return lazy.nthnext(coll, n)
    end
    v_27_auto = nthnext0
    core["nthnext"] = v_27_auto
    nthnext = v_27_auto
  end
  local keep
  do
    local v_27_auto
    local function keep0(...)
      local case_1150_ = select("#", ...)
      if (case_1150_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "keep"))
      elseif (case_1150_ == 1) then
        local f = ...
        local function fn_1151_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1151_"))
            else
            end
          end
          local function fn_1153_(...)
            local case_1154_ = select("#", ...)
            if (case_1154_ == 0) then
              return rf()
            elseif (case_1154_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1154_ == 2) then
              local result, input = ...
              local v = f(input)
              if nil_3f(v) then
                return result
              else
                return rf(result, v)
              end
            else
              local _ = case_1154_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1153_"))
            end
          end
          return fn_1153_
        end
        return fn_1151_
      elseif (case_1150_ == 2) then
        local f, coll = ...
        return seq_2a(lazy.keep(f, coll))
      else
        local _ = case_1150_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "keep"))
      end
    end
    v_27_auto = keep0
    core["keep"] = v_27_auto
    keep = v_27_auto
  end
  local keep_indexed
  do
    local v_27_auto
    local function keep_indexed0(...)
      local case_1158_ = select("#", ...)
      if (case_1158_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "keep-indexed"))
      elseif (case_1158_ == 1) then
        local f = ...
        local function fn_1159_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1159_"))
            else
            end
          end
          local iv = -1
          local function fn_1161_(...)
            local case_1162_ = select("#", ...)
            if (case_1162_ == 0) then
              return rf()
            elseif (case_1162_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1162_ == 2) then
              local result, input = ...
              iv = (iv + 1)
              local v = f(iv, input)
              if nil_3f(v) then
                return result
              else
                return rf(result, v)
              end
            else
              local _ = case_1162_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1161_"))
            end
          end
          return fn_1161_
        end
        return fn_1159_
      elseif (case_1158_ == 2) then
        local f, coll = ...
        return seq_2a(lazy["keep-indexed"](f, coll))
      else
        local _ = case_1158_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "keep-indexed"))
      end
    end
    v_27_auto = keep_indexed0
    core["keep-indexed"] = v_27_auto
    keep_indexed = v_27_auto
  end
  local partition
  do
    local v_27_auto
    local function partition0(...)
      local case_1167_ = select("#", ...)
      if (case_1167_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "partition"))
      elseif (case_1167_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "partition"))
      elseif (case_1167_ == 2) then
        local n, coll = ...
        return map(seq_2a, lazy.partition(n, coll))
      elseif (case_1167_ == 3) then
        local n, step, coll = ...
        return map(seq_2a, lazy.partition(n, step, coll))
      elseif (case_1167_ == 4) then
        local n, step, pad, coll = ...
        return map(seq_2a, lazy.partition(n, step, pad, coll))
      else
        local _ = case_1167_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "partition"))
      end
    end
    v_27_auto = partition0
    core["partition"] = v_27_auto
    partition = v_27_auto
  end
  local function array()
    local len = 0
    local function _1169_()
      return len
    end
    local function _1170_(self)
      while (0 ~= len) do
        self[len] = nil
        len = (len - 1)
      end
      return nil
    end
    local function _1171_(self, val)
      len = (len + 1)
      self[len] = val
      return self
    end
    return setmetatable({}, {__len = _1169_, __index = {clear = _1170_, add = _1171_}})
  end
  local partition_by
  do
    local v_27_auto
    local function partition_by0(...)
      local case_1172_ = select("#", ...)
      if (case_1172_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "partition-by"))
      elseif (case_1172_ == 1) then
        local f = ...
        local function fn_1173_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1173_"))
            else
            end
          end
          local a0 = array()
          local none = {}
          local pv = none
          local function fn_1175_(...)
            local case_1176_ = select("#", ...)
            if (case_1176_ == 0) then
              return rf()
            elseif (case_1176_ == 1) then
              local result = ...
              local function _1177_(...)
                if empty_3f(a0) then
                  return result
                else
                  local v = vec(a0)
                  a0:clear()
                  return core.unreduced(rf(result, v))
                end
              end
              return rf(_1177_(...))
            elseif (case_1176_ == 2) then
              local result, input = ...
              local pval = pv
              local val = f(input)
              pv = val
              if ((pval == none) or (val == pval)) then
                a0:add(input)
                return result
              else
                local v = vec(a0)
                a0:clear()
                local ret = rf(result, v)
                if not core["reduced?"](ret) then
                  a0:add(input)
                else
                end
                return ret
              end
            else
              local _ = case_1176_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1175_"))
            end
          end
          return fn_1175_
        end
        return fn_1173_
      elseif (case_1172_ == 2) then
        local f, coll = ...
        return map(seq_2a, lazy["partition-by"](f, coll))
      else
        local _ = case_1172_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "partition-by"))
      end
    end
    v_27_auto = partition_by0
    core["partition-by"] = v_27_auto
    partition_by = v_27_auto
  end
  local partition_all
  do
    local v_27_auto
    local function partition_all0(...)
      local case_1182_ = select("#", ...)
      if (case_1182_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "partition-all"))
      elseif (case_1182_ == 1) then
        local n = ...
        local function fn_1183_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1183_"))
            else
            end
          end
          local a0 = array()
          local function fn_1185_(...)
            local case_1186_ = select("#", ...)
            if (case_1186_ == 0) then
              return rf()
            elseif (case_1186_ == 1) then
              local result = ...
              local function _1187_(...)
                if (0 == #a0) then
                  return result
                else
                  local v = vec(a0)
                  a0:clear()
                  return core.unreduced(rf(result, v))
                end
              end
              return rf(_1187_(...))
            elseif (case_1186_ == 2) then
              local result, input = ...
              a0:add(input)
              if (n == #a0) then
                local v = vec(a0)
                a0:clear()
                return rf(result, v)
              else
                return result
              end
            else
              local _ = case_1186_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1185_"))
            end
          end
          return fn_1185_
        end
        return fn_1183_
      elseif (case_1182_ == 2) then
        local n, coll = ...
        return map(seq_2a, lazy["partition-all"](n, coll))
      elseif (case_1182_ == 3) then
        local n, step, coll = ...
        return map(seq_2a, lazy["partition-all"](n, step, coll))
      else
        local _ = case_1182_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "partition-all"))
      end
    end
    v_27_auto = partition_all0
    core["partition-all"] = v_27_auto
    partition_all = v_27_auto
  end
  local reductions
  do
    local v_27_auto
    local function reductions0(...)
      local case_1192_ = select("#", ...)
      if (case_1192_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "reductions"))
      elseif (case_1192_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "reductions"))
      elseif (case_1192_ == 2) then
        local f, coll = ...
        return seq_2a(lazy.reductions(f, coll))
      elseif (case_1192_ == 3) then
        local f, init, coll = ...
        return seq_2a(lazy.reductions(f, init, coll))
      else
        local _ = case_1192_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "reductions"))
      end
    end
    v_27_auto = reductions0
    core["reductions"] = v_27_auto
    reductions = v_27_auto
  end
  local contains_3f
  do
    local v_27_auto
    local function contains_3f0(...)
      local coll, elt = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "contains?"))
        else
        end
      end
      return lazy["contains?"](coll, elt)
    end
    v_27_auto = contains_3f0
    core["contains?"] = v_27_auto
    contains_3f = v_27_auto
  end
  local distinct
  do
    local v_27_auto
    local function distinct0(...)
      local case_1195_ = select("#", ...)
      if (case_1195_ == 0) then
        local function fn_1196_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1196_"))
            else
            end
          end
          local seen = setmetatable({}, {__index = deep_index})
          local function fn_1198_(...)
            local case_1199_ = select("#", ...)
            if (case_1199_ == 0) then
              return rf()
            elseif (case_1199_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1199_ == 2) then
              local result, input = ...
              if seen[input] then
                return result
              else
                seen[input] = true
                return rf(result, input)
              end
            else
              local _ = case_1199_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1198_"))
            end
          end
          return fn_1198_
        end
        return fn_1196_
      elseif (case_1195_ == 1) then
        local coll = ...
        return seq_2a(lazy.distinct(coll))
      else
        local _ = case_1195_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "distinct"))
      end
    end
    v_27_auto = distinct0
    core["distinct"] = v_27_auto
    distinct = v_27_auto
  end
  local dedupe
  do
    local v_27_auto
    local function dedupe0(...)
      local case_1203_ = select("#", ...)
      if (case_1203_ == 0) then
        local function fn_1204_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1204_"))
            else
            end
          end
          local none = {}
          local pv = none
          local function fn_1206_(...)
            local case_1207_ = select("#", ...)
            if (case_1207_ == 0) then
              return rf()
            elseif (case_1207_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1207_ == 2) then
              local result, input = ...
              local prior = pv
              pv = input
              if (prior == input) then
                return result
              else
                return rf(result, input)
              end
            else
              local _ = case_1207_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1206_"))
            end
          end
          return fn_1206_
        end
        return fn_1204_
      elseif (case_1203_ == 1) then
        local coll = ...
        return core.sequence(dedupe0(), coll)
      else
        local _ = case_1203_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "dedupe"))
      end
    end
    v_27_auto = dedupe0
    core["dedupe"] = v_27_auto
    dedupe = v_27_auto
  end
  local random_sample
  do
    local v_27_auto
    local function random_sample0(...)
      local case_1211_ = select("#", ...)
      if (case_1211_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "random-sample"))
      elseif (case_1211_ == 1) then
        local prob = ...
        local function _1212_()
          return (math.random() < prob)
        end
        return filter(_1212_)
      elseif (case_1211_ == 2) then
        local prob, coll = ...
        local function _1213_()
          return (math.random() < prob)
        end
        return filter(_1213_, coll)
      else
        local _ = case_1211_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "random-sample"))
      end
    end
    v_27_auto = random_sample0
    core["random-sample"] = v_27_auto
    random_sample = v_27_auto
  end
  local doall
  do
    local v_27_auto
    local function doall0(...)
      local seq0 = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "doall"))
        else
        end
      end
      return seq_2a(lazy.doall(seq0))
    end
    v_27_auto = doall0
    core["doall"] = v_27_auto
    doall = v_27_auto
  end
  local dorun
  do
    local v_27_auto
    local function dorun0(...)
      local seq0 = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "dorun"))
        else
        end
      end
      return lazy.dorun(seq0)
    end
    v_27_auto = dorun0
    core["dorun"] = v_27_auto
    dorun = v_27_auto
  end
  local line_seq
  do
    local v_27_auto
    local function line_seq0(...)
      local file = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "line-seq"))
        else
        end
      end
      return seq_2a(lazy["line-seq"](file))
    end
    v_27_auto = line_seq0
    core["line-seq"] = v_27_auto
    line_seq = v_27_auto
  end
  local iterate
  do
    local v_27_auto
    local function iterate0(...)
      local f, x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "iterate"))
        else
        end
      end
      return seq_2a(lazy.iterate(f, x))
    end
    v_27_auto = iterate0
    core["iterate"] = v_27_auto
    iterate = v_27_auto
  end
  local remove
  do
    local v_27_auto
    local function remove0(...)
      local case_1219_ = select("#", ...)
      if (case_1219_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "remove"))
      elseif (case_1219_ == 1) then
        local pred = ...
        return filter(complement(pred))
      elseif (case_1219_ == 2) then
        local pred, coll = ...
        return seq_2a(lazy.remove(pred, coll))
      else
        local _ = case_1219_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "remove"))
      end
    end
    v_27_auto = remove0
    core["remove"] = v_27_auto
    remove = v_27_auto
  end
  local cycle
  do
    local v_27_auto
    local function cycle0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "cycle"))
        else
        end
      end
      return seq_2a(lazy.cycle(coll))
    end
    v_27_auto = cycle0
    core["cycle"] = v_27_auto
    cycle = v_27_auto
  end
  local _repeat
  do
    local v_27_auto
    local function _repeat0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "repeat"))
        else
        end
      end
      return seq_2a(lazy["repeat"](x))
    end
    v_27_auto = _repeat0
    core["repeat"] = v_27_auto
    _repeat = v_27_auto
  end
  local repeatedly
  do
    local v_27_auto
    local function repeatedly0(...)
      local _let_1223_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1223_.list
      local _let_1224_ = list_38_auto(...)
      local f = _let_1224_[1]
      local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1224_, 2)
      return seq_2a(apply(lazy.repeatedly, f, args))
    end
    v_27_auto = repeatedly0
    core["repeatedly"] = v_27_auto
    repeatedly = v_27_auto
  end
  local tree_seq
  do
    local v_27_auto
    local function tree_seq0(...)
      local branch_3f, children, root = ...
      do
        local cnt_54_auto = select("#", ...)
        if (3 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "tree-seq"))
        else
        end
      end
      return seq_2a(lazy["tree-seq"](branch_3f, children, root))
    end
    v_27_auto = tree_seq0
    core["tree-seq"] = v_27_auto
    tree_seq = v_27_auto
  end
  local interleave
  do
    local v_27_auto
    local function interleave0(...)
      local case_1226_ = select("#", ...)
      if (case_1226_ == 0) then
        return seq_2a(lazy.interleave())
      elseif (case_1226_ == 1) then
        local s = ...
        return seq_2a(lazy.interleave(s))
      elseif (case_1226_ == 2) then
        local s1, s2 = ...
        return seq_2a(lazy.interleave(s1, s2))
      else
        local _ = case_1226_
        local _let_1227_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1227_.list
        local _let_1228_ = list_38_auto(...)
        local s1 = _let_1228_[1]
        local s2 = _let_1228_[2]
        local ss = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1228_, 3)
        return seq_2a(apply(lazy.interleave, s1, s2, ss))
      end
    end
    v_27_auto = interleave0
    core["interleave"] = v_27_auto
    interleave = v_27_auto
  end
  local interpose
  do
    local v_27_auto
    local function interpose0(...)
      local case_1230_ = select("#", ...)
      if (case_1230_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "interpose"))
      elseif (case_1230_ == 1) then
        local sep = ...
        local function fn_1231_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1231_"))
            else
            end
          end
          local started = false
          local function fn_1233_(...)
            local case_1234_ = select("#", ...)
            if (case_1234_ == 0) then
              return rf()
            elseif (case_1234_ == 1) then
              local result = ...
              return rf(result)
            elseif (case_1234_ == 2) then
              local result, input = ...
              if started then
                local sepr = rf(result, sep)
                if core["reduced?"](sepr) then
                  return sepr
                else
                  return rf(sepr, input)
                end
              else
                started = true
                return rf(result, input)
              end
            else
              local _ = case_1234_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1233_"))
            end
          end
          return fn_1233_
        end
        return fn_1231_
      elseif (case_1230_ == 2) then
        local separator, coll = ...
        return seq_2a(lazy.interpose(separator, coll))
      else
        local _ = case_1230_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "interpose"))
      end
    end
    v_27_auto = interpose0
    core["interpose"] = v_27_auto
    interpose = v_27_auto
  end
  local halt_when
  do
    local v_27_auto
    local function halt_when0(...)
      local case_1239_ = select("#", ...)
      if (case_1239_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "halt-when"))
      elseif (case_1239_ == 1) then
        local pred = ...
        return halt_when0(pred, nil)
      elseif (case_1239_ == 2) then
        local pred, retf = ...
        local function fn_1240_(...)
          local rf = ...
          do
            local cnt_54_auto = select("#", ...)
            if (1 ~= cnt_54_auto) then
              error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1240_"))
            else
            end
          end
          local halt
          local function _1242_()
            return "#<halt>"
          end
          halt = setmetatable({}, {__fennelview = _1242_})
          local function fn_1243_(...)
            local case_1244_ = select("#", ...)
            if (case_1244_ == 0) then
              return rf()
            elseif (case_1244_ == 1) then
              local result = ...
              if (map_3f(result) and contains_3f(result, halt)) then
                return result.value
              else
                return rf(result)
              end
            elseif (case_1244_ == 2) then
              local result, input = ...
              if pred(input) then
                local _1246_
                if retf then
                  _1246_ = retf(rf(result), input)
                else
                  _1246_ = input
                end
                return core.reduced({[halt] = true, value = _1246_})
              else
                return rf(result, input)
              end
            else
              local _ = case_1244_
              return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1243_"))
            end
          end
          return fn_1243_
        end
        return fn_1240_
      else
        local _ = case_1239_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "halt-when"))
      end
    end
    v_27_auto = halt_when0
    core["halt-when"] = v_27_auto
    halt_when = v_27_auto
  end
  local realized_3f
  do
    local v_27_auto
    local function realized_3f0(...)
      local s = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "realized?"))
        else
        end
      end
      return lazy["realized?"](s)
    end
    v_27_auto = realized_3f0
    core["realized?"] = v_27_auto
    realized_3f = v_27_auto
  end
  local keys
  do
    local v_27_auto
    local function keys0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "keys"))
        else
        end
      end
      assert((map_3f(coll) or empty_3f(coll)), "expected a map")
      if empty_3f(coll) then
        return lazy.list()
      else
        return lazy.keys(coll)
      end
    end
    v_27_auto = keys0
    core["keys"] = v_27_auto
    keys = v_27_auto
  end
  local vals
  do
    local v_27_auto
    local function vals0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "vals"))
        else
        end
      end
      assert((map_3f(coll) or empty_3f(coll)), "expected a map")
      if empty_3f(coll) then
        return lazy.list()
      else
        return lazy.vals(coll)
      end
    end
    v_27_auto = vals0
    core["vals"] = v_27_auto
    vals = v_27_auto
  end
  local find
  do
    local v_27_auto
    local function find0(...)
      local coll, key = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "find"))
        else
        end
      end
      assert((map_3f(coll) or empty_3f(coll)), "expected a map")
      local case_1257_ = coll[key]
      if (nil ~= case_1257_) then
        local v = case_1257_
        return {key, v}
      else
        return nil
      end
    end
    v_27_auto = find0
    core["find"] = v_27_auto
    find = v_27_auto
  end
  local sort
  do
    local v_27_auto
    local function sort0(...)
      local case_1259_ = select("#", ...)
      if (case_1259_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "sort"))
      elseif (case_1259_ == 1) then
        local coll = ...
        local case_1260_ = seq(coll)
        if (nil ~= case_1260_) then
          local s = case_1260_
          return seq(itable.sort(vec(s)))
        else
          local _ = case_1260_
          return list()
        end
      elseif (case_1259_ == 2) then
        local comparator, coll = ...
        local case_1262_ = seq(coll)
        if (nil ~= case_1262_) then
          local s = case_1262_
          return seq(itable.sort(vec(s), comparator))
        else
          local _ = case_1262_
          return list()
        end
      else
        local _ = case_1259_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "sort"))
      end
    end
    v_27_auto = sort0
    core["sort"] = v_27_auto
    sort = v_27_auto
  end
  local reduce
  do
    local v_27_auto
    local function reduce0(...)
      local case_1266_ = select("#", ...)
      if (case_1266_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "reduce"))
      elseif (case_1266_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "reduce"))
      elseif (case_1266_ == 2) then
        local f, coll = ...
        return lazy.reduce(f, seq(coll))
      elseif (case_1266_ == 3) then
        local f, val, coll = ...
        return lazy.reduce(f, val, seq(coll))
      else
        local _ = case_1266_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "reduce"))
      end
    end
    v_27_auto = reduce0
    core["reduce"] = v_27_auto
    reduce = v_27_auto
  end
  local reduced
  do
    local v_27_auto
    local function reduced0(...)
      local value = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "reduced"))
        else
        end
      end
      local tmp_9_ = rdc.reduced(value)
      local function _1269_(_241)
        return _241:unbox()
      end
      getmetatable(tmp_9_)["cljlib/deref"] = _1269_
      return tmp_9_
    end
    v_27_auto = reduced0
    core["reduced"] = v_27_auto
    reduced = v_27_auto
  end
  local reduced_3f
  do
    local v_27_auto
    local function reduced_3f0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "reduced?"))
        else
        end
      end
      return rdc["reduced?"](x)
    end
    v_27_auto = reduced_3f0
    core["reduced?"] = v_27_auto
    reduced_3f = v_27_auto
  end
  local unreduced
  do
    local v_27_auto
    local function unreduced0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "unreduced"))
        else
        end
      end
      if reduced_3f(x) then
        return deref(x)
      else
        return x
      end
    end
    v_27_auto = unreduced0
    core["unreduced"] = v_27_auto
    unreduced = v_27_auto
  end
  local ensure_reduced
  do
    local v_27_auto
    local function ensure_reduced0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "ensure-reduced"))
        else
        end
      end
      if reduced_3f(x) then
        return x
      else
        return reduced(x)
      end
    end
    v_27_auto = ensure_reduced0
    core["ensure-reduced"] = v_27_auto
    ensure_reduced = v_27_auto
  end
  local preserving_reduced
  local function preserving_reduced0(...)
    local rf = ...
    do
      local cnt_54_auto = select("#", ...)
      if (1 ~= cnt_54_auto) then
        error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "preserving-reduced"))
      else
      end
    end
    local function fn_1276_(...)
      local a0, b = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1276_"))
        else
        end
      end
      local ret = rf(a0, b)
      if reduced_3f(ret) then
        return reduced(ret)
      else
        return ret
      end
    end
    return fn_1276_
  end
  preserving_reduced = preserving_reduced0
  local cat
  do
    local v_27_auto
    local function cat0(...)
      local rf = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "cat"))
        else
        end
      end
      local rrf = preserving_reduced(rf)
      local function fn_1280_(...)
        local case_1281_ = select("#", ...)
        if (case_1281_ == 0) then
          return rf()
        elseif (case_1281_ == 1) then
          local result = ...
          return rf(result)
        elseif (case_1281_ == 2) then
          local result, input = ...
          return reduce(rrf, result, input)
        else
          local _ = case_1281_
          return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1280_"))
        end
      end
      return fn_1280_
    end
    v_27_auto = cat0
    core["cat"] = v_27_auto
    cat = v_27_auto
  end
  local reduce_kv
  do
    local v_27_auto
    local function reduce_kv0(...)
      local f, val, s = ...
      do
        local cnt_54_auto = select("#", ...)
        if (3 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "reduce-kv"))
        else
        end
      end
      if map_3f(s) then
        local function _1285_(res, _1284_)
          local k = _1284_[1]
          local v = _1284_[2]
          return f(res, k, v)
        end
        return reduce(_1285_, val, seq(s))
      else
        local function _1287_(res, _1286_)
          local k = _1286_[1]
          local v = _1286_[2]
          return f(res, k, v)
        end
        return reduce(_1287_, val, map(vector, drop(1, range()), seq(s)))
      end
    end
    v_27_auto = reduce_kv0
    core["reduce-kv"] = v_27_auto
    reduce_kv = v_27_auto
  end
  local completing
  do
    local v_27_auto
    local function completing0(...)
      local case_1289_ = select("#", ...)
      if (case_1289_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "completing"))
      elseif (case_1289_ == 1) then
        local f = ...
        return completing0(f, identity)
      elseif (case_1289_ == 2) then
        local f, cf = ...
        local function fn_1290_(...)
          local case_1291_ = select("#", ...)
          if (case_1291_ == 0) then
            return f()
          elseif (case_1291_ == 1) then
            local x = ...
            return cf(x)
          elseif (case_1291_ == 2) then
            local x, y = ...
            return f(x, y)
          else
            local _ = case_1291_
            return error(("Wrong number of args (%s) passed to %s"):format(_, "fn_1290_"))
          end
        end
        return fn_1290_
      else
        local _ = case_1289_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "completing"))
      end
    end
    v_27_auto = completing0
    core["completing"] = v_27_auto
    completing = v_27_auto
  end
  local transduce
  do
    local v_27_auto
    local function transduce0(...)
      local case_1297_ = select("#", ...)
      if (case_1297_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "transduce"))
      elseif (case_1297_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "transduce"))
      elseif (case_1297_ == 2) then
        return error(("Wrong number of args (%s) passed to %s"):format(2, "transduce"))
      elseif (case_1297_ == 3) then
        local xform, f, coll = ...
        return transduce0(xform, f, f(), coll)
      elseif (case_1297_ == 4) then
        local xform, f, init, coll = ...
        local f0 = xform(f)
        return f0(reduce(f0, init, seq(coll)))
      else
        local _ = case_1297_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "transduce"))
      end
    end
    v_27_auto = transduce0
    core["transduce"] = v_27_auto
    transduce = v_27_auto
  end
  local sequence
  do
    local v_27_auto
    local function sequence0(...)
      local case_1299_ = select("#", ...)
      if (case_1299_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "sequence"))
      elseif (case_1299_ == 1) then
        local coll = ...
        if seq_3f(coll) then
          return coll
        else
          return (seq(coll) or list())
        end
      elseif (case_1299_ == 2) then
        local xform, coll = ...
        local f
        local function _1301_(_241, _242)
          return cons(_242, _241)
        end
        f = xform(completing(_1301_))
        local function step(coll0)
          local val_101_auto = seq(coll0)
          if (nil ~= val_101_auto) then
            local s = val_101_auto
            local res = f(nil, first(s))
            if reduced_3f(res) then
              return f(deref(res))
            elseif seq_3f(res) then
              local function _1302_()
                return step(rest(s))
              end
              return concat(res, lazy_seq_2a(_1302_))
            elseif "else" then
              return step(rest(s))
            else
              return nil
            end
          else
            return f(nil)
          end
        end
        return (step(coll) or list())
      else
        local _ = case_1299_
        local _let_1305_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1305_.list
        local _let_1306_ = list_38_auto(...)
        local xform = _let_1306_[1]
        local coll = _let_1306_[2]
        local colls = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1306_, 3)
        local f
        local function _1307_(_241, _242)
          return cons(_242, _241)
        end
        f = xform(completing(_1307_))
        local function step(colls0)
          if every_3f(seq, colls0) then
            local res = apply(f, nil, map(first, colls0))
            if reduced_3f(res) then
              return f(deref(res))
            elseif seq_3f(res) then
              local function _1308_()
                return step(map(rest, colls0))
              end
              return concat(res, lazy_seq_2a(_1308_))
            elseif "else" then
              return step(map(rest, colls0))
            else
              return nil
            end
          else
            return f(nil)
          end
        end
        return (step(cons(coll, colls)) or list())
      end
    end
    v_27_auto = sequence0
    core["sequence"] = v_27_auto
    sequence = v_27_auto
  end
  local function map__3etransient(immutable)
    local function _1312_(map0)
      local removed = setmetatable({}, {__index = deep_index})
      local function _1313_(_, k)
        if not removed[k] then
          return map0[k]
        else
          return nil
        end
      end
      local function _1315_()
        return error("can't `conj` onto transient map, use `conj!`")
      end
      local function _1316_()
        return error("can't `assoc` onto transient map, use `assoc!`")
      end
      local function _1317_()
        return error("can't `dissoc` onto transient map, use `dissoc!`")
      end
      local function _1319_(tmap, _1318_)
        local k = _1318_[1]
        local v = _1318_[2]
        if (nil == v) then
          removed[k] = true
        else
          removed[k] = nil
        end
        tmap[k] = v
        return tmap
      end
      local function _1321_(tmap, ...)
        for i = 1, select("#", ...), 2 do
          local k, v = select(i, ...)
          tmap[k] = v
          if (nil == v) then
            removed[k] = true
          else
            removed[k] = nil
          end
        end
        return tmap
      end
      local function _1323_(tmap, ...)
        for i = 1, select("#", ...) do
          local k = select(i, ...)
          tmap[k] = nil
          removed[k] = true
        end
        return tmap
      end
      local function _1324_(tmap)
        local t
        do
          local tbl_21_
          do
            local tbl_21_0 = {}
            for k, v in pairs(map0) do
              local k_22_, v_23_ = k, v
              if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
                tbl_21_0[k_22_] = v_23_
              else
              end
            end
            tbl_21_ = tbl_21_0
          end
          for k, v in pairs(tmap) do
            local k_22_, v_23_ = k, v
            if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
              tbl_21_[k_22_] = v_23_
            else
            end
          end
          t = tbl_21_
        end
        for k in pairs(removed) do
          t[k] = nil
        end
        local function _1327_()
          local tbl_26_ = {}
          local i_27_ = 0
          for k in pairs_2a(tmap) do
            local val_28_ = k
            if (nil ~= val_28_) then
              i_27_ = (i_27_ + 1)
              tbl_26_[i_27_] = val_28_
            else
            end
          end
          return tbl_26_
        end
        for _, k in ipairs(_1327_()) do
          tmap[k] = nil
        end
        local function _1329_()
          return error("attempt to use transient after it was persistet")
        end
        local function _1330_()
          return error("attempt to use transient after it was persistet")
        end
        setmetatable(tmap, {__index = _1329_, __newindex = _1330_})
        return immutable(itable(t))
      end
      return setmetatable({}, {__index = _1313_, ["cljlib/type"] = "transient", ["cljlib/conj"] = _1315_, ["cljlib/assoc"] = _1316_, ["cljlib/dissoc"] = _1317_, ["cljlib/conj!"] = _1319_, ["cljlib/assoc!"] = _1321_, ["cljlib/dissoc!"] = _1323_, ["cljlib/persistent!"] = _1324_})
    end
    return _1312_
  end
  local function hash_map_2a(x)
    do
      local case_1331_ = getmetatable(x)
      if (nil ~= case_1331_) then
        local mt = case_1331_
        mt["cljlib/type"] = "hash-map"
        mt["cljlib/editable"] = true
        local function _1333_(t, _1332_, ...)
          local k = _1332_[1]
          local v = _1332_[2]
          local function _1334_(...)
            local kvs = {}
            for _, _1335_ in ipairs_2a({...}) do
              local k0 = _1335_[1]
              local v0 = _1335_[2]
              table.insert(kvs, k0)
              table.insert(kvs, v0)
              kvs = kvs
            end
            return kvs
          end
          return apply(core.assoc, t, k, v, _1334_(...))
        end
        mt["cljlib/conj"] = _1333_
        mt["cljlib/transient"] = map__3etransient(hash_map_2a)
        local function _1336_()
          return hash_map_2a(itable({}))
        end
        mt["cljlib/empty"] = _1336_
      else
        local _ = case_1331_
        hash_map_2a(setmetatable(x, {}))
      end
    end
    return x
  end
  local assoc
  do
    local v_27_auto
    local function assoc0(...)
      local case_1340_ = select("#", ...)
      if (case_1340_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "assoc"))
      elseif (case_1340_ == 1) then
        local tbl = ...
        return hash_map_2a(itable({}))
      elseif (case_1340_ == 2) then
        return error(("Wrong number of args (%s) passed to %s"):format(2, "assoc"))
      elseif (case_1340_ == 3) then
        local tbl, k, v = ...
        assert((nil_3f(tbl) or map_3f(tbl) or empty_3f(tbl)), "expected a map")
        assert(not nil_3f(k), "attempt to use nil as key")
        return hash_map_2a(itable.assoc((tbl or {}), k, v))
      else
        local _ = case_1340_
        local _let_1341_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1341_.list
        local _let_1342_ = list_38_auto(...)
        local tbl = _let_1342_[1]
        local k = _let_1342_[2]
        local v = _let_1342_[3]
        local kvs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1342_, 4)
        assert((nil_3f(tbl) or map_3f(tbl) or empty_3f(tbl)), "expected a map")
        assert(not nil_3f(k), "attempt to use nil as key")
        return hash_map_2a(apply(itable.assoc, (tbl or {}), k, v, kvs))
      end
    end
    v_27_auto = assoc0
    core["assoc"] = v_27_auto
    assoc = v_27_auto
  end
  local assoc_in
  do
    local v_27_auto
    local function assoc_in0(...)
      local tbl, key_seq, val = ...
      do
        local cnt_54_auto = select("#", ...)
        if (3 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "assoc-in"))
        else
        end
      end
      assert((nil_3f(tbl) or map_3f(tbl) or empty_3f(tbl)), "expected a map or nil")
      return hash_map_2a(itable["assoc-in"](tbl, key_seq, val))
    end
    v_27_auto = assoc_in0
    core["assoc-in"] = v_27_auto
    assoc_in = v_27_auto
  end
  local update
  do
    local v_27_auto
    local function update0(...)
      local tbl, key, f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (3 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "update"))
        else
        end
      end
      assert((nil_3f(tbl) or map_3f(tbl) or empty_3f(tbl)), "expected a map")
      return hash_map_2a(itable.update(tbl, key, f))
    end
    v_27_auto = update0
    core["update"] = v_27_auto
    update = v_27_auto
  end
  local update_in
  do
    local v_27_auto
    local function update_in0(...)
      local tbl, key_seq, f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (3 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "update-in"))
        else
        end
      end
      assert((nil_3f(tbl) or map_3f(tbl) or empty_3f(tbl)), "expected a map or nil")
      return hash_map_2a(itable["update-in"](tbl, key_seq, f))
    end
    v_27_auto = update_in0
    core["update-in"] = v_27_auto
    update_in = v_27_auto
  end
  local hash_map
  do
    local v_27_auto
    local function hash_map0(...)
      local _let_1347_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1347_.list
      local _let_1348_ = list_38_auto(...)
      local kvs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1348_, 1)
      return apply(assoc, {}, kvs)
    end
    v_27_auto = hash_map0
    core["hash-map"] = v_27_auto
    hash_map = v_27_auto
  end
  local get
  do
    local v_27_auto
    local function get0(...)
      local case_1350_ = select("#", ...)
      if (case_1350_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "get"))
      elseif (case_1350_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "get"))
      elseif (case_1350_ == 2) then
        local tbl, key = ...
        return get0(tbl, key, nil)
      elseif (case_1350_ == 3) then
        local tbl, key, not_found = ...
        assert((map_3f(tbl) or empty_3f(tbl)), "expected a map")
        return (tbl[key] or not_found)
      else
        local _ = case_1350_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "get"))
      end
    end
    v_27_auto = get0
    core["get"] = v_27_auto
    get = v_27_auto
  end
  local get_in
  do
    local v_27_auto
    local function get_in0(...)
      local case_1353_ = select("#", ...)
      if (case_1353_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "get-in"))
      elseif (case_1353_ == 1) then
        return error(("Wrong number of args (%s) passed to %s"):format(1, "get-in"))
      elseif (case_1353_ == 2) then
        local tbl, keys0 = ...
        return get_in0(tbl, keys0, nil)
      elseif (case_1353_ == 3) then
        local tbl, keys0, not_found = ...
        assert((map_3f(tbl) or empty_3f(tbl)), "expected a map")
        local res, t, done = tbl, tbl, nil
        for _, k in ipairs_2a(keys0) do
          if done then break end
          local case_1354_ = t[k]
          if (nil ~= case_1354_) then
            local v = case_1354_
            res, t = v, v
          else
            local _0 = case_1354_
            res, done = not_found, true
          end
        end
        return res
      else
        local _ = case_1353_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "get-in"))
      end
    end
    v_27_auto = get_in0
    core["get-in"] = v_27_auto
    get_in = v_27_auto
  end
  local dissoc
  do
    local v_27_auto
    local function dissoc0(...)
      local case_1357_ = select("#", ...)
      if (case_1357_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "dissoc"))
      elseif (case_1357_ == 1) then
        local tbl = ...
        return tbl
      elseif (case_1357_ == 2) then
        local tbl, key = ...
        assert((map_3f(tbl) or empty_3f(tbl)), "expected a map")
        local function _1358_(...)
          tbl[key] = nil
          return tbl
        end
        return hash_map_2a(_1358_(...))
      else
        local _ = case_1357_
        local _let_1359_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1359_.list
        local _let_1360_ = list_38_auto(...)
        local tbl = _let_1360_[1]
        local key = _let_1360_[2]
        local keys0 = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1360_, 3)
        return apply(dissoc0, dissoc0(tbl, key), keys0)
      end
    end
    v_27_auto = dissoc0
    core["dissoc"] = v_27_auto
    dissoc = v_27_auto
  end
  local merge
  do
    local v_27_auto
    local function merge0(...)
      local _let_1362_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1362_.list
      local _let_1363_ = list_38_auto(...)
      local maps = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1363_, 1)
      if some(identity, maps) then
        local function _1364_(a0, b)
          local tbl_21_ = a0
          for k, v in pairs_2a(b) do
            local k_22_, v_23_ = k, v
            if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
              tbl_21_[k_22_] = v_23_
            else
            end
          end
          return tbl_21_
        end
        return hash_map_2a(itable(reduce(_1364_, {}, maps)))
      else
        return nil
      end
    end
    v_27_auto = merge0
    core["merge"] = v_27_auto
    merge = v_27_auto
  end
  local frequencies
  do
    local v_27_auto
    local function frequencies0(...)
      local t = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "frequencies"))
        else
        end
      end
      return hash_map_2a(itable.frequencies(t))
    end
    v_27_auto = frequencies0
    core["frequencies"] = v_27_auto
    frequencies = v_27_auto
  end
  local group_by
  do
    local v_27_auto
    local function group_by0(...)
      local f, t = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "group-by"))
        else
        end
      end
      return hash_map_2a((itable["group-by"](f, t)))
    end
    v_27_auto = group_by0
    core["group-by"] = v_27_auto
    group_by = v_27_auto
  end
  local zipmap
  do
    local v_27_auto
    local function zipmap0(...)
      local keys0, vals0 = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "zipmap"))
        else
        end
      end
      return hash_map_2a(itable(lazy.zipmap(keys0, vals0)))
    end
    v_27_auto = zipmap0
    core["zipmap"] = v_27_auto
    zipmap = v_27_auto
  end
  local replace
  do
    local v_27_auto
    local function replace0(...)
      local case_1370_ = select("#", ...)
      if (case_1370_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "replace"))
      elseif (case_1370_ == 1) then
        local smap = ...
        local function _1371_(_241)
          local val_97_auto = find(smap, _241)
          if val_97_auto then
            local e = val_97_auto
            return e[2]
          else
            return _241
          end
        end
        return map(_1371_)
      elseif (case_1370_ == 2) then
        local smap, coll = ...
        if vector_3f(coll) then
          local function _1373_(res, v)
            local val_97_auto = find(smap, v)
            if val_97_auto then
              local e = val_97_auto
              table.insert(res, e[2])
              return res
            else
              table.insert(res, v)
              return res
            end
          end
          return vec_2a(itable(reduce(_1373_, {}, coll)))
        else
          local function _1375_(_241)
            local val_97_auto = find(smap, _241)
            if val_97_auto then
              local e = val_97_auto
              return e[2]
            else
              return _241
            end
          end
          return map(_1375_, coll)
        end
      else
        local _ = case_1370_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "replace"))
      end
    end
    v_27_auto = replace0
    core["replace"] = v_27_auto
    replace = v_27_auto
  end
  local conj
  do
    local v_27_auto
    local function conj0(...)
      local case_1379_ = select("#", ...)
      if (case_1379_ == 0) then
        return vector()
      elseif (case_1379_ == 1) then
        local s = ...
        return s
      elseif (case_1379_ == 2) then
        local s, x = ...
        local case_1380_ = getmetatable(s)
        if ((_G.type(case_1380_) == "table") and (nil ~= case_1380_["cljlib/conj"])) then
          local f = case_1380_["cljlib/conj"]
          return f(s, x)
        else
          local _ = case_1380_
          if vector_3f(s) then
            return vec_2a(itable.insert(s, x))
          elseif map_3f(s) then
            return apply(assoc, s, x)
          elseif nil_3f(s) then
            return cons(x, s)
          elseif empty_3f(s) then
            return vector(x)
          else
            return error("expected collection, got", type(s))
          end
        end
      else
        local _ = case_1379_
        local _let_1383_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1383_.list
        local _let_1384_ = list_38_auto(...)
        local s = _let_1384_[1]
        local x = _let_1384_[2]
        local xs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1384_, 3)
        return apply(conj0, conj0(s, x), xs)
      end
    end
    v_27_auto = conj0
    core["conj"] = v_27_auto
    conj = v_27_auto
  end
  local disj
  do
    local v_27_auto
    local function disj0(...)
      local case_1386_ = select("#", ...)
      if (case_1386_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "disj"))
      elseif (case_1386_ == 1) then
        local Set = ...
        return Set
      elseif (case_1386_ == 2) then
        local Set, key = ...
        local case_1387_ = getmetatable(Set)
        if ((_G.type(case_1387_) == "table") and (case_1387_["cljlib/type"] == "hash-set") and (nil ~= case_1387_["cljlib/disj"])) then
          local f = case_1387_["cljlib/disj"]
          return f(Set, key)
        else
          local _ = case_1387_
          return error(("disj is not supported on " .. class(Set)), 2)
        end
      else
        local _ = case_1386_
        local _let_1389_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1389_.list
        local _let_1390_ = list_38_auto(...)
        local Set = _let_1390_[1]
        local key = _let_1390_[2]
        local keys0 = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1390_, 3)
        local case_1391_ = getmetatable(Set)
        if ((_G.type(case_1391_) == "table") and (case_1391_["cljlib/type"] == "hash-set") and (nil ~= case_1391_["cljlib/disj"])) then
          local f = case_1391_["cljlib/disj"]
          return apply(f, Set, key, keys0)
        else
          local _0 = case_1391_
          return error(("disj is not supported on " .. class(Set)), 2)
        end
      end
    end
    v_27_auto = disj0
    core["disj"] = v_27_auto
    disj = v_27_auto
  end
  local pop
  do
    local v_27_auto
    local function pop0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "pop"))
        else
        end
      end
      local case_1395_ = getmetatable(coll)
      if ((_G.type(case_1395_) == "table") and (case_1395_["cljlib/type"] == "seq")) then
        local case_1396_ = seq(coll)
        if (nil ~= case_1396_) then
          local s = case_1396_
          return drop(1, s)
        else
          local _ = case_1396_
          return error("can't pop empty list", 2)
        end
      elseif ((_G.type(case_1395_) == "table") and (nil ~= case_1395_["cljlib/pop"])) then
        local f = case_1395_["cljlib/pop"]
        return f(coll)
      else
        local _ = case_1395_
        return error(("pop is not supported on " .. class(coll)), 2)
      end
    end
    v_27_auto = pop0
    core["pop"] = v_27_auto
    pop = v_27_auto
  end
  local transient
  do
    local v_27_auto
    local function transient0(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "transient"))
        else
        end
      end
      local case_1400_ = getmetatable(coll)
      if ((_G.type(case_1400_) == "table") and (case_1400_["cljlib/editable"] == true) and (nil ~= case_1400_["cljlib/transient"])) then
        local f = case_1400_["cljlib/transient"]
        return f(coll)
      else
        local _ = case_1400_
        return error("expected editable collection", 2)
      end
    end
    v_27_auto = transient0
    core["transient"] = v_27_auto
    transient = v_27_auto
  end
  local conj_21
  do
    local v_27_auto
    local function conj_210(...)
      local case_1402_ = select("#", ...)
      if (case_1402_ == 0) then
        return transient(vec_2a({}))
      elseif (case_1402_ == 1) then
        local coll = ...
        return coll
      elseif (case_1402_ == 2) then
        local coll, x = ...
        do
          local case_1403_ = getmetatable(coll)
          if ((_G.type(case_1403_) == "table") and (case_1403_["cljlib/type"] == "transient") and (nil ~= case_1403_["cljlib/conj!"])) then
            local f = case_1403_["cljlib/conj!"]
            f(coll, x)
          elseif ((_G.type(case_1403_) == "table") and (case_1403_["cljlib/type"] == "transient")) then
            error("unsupported transient operation", 2)
          else
            local _ = case_1403_
            error("expected transient collection", 2)
          end
        end
        return coll
      else
        local _ = case_1402_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "conj!"))
      end
    end
    v_27_auto = conj_210
    core["conj!"] = v_27_auto
    conj_21 = v_27_auto
  end
  local assoc_21
  do
    local v_27_auto
    local function assoc_210(...)
      local _let_1406_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1406_.list
      local _let_1407_ = list_38_auto(...)
      local map0 = _let_1407_[1]
      local k = _let_1407_[2]
      local ks = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1407_, 3)
      do
        local case_1408_ = getmetatable(map0)
        if ((_G.type(case_1408_) == "table") and (case_1408_["cljlib/type"] == "transient") and (nil ~= case_1408_["cljlib/dissoc!"])) then
          local f = case_1408_["cljlib/dissoc!"]
          apply(f, map0, k, ks)
        elseif ((_G.type(case_1408_) == "table") and (case_1408_["cljlib/type"] == "transient")) then
          error("unsupported transient operation", 2)
        else
          local _ = case_1408_
          error("expected transient collection", 2)
        end
      end
      return map0
    end
    v_27_auto = assoc_210
    core["assoc!"] = v_27_auto
    assoc_21 = v_27_auto
  end
  local dissoc_21
  do
    local v_27_auto
    local function dissoc_210(...)
      local _let_1410_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1410_.list
      local _let_1411_ = list_38_auto(...)
      local map0 = _let_1411_[1]
      local k = _let_1411_[2]
      local ks = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1411_, 3)
      do
        local case_1412_ = getmetatable(map0)
        if ((_G.type(case_1412_) == "table") and (case_1412_["cljlib/type"] == "transient") and (nil ~= case_1412_["cljlib/dissoc!"])) then
          local f = case_1412_["cljlib/dissoc!"]
          apply(f, map0, k, ks)
        elseif ((_G.type(case_1412_) == "table") and (case_1412_["cljlib/type"] == "transient")) then
          error("unsupported transient operation", 2)
        else
          local _ = case_1412_
          error("expected transient collection", 2)
        end
      end
      return map0
    end
    v_27_auto = dissoc_210
    core["dissoc!"] = v_27_auto
    dissoc_21 = v_27_auto
  end
  local disj_21
  do
    local v_27_auto
    local function disj_210(...)
      local case_1414_ = select("#", ...)
      if (case_1414_ == 0) then
        return error(("Wrong number of args (%s) passed to %s"):format(0, "disj!"))
      elseif (case_1414_ == 1) then
        local Set = ...
        return Set
      else
        local _ = case_1414_
        local _let_1415_ = require("io.gitlab.andreyorst.cljlib.core")
        local list_38_auto = _let_1415_.list
        local _let_1416_ = list_38_auto(...)
        local Set = _let_1416_[1]
        local key = _let_1416_[2]
        local ks = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1416_, 3)
        local case_1417_ = getmetatable(Set)
        if ((_G.type(case_1417_) == "table") and (case_1417_["cljlib/type"] == "transient") and (nil ~= case_1417_["cljlib/disj!"])) then
          local f = case_1417_["cljlib/disj!"]
          return apply(f, Set, key, ks)
        elseif ((_G.type(case_1417_) == "table") and (case_1417_["cljlib/type"] == "transient")) then
          return error("unsupported transient operation", 2)
        else
          local _0 = case_1417_
          return error("expected transient collection", 2)
        end
      end
    end
    v_27_auto = disj_210
    core["disj!"] = v_27_auto
    disj_21 = v_27_auto
  end
  local pop_21
  do
    local v_27_auto
    local function pop_210(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "pop!"))
        else
        end
      end
      local case_1421_ = getmetatable(coll)
      if ((_G.type(case_1421_) == "table") and (case_1421_["cljlib/type"] == "transient") and (nil ~= case_1421_["cljlib/pop!"])) then
        local f = case_1421_["cljlib/pop!"]
        return f(coll)
      elseif ((_G.type(case_1421_) == "table") and (case_1421_["cljlib/type"] == "transient")) then
        return error("unsupported transient operation", 2)
      else
        local _ = case_1421_
        return error("expected transient collection", 2)
      end
    end
    v_27_auto = pop_210
    core["pop!"] = v_27_auto
    pop_21 = v_27_auto
  end
  local persistent_21
  do
    local v_27_auto
    local function persistent_210(...)
      local coll = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "persistent!"))
        else
        end
      end
      local case_1424_ = getmetatable(coll)
      if ((_G.type(case_1424_) == "table") and (case_1424_["cljlib/type"] == "transient") and (nil ~= case_1424_["cljlib/persistent!"])) then
        local f = case_1424_["cljlib/persistent!"]
        return f(coll)
      else
        local _ = case_1424_
        return error("expected transient collection", 2)
      end
    end
    v_27_auto = persistent_210
    core["persistent!"] = v_27_auto
    persistent_21 = v_27_auto
  end
  local into
  do
    local v_27_auto
    local function into0(...)
      local case_1426_ = select("#", ...)
      if (case_1426_ == 0) then
        return vector()
      elseif (case_1426_ == 1) then
        local to = ...
        return to
      elseif (case_1426_ == 2) then
        local to, from = ...
        local case_1427_ = getmetatable(to)
        if ((_G.type(case_1427_) == "table") and (case_1427_["cljlib/editable"] == true)) then
          return persistent_21(reduce(conj_21, transient(to), from))
        else
          local _ = case_1427_
          return reduce(conj, to, from)
        end
      elseif (case_1426_ == 3) then
        local to, xform, from = ...
        local case_1429_ = getmetatable(to)
        if ((_G.type(case_1429_) == "table") and (case_1429_["cljlib/editable"] == true)) then
          return persistent_21(transduce(xform, conj_21, transient(to), from))
        else
          local _ = case_1429_
          return transduce(xform, conj, to, from)
        end
      else
        local _ = case_1426_
        return error(("Wrong number of args (%s) passed to %s"):format(_, "into"))
      end
    end
    v_27_auto = into0
    core["into"] = v_27_auto
    into = v_27_auto
  end
  local function viewset(Set, view, inspector, indent)
    if inspector.seen[Set] then
      return ("@set" .. inspector.seen[Set] .. "{...}")
    else
      local prefix
      local _1432_
      if inspector["visible-cycle?"](Set) then
        _1432_ = inspector.seen[Set]
      else
        _1432_ = ""
      end
      prefix = ("@set" .. _1432_ .. "{")
      local set_indent = #prefix
      local indent_str = string.rep(" ", set_indent)
      local lines
      do
        local tbl_26_ = {}
        local i_27_ = 0
        for v in pairs_2a(Set) do
          local val_28_ = (indent_str .. view(v, inspector, (indent + set_indent), true))
          if (nil ~= val_28_) then
            i_27_ = (i_27_ + 1)
            tbl_26_[i_27_] = val_28_
          else
          end
        end
        lines = tbl_26_
      end
      lines[1] = (prefix .. string.gsub((lines[1] or ""), "^%s+", ""))
      lines[#lines] = (lines[#lines] .. "}")
      return lines
    end
  end
  local function hash_set__3etransient(immutable)
    local function _1436_(hset)
      local removed = setmetatable({}, {__index = deep_index})
      local function _1437_(_, k)
        if not removed[k] then
          return hset[k]
        else
          return nil
        end
      end
      local function _1439_()
        return error("can't `conj` onto transient set, use `conj!`")
      end
      local function _1440_()
        return error("can't `disj` a transient set, use `disj!`")
      end
      local function _1441_()
        return error("can't `assoc` onto transient set, use `assoc!`")
      end
      local function _1442_()
        return error("can't `dissoc` onto transient set, use `dissoc!`")
      end
      local function _1443_(thset, v)
        if (nil == v) then
          removed[v] = true
        else
          removed[v] = nil
        end
        thset[v] = v
        return thset
      end
      local function _1445_()
        return error("can't `dissoc!` a transient set")
      end
      local function _1446_(thset, ...)
        for i = 1, select("#", ...) do
          local k = select(i, ...)
          thset[k] = nil
          removed[k] = true
        end
        return thset
      end
      local function _1447_(thset)
        local t
        do
          local tbl_21_
          do
            local tbl_21_0 = {}
            for k, v in pairs(hset) do
              local k_22_, v_23_ = k, v
              if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
                tbl_21_0[k_22_] = v_23_
              else
              end
            end
            tbl_21_ = tbl_21_0
          end
          for k, v in pairs(thset) do
            local k_22_, v_23_ = k, v
            if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
              tbl_21_[k_22_] = v_23_
            else
            end
          end
          t = tbl_21_
        end
        for k in pairs(removed) do
          t[k] = nil
        end
        local function _1450_()
          local tbl_26_ = {}
          local i_27_ = 0
          for k in pairs_2a(thset) do
            local val_28_ = k
            if (nil ~= val_28_) then
              i_27_ = (i_27_ + 1)
              tbl_26_[i_27_] = val_28_
            else
            end
          end
          return tbl_26_
        end
        for _, k in ipairs(_1450_()) do
          thset[k] = nil
        end
        local function _1452_()
          return error("attempt to use transient after it was persistet")
        end
        local function _1453_()
          return error("attempt to use transient after it was persistet")
        end
        setmetatable(thset, {__index = _1452_, __newindex = _1453_})
        return immutable(itable(t))
      end
      return setmetatable({}, {__index = _1437_, ["cljlib/type"] = "transient", ["cljlib/conj"] = _1439_, ["cljlib/disj"] = _1440_, ["cljlib/assoc"] = _1441_, ["cljlib/dissoc"] = _1442_, ["cljlib/conj!"] = _1443_, ["cljlib/assoc!"] = _1445_, ["cljlib/disj!"] = _1446_, ["cljlib/persistent!"] = _1447_})
    end
    return _1436_
  end
  local function hash_set_2a(x)
    do
      local case_1454_ = getmetatable(x)
      if (nil ~= case_1454_) then
        local mt = case_1454_
        mt["cljlib/type"] = "hash-set"
        local function _1455_(s, v, ...)
          local function _1456_(...)
            local res = {}
            for _, v0 in ipairs({...}) do
              table.insert(res, v0)
              table.insert(res, v0)
            end
            return res
          end
          return hash_set_2a(itable.assoc(s, v, v, unpack_2a(_1456_(...))))
        end
        mt["cljlib/conj"] = _1455_
        local function _1457_(s, k, ...)
          local to_remove
          do
            local tbl_21_ = setmetatable({[k] = true}, {__index = deep_index})
            for _, k0 in ipairs({...}) do
              local k_22_, v_23_ = k0, true
              if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
                tbl_21_[k_22_] = v_23_
              else
              end
            end
            to_remove = tbl_21_
          end
          local function _1459_(...)
            local res = {}
            for _, v in pairs(s) do
              if not to_remove[v] then
                table.insert(res, v)
                table.insert(res, v)
              else
              end
            end
            return res
          end
          return hash_set_2a(itable.assoc({}, unpack_2a(_1459_(...))))
        end
        mt["cljlib/disj"] = _1457_
        local function _1461_()
          return hash_set_2a(itable({}))
        end
        mt["cljlib/empty"] = _1461_
        mt["cljlib/editable"] = true
        mt["cljlib/transient"] = hash_set__3etransient(hash_set_2a)
        local function _1462_(s)
          local function _1463_(_241)
            if vector_3f(_241) then
              return _241[1]
            else
              return _241
            end
          end
          return map(_1463_, s)
        end
        mt["cljlib/seq"] = _1462_
        mt["__fennelview"] = viewset
        local function _1465_(s, i)
          local j = 1
          local vals0 = {}
          for v in pairs_2a(s) do
            if (j >= i) then
              table.insert(vals0, v)
            else
              j = (j + 1)
            end
          end
          return core["hash-set"](unpack_2a(vals0))
        end
        mt["__fennelrest"] = _1465_
      else
        local _ = case_1454_
        hash_set_2a(setmetatable(x, {}))
      end
    end
    return x
  end
  local hash_set
  do
    local v_27_auto
    local function hash_set0(...)
      local _let_1468_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1468_.list
      local _let_1469_ = list_38_auto(...)
      local xs = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1469_, 1)
      local Set
      do
        local tbl_21_ = setmetatable({}, {__newindex = deep_newindex})
        for _, val in pairs_2a(xs) do
          local k_22_, v_23_ = val, val
          if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
            tbl_21_[k_22_] = v_23_
          else
          end
        end
        Set = tbl_21_
      end
      return hash_set_2a(itable(Set))
    end
    v_27_auto = hash_set0
    core["hash-set"] = v_27_auto
    hash_set = v_27_auto
  end
  local multifn_3f
  do
    local v_27_auto
    local function multifn_3f0(...)
      local mf = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "multifn?"))
        else
        end
      end
      local case_1472_ = getmetatable(mf)
      if ((_G.type(case_1472_) == "table") and (case_1472_["cljlib/type"] == "multifn")) then
        return true
      else
        local _ = case_1472_
        return false
      end
    end
    v_27_auto = multifn_3f0
    core["multifn?"] = v_27_auto
    multifn_3f = v_27_auto
  end
  local remove_method
  do
    local v_27_auto
    local function remove_method0(...)
      local multimethod, dispatch_value = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "remove-method"))
        else
        end
      end
      if multifn_3f(multimethod) then
        multimethod[dispatch_value] = nil
      else
        error((tostring(multimethod) .. " is not a multifn"), 2)
      end
      return multimethod
    end
    v_27_auto = remove_method0
    core["remove-method"] = v_27_auto
    remove_method = v_27_auto
  end
  local remove_all_methods
  do
    local v_27_auto
    local function remove_all_methods0(...)
      local multimethod = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "remove-all-methods"))
        else
        end
      end
      if multifn_3f(multimethod) then
        for k, _ in pairs(multimethod) do
          multimethod[k] = nil
        end
      else
        error((tostring(multimethod) .. " is not a multifn"), 2)
      end
      return multimethod
    end
    v_27_auto = remove_all_methods0
    core["remove-all-methods"] = v_27_auto
    remove_all_methods = v_27_auto
  end
  local methods
  do
    local v_27_auto
    local function methods0(...)
      local multimethod = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "methods"))
        else
        end
      end
      if multifn_3f(multimethod) then
        local m = {}
        for k, v in pairs(multimethod) do
          m[k] = v
        end
        return m
      else
        return error((tostring(multimethod) .. " is not a multifn"), 2)
      end
    end
    v_27_auto = methods0
    core["methods"] = v_27_auto
    methods = v_27_auto
  end
  local get_method
  do
    local v_27_auto
    local function get_method0(...)
      local multimethod, dispatch_value = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "get-method"))
        else
        end
      end
      if multifn_3f(multimethod) then
        return (multimethod[dispatch_value] or multimethod.default)
      else
        return error((tostring(multimethod) .. " is not a multifn"), 2)
      end
    end
    v_27_auto = get_method0
    core["get-method"] = v_27_auto
    get_method = v_27_auto
  end
  local inst
  do
    local v_27_auto
    local function inst0(...)
      local s = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "inst"))
        else
        end
      end
      local date = lua_inst(s)
      local function _1483_(_241)
        return ("#<inst: %04d-%s.%03d-00:00>"):format(_241.year, os.date("%m-%dT%H:%M:%S", os.time(_241)), _241.msec)
      end
      getmetatable(date)["__fennelview"] = _1483_
      return date
    end
    v_27_auto = inst0
    core["inst"] = v_27_auto
    inst = v_27_auto
  end
  local function start_task_runner(agent)
    local function _1484_()
      while (agent.status == "ready") do
        local _let_1485_ = a["<!"](agent.tasks)
        local f = _let_1485_[1]
        local args = _let_1485_[2]
        local task_ok_3f, state_or_msg = pcall(apply, f, agent.state, args)
        local task_ok_3f0, state_or_msg0
        if task_ok_3f then
          local validator_ok, err = pcall(agent.validator, state_or_msg)
          if validator_ok then
            task_ok_3f0, state_or_msg0 = true, state_or_msg
          else
            task_ok_3f0, state_or_msg0 = false, err
          end
        else
          task_ok_3f0, state_or_msg0 = false, state_or_msg
        end
        local case_1488_, case_1489_ = task_ok_3f0, state_or_msg0
        if ((case_1488_ == true) and true) then
          local _3fstate = case_1489_
          agent.state = _3fstate
        elseif ((case_1488_ == false) and (nil ~= case_1489_)) then
          local err = case_1489_
          if (agent["error-mode"] ~= "continue") then
            agent.status = "failed"
            agent.error = err
          else
          end
          if agent["error-handler"] then
            agent["error-handler"](agent, err)
          else
          end
        else
        end
      end
      return nil
    end
    a["go*"](_1484_)
    return nil
  end
  local agents = {}
  local agent
  do
    local v_27_auto
    local function agent0(...)
      local _let_1493_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1493_.list
      local _let_1494_ = list_38_auto(...)
      local state = _let_1494_[1]
      local options = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1494_, 2)
      local opts = apply(hash_map, options)
      local agent1
      local _1495_
      if opts.validator then
        local function _1496_(newstate)
          if not opts.validator(newstate) then
            return error("Invalid reference state", 2)
          else
            return nil
          end
        end
        _1495_ = _1496_
      else
        local function _1498_()
          return true
        end
        _1495_ = _1498_
      end
      local or_1500_ = opts["error-handler"]
      if not or_1500_ then
        local function _1501_()
          return true
        end
        or_1500_ = _1501_
      end
      local function _1502_(self)
        return self.state
      end
      local function _1503_(agent2, task)
        if (agent2.status ~= "ready") then
          error(agent2.error, 3)
        else
        end
        local function _1505_()
          return a[">!"](agent2.tasks, task)
        end
        a["go*"](_1505_)
        return agent2
      end
      local function _1506_(agent2, view, inspector, indent)
        local prefix = ("#<" .. string.gsub(tostring(agent2), "table", "agent") .. " ")
        local _1507_
        do
          inspector["one-line?"] = true
          _1507_ = inspector
        end
        return {(prefix .. view({val = agent2.state, status = agent2.status}, _1507_, (indent + #prefix)) .. ">")}
      end
      agent1 = setmetatable({state = state, ["error-mode"] = (opts["error-mode"] or (opts["error-handler"] and "continue") or "fail"), validator = _1495_, ["error-handler"] = or_1500_, status = "ready", tasks = a.chan()}, {["cljlib/type"] = "agent", ["cljlib/deref"] = _1502_, ["cljlib/send"] = _1503_, __fennelview = _1506_})
      start_task_runner(agent1)
      agents[agent1] = true
      return agent1
    end
    v_27_auto = agent0
    core["agent"] = v_27_auto
    agent = v_27_auto
  end
  local set_error_handler_21
  do
    local v_27_auto
    local function set_error_handler_210(...)
      local agent0, handler_fn = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "set-error-handler!"))
        else
        end
      end
      agent0["error-handler"] = handler_fn
      return nil
    end
    v_27_auto = set_error_handler_210
    core["set-error-handler!"] = v_27_auto
    set_error_handler_21 = v_27_auto
  end
  local set_error_mode_21
  do
    local v_27_auto
    local function set_error_mode_210(...)
      local agent0, mode_keyword = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "set-error-mode!"))
        else
        end
      end
      agent0["error-mode"] = mode_keyword
      return nil
    end
    v_27_auto = set_error_mode_210
    core["set-error-mode!"] = v_27_auto
    set_error_mode_21 = v_27_auto
  end
  local agent_error
  do
    local v_27_auto
    local function agent_error0(...)
      local agent0 = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "agent-error"))
        else
        end
      end
      return agent0.error
    end
    v_27_auto = agent_error0
    core["agent-error"] = v_27_auto
    agent_error = v_27_auto
  end
  local restart_agent
  do
    local v_27_auto
    local function restart_agent0(...)
      local _let_1511_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1511_.list
      local _let_1512_ = list_38_auto(...)
      local agent0 = _let_1512_[1]
      local new_state = _let_1512_[2]
      local options = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1512_, 3)
      if (agent0.status ~= "failed") then
        error("Agent does not need a restart", 2)
      else
      end
      local opts = apply(hash_map, options)
      do
        agent0["state"] = new_state
        agent0["status"] = "ready"
        agent0["error"] = nil
      end
      if opts["clear-actions"] then
        agent0.tasks = a.chan()
      else
      end
      return start_task_runner(agent0)
    end
    v_27_auto = restart_agent0
    core["restart-agent"] = v_27_auto
    restart_agent = v_27_auto
  end
  local send
  do
    local v_27_auto
    local function send0(...)
      local _let_1515_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1515_.list
      local _let_1516_ = list_38_auto(...)
      local a0 = _let_1516_[1]
      local f = _let_1516_[2]
      local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1516_, 3)
      do
        local case_1517_ = getmetatable(a0)
        if ((_G.type(case_1517_) == "table") and (nil ~= case_1517_["cljlib/send"])) then
          local send1 = case_1517_["cljlib/send"]
          send1(a0, {f, args})
        else
          local _ = case_1517_
          error("object doesn't implement cljlib/send metamethod", 2)
        end
      end
      return a0
    end
    v_27_auto = send0
    core["send"] = v_27_auto
    send = v_27_auto
  end
  local shutdown_agents
  do
    local v_27_auto
    local function shutdown_agents0(...)
      do
        local cnt_54_auto = select("#", ...)
        if (0 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "shutdown-agents"))
        else
        end
      end
      for agent0 in pairs(agents) do
        agent0.status = nil
        local function _1520_(x)
          return x
        end
        send(a, _1520_)
      end
      agents = {}
      return nil
    end
    v_27_auto = shutdown_agents0
    core["shutdown-agents"] = v_27_auto
    shutdown_agents = v_27_auto
  end
  local atom
  do
    local v_27_auto
    local function atom0(...)
      local _let_1521_ = require("io.gitlab.andreyorst.cljlib.core")
      local list_38_auto = _let_1521_.list
      local _let_1522_ = list_38_auto(...)
      local x = _let_1522_[1]
      local options = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_1522_, 2)
      local opts = apply(hash_map, options)
      if (opts.validator and not opts.validator(x)) then
        error("Invalid reference state", 2)
      else
      end
      local _1524_
      if opts.validator then
        local function _1525_(newstate)
          if not opts.validator(newstate) then
            return error("Invalid reference state", 2)
          else
            return nil
          end
        end
        _1524_ = _1525_
      else
        local function _1527_(_newstate)
          return true
        end
        _1524_ = _1527_
      end
      local function _1529_(self)
        return self.val
      end
      local function _1530_(atom1, view, inspector, indent)
        local prefix = ("#<" .. string.gsub(tostring(agent), "table", "atom") .. " ")
        local _1531_
        do
          inspector["one-line?"] = true
          _1531_ = inspector
        end
        return {(prefix .. view({val = atom1.val, status = "ready"}, _1531_, (indent + #prefix)) .. ">")}
      end
      return setmetatable({val = x, validator = _1524_}, {["cljlib/type"] = "atom", ["cljlib/deref"] = _1529_, __fennelview = _1530_})
    end
    v_27_auto = atom0
    core["atom"] = v_27_auto
    atom = v_27_auto
  end
  core["swap!"] = function(atom0, f, ...)
    local newval = f(atom0.val, ...)
    atom0.validator(newval)
    atom0.val = newval
    return newval
  end
  local reset_21
  do
    local v_27_auto
    local function reset_210(...)
      local atom0, newval = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "reset!"))
        else
        end
      end
      local function _1533_()
        return newval
      end
      return core["swap!"](atom0, _1533_)
    end
    v_27_auto = reset_210
    core["reset!"] = v_27_auto
    reset_21 = v_27_auto
  end
  local volatile_21
  do
    local v_27_auto
    local function volatile_210(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "volatile!"))
        else
        end
      end
      local function _1535_(self)
        return self.val
      end
      local function _1536_(volatile, view, inspector, indent)
        local prefix = ("#<" .. string.gsub(tostring(agent), "table", "volatile") .. " ")
        local _1537_
        do
          inspector["one-line?"] = true
          _1537_ = inspector
        end
        return {(prefix .. view({val = volatile.val, status = "ready"}, _1537_, (indent + #prefix)) .. ">")}
      end
      return setmetatable({val = x}, {["cljlib/type"] = "volatile", ["cljlib/deref"] = _1535_, __fennelview = _1536_})
    end
    v_27_auto = volatile_210
    core["volatile!"] = v_27_auto
    volatile_21 = v_27_auto
  end
  core["vswap!"] = function(volatile, f, ...)
    local newval = f(volatile.val, ...)
    volatile.val = newval
    return newval
  end
  local vreset_21
  do
    local v_27_auto
    local function vreset_210(...)
      local volatile, newval = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "vreset!"))
        else
        end
      end
      local function _1539_()
        return newval
      end
      return core["vswap!"](volatile, _1539_)
    end
    v_27_auto = vreset_210
    core["vreset!"] = v_27_auto
    vreset_21 = v_27_auto
  end
  local set_validator_21
  do
    local v_27_auto
    local function set_validator_210(...)
      local agent_2fatom, validator_fn = ...
      do
        local cnt_54_auto = select("#", ...)
        if (2 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "set-validator!"))
        else
        end
      end
      if ((nil ~= validator_fn) and not validator_fn(deref(agent_2fatom))) then
        error("Invalid reference state", 2)
      else
      end
      local function _1542_(newstate)
        if not validator_fn(newstate) then
          return error("Invalid reference state", 2)
        else
          return nil
        end
      end
      agent_2fatom.validator = _1542_
      return nil
    end
    v_27_auto = set_validator_210
    core["set-validator!"] = v_27_auto
    set_validator_21 = v_27_auto
  end
  local tap_ch = a.chan()
  local mult_ch = a.mult(tap_ch)
  local taps = {}
  local remove_tap
  do
    local v_27_auto
    local function remove_tap0(...)
      local f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "remove-tap"))
        else
        end
      end
      do
        local case_1545_ = taps[f]
        if (nil ~= case_1545_) then
          local c = case_1545_
          a.untap(mult_ch, c)
          a["close!"](c)
        else
        end
      end
      taps[f] = nil
      return nil
    end
    v_27_auto = remove_tap0
    core["remove-tap"] = v_27_auto
    remove_tap = v_27_auto
  end
  local add_tap
  do
    local v_27_auto
    local function add_tap0(...)
      local f = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "add-tap"))
        else
        end
      end
      remove_tap(f)
      local c = a.chan()
      a.tap(mult_ch, c)
      local function _1548_()
        local function recur()
          local data = a["<!"](c)
          if data then
            f(data)
            return recur()
          else
            return nil
          end
        end
        return recur()
      end
      a["go*"](_1548_)
      taps[f] = c
      return nil
    end
    v_27_auto = add_tap0
    core["add-tap"] = v_27_auto
    add_tap = v_27_auto
  end
  local tap_3e
  do
    local v_27_auto
    local function tap_3e0(...)
      local x = ...
      do
        local cnt_54_auto = select("#", ...)
        if (1 ~= cnt_54_auto) then
          error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "tap>"))
        else
        end
      end
      return a["offer!"](tap_ch, x)
    end
    v_27_auto = tap_3e0
    core["tap>"] = v_27_auto
    tap_3e = v_27_auto
  end
  return core
end
package.preload["io.gitlab.andreyorst.lazy-seq"] = package.preload["io.gitlab.andreyorst.lazy-seq"] or function(...)
  --[[ "MIT License
  
    Copyright (c) 2021 Andrey Listopadov
  
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the “Software”), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
  
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
  
    THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE." ]]
  utf8 = _G.utf8
  local function pairs_2a(t)
    local mt = getmetatable(t)
    if (("table" == mt) and mt.__pairs) then
      return mt.__pairs(t)
    else
      return pairs(t)
    end
  end
  local function ipairs_2a(t)
    local mt = getmetatable(t)
    if (("table" == mt) and mt.__ipairs) then
      return mt.__ipairs(t)
    else
      return ipairs(t)
    end
  end
  local function rev_ipairs(t)
    local function _14_(t0, i)
      local i0 = (i - 1)
      if (i0 == 0) then
        return nil
      else
        local _ = i0
        return i0, t0[i0]
      end
    end
    return _14_, t, (1 + #t)
  end
  local function length_2a(t)
    local mt = getmetatable(t)
    if (("table" == mt) and mt.__len) then
      return mt.__len(t)
    else
      return #t
    end
  end
  local function table_pack(...)
    local tmp_9_ = {...}
    tmp_9_["n"] = select("#", ...)
    return tmp_9_
  end
  local table_unpack = (table.unpack or _G.unpack)
  local seq = nil
  local cons_iter = nil
  local function first(s)
    local case_17_ = seq(s)
    if (nil ~= case_17_) then
      local s_2a = case_17_
      return s_2a(true)
    else
      local _ = case_17_
      return nil
    end
  end
  local function empty_cons_view()
    return "@seq()"
  end
  local function empty_cons_len()
    return 0
  end
  local function empty_cons_index()
    return nil
  end
  local function cons_newindex()
    return error("cons cell is immutable")
  end
  local function empty_cons_next(_)
    return nil
  end
  local function empty_cons_pairs(s)
    return empty_cons_next, nil, s
  end
  local function gettype(x)
    local case_19_
    do
      local t_20_ = getmetatable(x)
      if (nil ~= t_20_) then
        t_20_ = t_20_["__lazy-seq/type"]
      else
      end
      case_19_ = t_20_
    end
    if (nil ~= case_19_) then
      local t = case_19_
      return t
    else
      local _ = case_19_
      return type(x)
    end
  end
  local function realize(c)
    if ("lazy-cons" == gettype(c)) then
      c()
    else
    end
    return c
  end
  local empty_cons = {}
  local function empty_cons_call(tf)
    if tf then
      return nil
    else
      return empty_cons
    end
  end
  local function empty_cons_fennelrest()
    return empty_cons
  end
  local function empty_cons_eq(_, s)
    return rawequal(getmetatable(empty_cons), getmetatable(realize(s)))
  end
  setmetatable(empty_cons, {__call = empty_cons_call, __len = empty_cons_len, __fennelview = empty_cons_view, __fennelrest = empty_cons_fennelrest, ["__lazy-seq/type"] = "empty-cons", __newindex = cons_newindex, __index = empty_cons_index, __name = "cons", __eq = empty_cons_eq, __pairs = empty_cons_pairs})
  local function rest(s)
    local case_25_ = seq(s)
    if (nil ~= case_25_) then
      local s_2a = case_25_
      return s_2a(false)
    else
      local _ = case_25_
      return empty_cons
    end
  end
  local function seq_3f(x)
    local tp = gettype(x)
    return ((tp == "cons") or (tp == "lazy-cons") or (tp == "empty-cons"))
  end
  local function empty_3f(x)
    return not seq(x)
  end
  local function next(s)
    return seq(realize(rest(seq(s))))
  end
  local function view_seq(list, options, view, indent, elements)
    table.insert(elements, view(first(list), options, indent))
    do
      local tail = next(list)
      if ("cons" == gettype(tail)) then
        view_seq(tail, options, view, indent, elements)
      else
      end
    end
    return elements
  end
  local function pp_seq(list, view, options, indent)
    local items = view_seq(list, options, view, (indent + 5), {})
    local lines
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for i, line in ipairs(items) do
        local val_28_
        if (i == 1) then
          val_28_ = line
        else
          val_28_ = ("     " .. line)
        end
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      lines = tbl_26_
    end
    lines[1] = ("@seq(" .. (lines[1] or ""))
    lines[#lines] = (lines[#lines] .. ")")
    return lines
  end
  local drop = nil
  local function cons_fennelrest(c, i)
    return drop((i - 1), c)
  end
  local allowed_types = {cons = true, ["empty-cons"] = true, ["lazy-cons"] = true, ["nil"] = true, string = true, table = true}
  local function cons_next(_, s)
    if (empty_cons ~= s) then
      local tail = next(s)
      local case_30_ = gettype(tail)
      if (case_30_ == "cons") then
        return tail, first(s)
      else
        local _0 = case_30_
        return empty_cons, first(s)
      end
    else
      return nil
    end
  end
  local function cons_pairs(s)
    return cons_next, nil, s
  end
  local function cons_eq(s1, s2)
    if rawequal(s1, s2) then
      return true
    else
      if (not rawequal(s2, empty_cons) and not rawequal(s1, empty_cons)) then
        local s10, s20, res = s1, s2, true
        while (res and s10 and s20) do
          res = (first(s10) == first(s20))
          s10 = next(s10)
          s20 = next(s20)
        end
        return res
      else
        return false
      end
    end
  end
  local function cons_len(s)
    local s0, len = s, 0
    while s0 do
      s0, len = next(s0), (len + 1)
    end
    return len
  end
  local function cons_index(s, i)
    if (i > 0) then
      local s0, i_2a = s, 1
      while ((i_2a ~= i) and s0) do
        s0, i_2a = next(s0), (i_2a + 1)
      end
      return first(s0)
    else
      return nil
    end
  end
  local function cons(head, tail)
    do local _ = {head, tail} end
    local tp = gettype(tail)
    assert(allowed_types[tp], ("expected nil, cons, table, or string as a tail, got: %s"):format(tp))
    local function _36_(_241, _242)
      if _242 then
        return head
      else
        if (nil ~= tail) then
          local s = tail
          return s
        elseif (tail == nil) then
          return empty_cons
        else
          return nil
        end
      end
    end
    return setmetatable({}, {__call = _36_, ["__lazy-seq/type"] = "cons", __index = cons_index, __newindex = cons_newindex, __len = cons_len, __pairs = cons_pairs, __name = "cons", __eq = cons_eq, __fennelview = pp_seq, __fennelrest = cons_fennelrest})
  end
  local function _39_(s)
    local case_40_ = gettype(s)
    if (case_40_ == "cons") then
      return s
    elseif (case_40_ == "lazy-cons") then
      return seq(realize(s))
    elseif (case_40_ == "empty-cons") then
      return nil
    elseif (case_40_ == "nil") then
      return nil
    elseif (case_40_ == "table") then
      return cons_iter(s)
    elseif (case_40_ == "string") then
      return cons_iter(s)
    else
      local _ = case_40_
      return error(("expected table, string or sequence, got %s"):format(_), 2)
    end
  end
  seq = _39_
  local function lazy_seq_2a(f)
    local lazy_cons = cons(nil, nil)
    local realize0
    local function _42_()
      local s = seq(f())
      if (nil ~= s) then
        return setmetatable(lazy_cons, getmetatable(s))
      else
        return setmetatable(lazy_cons, getmetatable(empty_cons))
      end
    end
    realize0 = _42_
    local function _44_(_241, _242)
      return realize0()(_242)
    end
    local function _45_(_241, _242)
      return realize0()[_242]
    end
    local function _46_(...)
      realize0()
      return pp_seq(...)
    end
    local function _47_()
      return length_2a(realize0())
    end
    local function _48_()
      return pairs_2a(realize0())
    end
    local function _49_(_241, _242)
      return (realize0() == _242)
    end
    return setmetatable(lazy_cons, {__call = _44_, __index = _45_, __newindex = cons_newindex, __fennelview = _46_, __fennelrest = cons_fennelrest, __len = _47_, __pairs = _48_, __name = "lazy cons", __eq = _49_, ["__lazy-seq/type"] = "lazy-cons"})
  end
  local function list(...)
    local args = table_pack(...)
    local l = empty_cons
    for i = args.n, 1, -1 do
      l = cons(args[i], l)
    end
    return l
  end
  local function spread(arglist)
    local arglist0 = seq(arglist)
    if (nil == arglist0) then
      return nil
    elseif (nil == next(arglist0)) then
      return seq(first(arglist0))
    elseif "else" then
      return cons(first(arglist0), spread(next(arglist0)))
    else
      return nil
    end
  end
  local function list_2a(...)
    local case_51_, case_52_, case_53_, case_54_, case_55_ = select("#", ...), ...
    if ((case_51_ == 1) and true) then
      local _3fargs = case_52_
      return seq(_3fargs)
    elseif ((case_51_ == 2) and true and true) then
      local _3fa = case_52_
      local _3fargs = case_53_
      return cons(_3fa, seq(_3fargs))
    elseif ((case_51_ == 3) and true and true and true) then
      local _3fa = case_52_
      local _3fb = case_53_
      local _3fargs = case_54_
      return cons(_3fa, cons(_3fb, seq(_3fargs)))
    elseif ((case_51_ == 4) and true and true and true and true) then
      local _3fa = case_52_
      local _3fb = case_53_
      local _3fc = case_54_
      local _3fargs = case_55_
      return cons(_3fa, cons(_3fb, cons(_3fc, seq(_3fargs))))
    else
      local _ = case_51_
      return spread(list(...))
    end
  end
  local function kind(t)
    local case_57_ = type(t)
    if (case_57_ == "table") then
      local len = length_2a(t)
      local nxt, t_2a, k = pairs_2a(t)
      local function _58_()
        if (len == 0) then
          return k
        else
          return len
        end
      end
      if (nil ~= nxt(t_2a, _58_())) then
        return "assoc"
      elseif (len > 0) then
        return "seq"
      else
        return "empty"
      end
    elseif (case_57_ == "string") then
      local len
      if utf8 then
        len = utf8.len(t)
      else
        len = #t
      end
      if (len > 0) then
        return "string"
      else
        return "empty"
      end
    else
      local _ = case_57_
      return "else"
    end
  end
  local function rseq(rev)
    local case_63_ = gettype(rev)
    if (case_63_ == "table") then
      local case_64_ = kind(rev)
      if (case_64_ == "seq") then
        local function wrap(nxt, t, i)
          local i0, v = nxt(t, i)
          if (nil ~= i0) then
            local function _65_()
              return wrap(nxt, t, i0)
            end
            return cons(v, lazy_seq_2a(_65_))
          else
            return empty_cons
          end
        end
        return wrap(rev_ipairs(rev))
      elseif (case_64_ == "empty") then
        return nil
      else
        local _ = case_64_
        return error("can't create an rseq from a non-sequential table")
      end
    else
      local _ = case_63_
      return error(("can't create an rseq from a " .. _))
    end
  end
  local function _69_(t)
    local case_70_ = kind(t)
    if (case_70_ == "assoc") then
      local function wrap(nxt, t0, k)
        local k0, v = nxt(t0, k)
        if (nil ~= k0) then
          local function _71_()
            return wrap(nxt, t0, k0)
          end
          return cons({k0, v}, lazy_seq_2a(_71_))
        else
          return empty_cons
        end
      end
      return wrap(pairs_2a(t))
    elseif (case_70_ == "seq") then
      local function wrap(nxt, t0, i)
        local i0, v = nxt(t0, i)
        if (nil ~= i0) then
          local function _73_()
            return wrap(nxt, t0, i0)
          end
          return cons(v, lazy_seq_2a(_73_))
        else
          return empty_cons
        end
      end
      return wrap(ipairs_2a(t))
    elseif (case_70_ == "string") then
      local char
      if utf8 then
        char = utf8.char
      else
        char = string.char
      end
      local function wrap(nxt, t0, i)
        local i0, v = nxt(t0, i)
        if (nil ~= i0) then
          local function _76_()
            return wrap(nxt, t0, i0)
          end
          return cons(char(v), lazy_seq_2a(_76_))
        else
          return empty_cons
        end
      end
      local function _78_()
        if utf8 then
          return utf8.codes(t)
        else
          return ipairs_2a({string.byte(t, 1, #t)})
        end
      end
      return wrap(_78_())
    elseif (case_70_ == "empty") then
      return nil
    else
      return nil
    end
  end
  cons_iter = _69_
  local function every_3f(pred, coll)
    local case_80_ = seq(coll)
    if (nil ~= case_80_) then
      local s = case_80_
      if pred(first(s)) then
        local case_81_ = next(s)
        if (nil ~= case_81_) then
          local r = case_81_
          return every_3f(pred, r)
        else
          local _ = case_81_
          return true
        end
      else
        return false
      end
    else
      local _ = case_80_
      return false
    end
  end
  local function some_3f(pred, coll)
    local case_85_ = seq(coll)
    if (nil ~= case_85_) then
      local s = case_85_
      local or_86_ = pred(first(s))
      if not or_86_ then
        local case_87_ = next(s)
        if (nil ~= case_87_) then
          local r = case_87_
          or_86_ = some_3f(pred, r)
        else
          local _ = case_87_
          or_86_ = nil
        end
      end
      return or_86_
    else
      local _ = case_85_
      return nil
    end
  end
  local function pack(s)
    local res = {}
    local n = 0
    do
      local case_93_ = seq(s)
      if (nil ~= case_93_) then
        local s_2a = case_93_
        for _, v in pairs_2a(s_2a) do
          n = (n + 1)
          res[n] = v
        end
      else
      end
    end
    res["n"] = n
    return res
  end
  local function count(s)
    local case_95_ = seq(s)
    if (nil ~= case_95_) then
      local s_2a = case_95_
      return length_2a(s_2a)
    else
      local _ = case_95_
      return 0
    end
  end
  local function unpack(s)
    local t = pack(s)
    return table_unpack(t, 1, t.n)
  end
  local function concat(...)
    local case_97_ = select("#", ...)
    if (case_97_ == 0) then
      return empty_cons
    elseif (case_97_ == 1) then
      local x = ...
      local function _98_()
        return x
      end
      return lazy_seq_2a(_98_)
    elseif (case_97_ == 2) then
      local x, y = ...
      local function _99_()
        local case_100_ = seq(x)
        if (nil ~= case_100_) then
          local s = case_100_
          return cons(first(s), concat(rest(s), y))
        elseif (case_100_ == nil) then
          return y
        else
          return nil
        end
      end
      return lazy_seq_2a(_99_)
    else
      local _ = case_97_
      local pv_102_, pv_103_ = ...
      return concat(concat(pv_102_, pv_103_), select(3, ...))
    end
  end
  local function reverse(s)
    local function helper(s0, res)
      local case_105_ = seq(s0)
      if (nil ~= case_105_) then
        local s_2a = case_105_
        return helper(rest(s_2a), cons(first(s_2a), res))
      else
        local _ = case_105_
        return res
      end
    end
    return helper(s, empty_cons)
  end
  local function map(f, ...)
    local case_107_ = select("#", ...)
    if (case_107_ == 0) then
      return nil
    elseif (case_107_ == 1) then
      local col = ...
      local function _108_()
        local case_109_ = seq(col)
        if (nil ~= case_109_) then
          local x = case_109_
          return cons(f(first(x)), map(f, seq(rest(x))))
        else
          local _ = case_109_
          return nil
        end
      end
      return lazy_seq_2a(_108_)
    elseif (case_107_ == 2) then
      local s1, s2 = ...
      local function _111_()
        local s10 = seq(s1)
        local s20 = seq(s2)
        if (s10 and s20) then
          return cons(f(first(s10), first(s20)), map(f, rest(s10), rest(s20)))
        else
          return nil
        end
      end
      return lazy_seq_2a(_111_)
    elseif (case_107_ == 3) then
      local s1, s2, s3 = ...
      local function _113_()
        local s10 = seq(s1)
        local s20 = seq(s2)
        local s30 = seq(s3)
        if (s10 and s20 and s30) then
          return cons(f(first(s10), first(s20), first(s30)), map(f, rest(s10), rest(s20), rest(s30)))
        else
          return nil
        end
      end
      return lazy_seq_2a(_113_)
    else
      local _ = case_107_
      local s = list(...)
      local function _115_()
        local function _116_(_2410)
          return (nil ~= seq(_2410))
        end
        if every_3f(_116_, s) then
          return cons(f(unpack(map(first, s))), map(f, unpack(map(rest, s))))
        else
          return nil
        end
      end
      return lazy_seq_2a(_115_)
    end
  end
  local function map_indexed(f, coll)
    local mapi
    local function mapi0(idx, coll0)
      local function _119_()
        local case_120_ = seq(coll0)
        if (nil ~= case_120_) then
          local s = case_120_
          return cons(f(idx, first(s)), mapi0((idx + 1), rest(s)))
        else
          local _ = case_120_
          return nil
        end
      end
      return lazy_seq_2a(_119_)
    end
    mapi = mapi0
    return mapi(1, coll)
  end
  local function mapcat(f, ...)
    local step
    local function step0(colls)
      local function _122_()
        local case_123_ = seq(colls)
        if (nil ~= case_123_) then
          local s = case_123_
          local c = first(s)
          return concat(c, step0(rest(colls)))
        else
          local _ = case_123_
          return nil
        end
      end
      return lazy_seq_2a(_122_)
    end
    step = step0
    return step(map(f, ...))
  end
  local function take(n, coll)
    local function _125_()
      if (n > 0) then
        local case_126_ = seq(coll)
        if (nil ~= case_126_) then
          local s = case_126_
          return cons(first(s), take((n - 1), rest(s)))
        else
          local _ = case_126_
          return nil
        end
      else
        return nil
      end
    end
    return lazy_seq_2a(_125_)
  end
  local function take_while(pred, coll)
    local function _129_()
      local case_130_ = seq(coll)
      if (nil ~= case_130_) then
        local s = case_130_
        local v = first(s)
        if pred(v) then
          return cons(v, take_while(pred, rest(s)))
        else
          return nil
        end
      else
        local _ = case_130_
        return nil
      end
    end
    return lazy_seq_2a(_129_)
  end
  local function _133_(n, coll)
    local step
    local function step0(n0, coll0)
      local s = seq(coll0)
      if ((n0 > 0) and s) then
        return step0((n0 - 1), rest(s))
      else
        return s
      end
    end
    step = step0
    local function _135_()
      return step(n, coll)
    end
    return lazy_seq_2a(_135_)
  end
  drop = _133_
  local function drop_while(pred, coll)
    local step
    local function step0(pred0, coll0)
      local s = seq(coll0)
      if (s and pred0(first(s))) then
        return step0(pred0, rest(s))
      else
        return s
      end
    end
    step = step0
    local function _137_()
      return step(pred, coll)
    end
    return lazy_seq_2a(_137_)
  end
  local function drop_last(...)
    local case_138_ = select("#", ...)
    if (case_138_ == 0) then
      return empty_cons
    elseif (case_138_ == 1) then
      return drop_last(1, ...)
    else
      local _ = case_138_
      local n, coll = ...
      local function _139_(x)
        return x
      end
      return map(_139_, coll, drop(n, coll))
    end
  end
  local function take_last(n, coll)
    local function loop(s, lead)
      if lead then
        return loop(next(s), next(lead))
      else
        return s
      end
    end
    return loop(seq(coll), seq(drop(n, coll)))
  end
  local function take_nth(n, coll)
    local function _142_()
      local case_143_ = seq(coll)
      if (nil ~= case_143_) then
        local s = case_143_
        return cons(first(s), take_nth(n, drop(n, s)))
      else
        return nil
      end
    end
    return lazy_seq_2a(_142_)
  end
  local function split_at(n, coll)
    return {take(n, coll), drop(n, coll)}
  end
  local function split_with(pred, coll)
    return {take_while(pred, coll), drop_while(pred, coll)}
  end
  local function filter(pred, coll)
    local function _145_()
      local case_146_ = seq(coll)
      if (nil ~= case_146_) then
        local s = case_146_
        local x = first(s)
        local r = rest(s)
        if pred(x) then
          return cons(x, filter(pred, r))
        else
          return filter(pred, r)
        end
      else
        local _ = case_146_
        return nil
      end
    end
    return lazy_seq_2a(_145_)
  end
  local function keep(f, coll)
    local function _149_()
      local case_150_ = seq(coll)
      if (nil ~= case_150_) then
        local s = case_150_
        local case_151_ = f(first(s))
        if (nil ~= case_151_) then
          local x = case_151_
          return cons(x, keep(f, rest(s)))
        elseif (case_151_ == nil) then
          return keep(f, rest(s))
        else
          return nil
        end
      else
        local _ = case_150_
        return nil
      end
    end
    return lazy_seq_2a(_149_)
  end
  local function keep_indexed(f, coll)
    local keepi
    local function keepi0(idx, coll0)
      local function _154_()
        local case_155_ = seq(coll0)
        if (nil ~= case_155_) then
          local s = case_155_
          local x = f(idx, first(s))
          if (nil == x) then
            return keepi0((1 + idx), rest(s))
          else
            return cons(x, keepi0((1 + idx), rest(s)))
          end
        else
          return nil
        end
      end
      return lazy_seq_2a(_154_)
    end
    keepi = keepi0
    return keepi(1, coll)
  end
  local function remove(pred, coll)
    local function _158_(_241)
      return not pred(_241)
    end
    return filter(_158_, coll)
  end
  local function cycle(coll)
    local function _159_()
      return concat(seq(coll), cycle(coll))
    end
    return lazy_seq_2a(_159_)
  end
  local function _repeat(x)
    local function step(x0)
      local function _160_()
        return cons(x0, step(x0))
      end
      return lazy_seq_2a(_160_)
    end
    return step(x)
  end
  local function repeatedly(f, ...)
    local args = table_pack(...)
    local f0
    local function _161_()
      return f(table_unpack(args, 1, args.n))
    end
    f0 = _161_
    local function step(f1)
      local function _162_()
        return cons(f1(), step(f1))
      end
      return lazy_seq_2a(_162_)
    end
    return step(f0)
  end
  local function iterate(f, x)
    local x_2a = f(x)
    local function _163_()
      return iterate(f, x_2a)
    end
    return cons(x, lazy_seq_2a(_163_))
  end
  local function nthnext(coll, n)
    local function loop(n0, xs)
      local and_164_ = (nil ~= xs)
      if and_164_ then
        local xs_2a = xs
        and_164_ = (n0 > 0)
      end
      if and_164_ then
        local xs_2a = xs
        return loop((n0 - 1), next(xs_2a))
      else
        local _ = xs
        return xs
      end
    end
    return loop(n, seq(coll))
  end
  local function nthrest(coll, n)
    local function loop(n0, xs)
      local case_167_ = seq(xs)
      local and_168_ = (nil ~= case_167_)
      if and_168_ then
        local xs_2a = case_167_
        and_168_ = (n0 > 0)
      end
      if and_168_ then
        local xs_2a = case_167_
        return loop((n0 - 1), rest(xs_2a))
      else
        local _ = case_167_
        return xs
      end
    end
    return loop(n, coll)
  end
  local function dorun(s)
    local case_171_ = seq(s)
    if (nil ~= case_171_) then
      local s_2a = case_171_
      return dorun(next(s_2a))
    else
      local _ = case_171_
      return nil
    end
  end
  local function doall(s)
    dorun(s)
    return s
  end
  local function partition(...)
    local case_173_ = select("#", ...)
    if (case_173_ == 2) then
      local n, coll = ...
      return partition(n, n, coll)
    elseif (case_173_ == 3) then
      local n, step, coll = ...
      local function _174_()
        local case_175_ = seq(coll)
        if (nil ~= case_175_) then
          local s = case_175_
          local p = take(n, s)
          if (n == length_2a(p)) then
            return cons(p, partition(n, step, nthrest(s, step)))
          else
            return nil
          end
        else
          local _ = case_175_
          return nil
        end
      end
      return lazy_seq_2a(_174_)
    elseif (case_173_ == 4) then
      local n, step, pad, coll = ...
      local function _178_()
        local case_179_ = seq(coll)
        if (nil ~= case_179_) then
          local s = case_179_
          local p = take(n, s)
          if (n == length_2a(p)) then
            return cons(p, partition(n, step, pad, nthrest(s, step)))
          else
            return list(take(n, concat(p, pad)))
          end
        else
          local _ = case_179_
          return nil
        end
      end
      return lazy_seq_2a(_178_)
    else
      local _ = case_173_
      return error("wrong amount arguments to 'partition'")
    end
  end
  local function partition_by(f, coll)
    local function _183_()
      local case_184_ = seq(coll)
      if (nil ~= case_184_) then
        local s = case_184_
        local v = first(s)
        local fv = f(v)
        local run
        local function _185_(_2410)
          return (fv == f(_2410))
        end
        run = cons(v, take_while(_185_, next(s)))
        local function _186_()
          return drop(length_2a(run), s)
        end
        return cons(run, partition_by(f, lazy_seq_2a(_186_)))
      else
        return nil
      end
    end
    return lazy_seq_2a(_183_)
  end
  local function partition_all(...)
    local case_188_ = select("#", ...)
    if (case_188_ == 2) then
      local n, coll = ...
      return partition_all(n, n, coll)
    elseif (case_188_ == 3) then
      local n, step, coll = ...
      local function _189_()
        local case_190_ = seq(coll)
        if (nil ~= case_190_) then
          local s = case_190_
          local p = take(n, s)
          return cons(p, partition_all(n, step, nthrest(s, step)))
        else
          local _ = case_190_
          return nil
        end
      end
      return lazy_seq_2a(_189_)
    else
      local _ = case_188_
      return error("wrong amount arguments to 'partition-all'")
    end
  end
  local function reductions(...)
    local case_193_ = select("#", ...)
    if (case_193_ == 2) then
      local f, coll = ...
      local function _194_()
        local case_195_ = seq(coll)
        if (nil ~= case_195_) then
          local s = case_195_
          return reductions(f, first(s), rest(s))
        else
          local _ = case_195_
          return list(f())
        end
      end
      return lazy_seq_2a(_194_)
    elseif (case_193_ == 3) then
      local f, init, coll = ...
      local function _197_()
        local case_198_ = seq(coll)
        if (nil ~= case_198_) then
          local s = case_198_
          return reductions(f, f(init, first(s)), rest(s))
        else
          return nil
        end
      end
      return cons(init, lazy_seq_2a(_197_))
    else
      local _ = case_193_
      return error("wrong amount arguments to 'reductions'")
    end
  end
  local function contains_3f(coll, elt)
    local case_201_ = gettype(coll)
    if (case_201_ == "table") then
      local case_202_ = kind(coll)
      if (case_202_ == "seq") then
        local res = false
        for _, v in ipairs_2a(coll) do
          if res then break end
          if (elt == v) then
            res = true
          else
            res = false
          end
        end
        return res
      elseif (case_202_ == "assoc") then
        if coll[elt] then
          return true
        else
          return false
        end
      else
        return nil
      end
    else
      local _ = case_201_
      local function loop(coll0)
        local case_206_ = seq(coll0)
        if (nil ~= case_206_) then
          local s = case_206_
          if (elt == first(s)) then
            return true
          else
            return loop(rest(s))
          end
        elseif (case_206_ == nil) then
          return false
        else
          return nil
        end
      end
      return loop(coll)
    end
  end
  local function distinct(coll)
    local function step(xs, seen)
      local loop
      local function loop0(_210_, seen0)
        local f = _210_[1]
        local xs0 = _210_
        local case_211_ = seq(xs0)
        if (nil ~= case_211_) then
          local s = case_211_
          if seen0[f] then
            return loop0(rest(s), seen0)
          else
            local function _212_()
              seen0[f] = true
              return seen0
            end
            return cons(f, step(rest(s), _212_()))
          end
        else
          local _ = case_211_
          return nil
        end
      end
      loop = loop0
      local function _215_()
        return loop(xs, seen)
      end
      return lazy_seq_2a(_215_)
    end
    return step(coll, {})
  end
  local function inf_range(x, step)
    local function _216_()
      return cons(x, inf_range((x + step), step))
    end
    return lazy_seq_2a(_216_)
  end
  local function fix_range(x, _end, step)
    local function _217_()
      if (((step >= 0) and (x < _end)) or ((step < 0) and (x > _end))) then
        return cons(x, fix_range((x + step), _end, step))
      elseif ((step == 0) and (x ~= _end)) then
        return cons(x, fix_range(x, _end, step))
      else
        return nil
      end
    end
    return lazy_seq_2a(_217_)
  end
  local function range(...)
    local case_219_ = select("#", ...)
    if (case_219_ == 0) then
      return inf_range(0, 1)
    elseif (case_219_ == 1) then
      local _end = ...
      return fix_range(0, _end, 1)
    elseif (case_219_ == 2) then
      local x, _end = ...
      return fix_range(x, _end, 1)
    else
      local _ = case_219_
      return fix_range(...)
    end
  end
  local function realized_3f(s)
    local case_221_ = gettype(s)
    if (case_221_ == "lazy-cons") then
      return false
    elseif (case_221_ == "empty-cons") then
      return true
    elseif (case_221_ == "cons") then
      return true
    else
      local _ = case_221_
      return error(("expected a sequence, got: %s"):format(_))
    end
  end
  local function line_seq(file)
    local next_line = file:lines()
    local function step(f)
      local line = f()
      if ("string" == type(line)) then
        local function _223_()
          return step(f)
        end
        return cons(line, lazy_seq_2a(_223_))
      else
        return nil
      end
    end
    return step(next_line)
  end
  local function tree_seq(branch_3f, children, root)
    local function walk(node)
      local function _225_()
        local function _226_()
          if branch_3f(node) then
            return mapcat(walk, children(node))
          else
            return nil
          end
        end
        return cons(node, _226_())
      end
      return lazy_seq_2a(_225_)
    end
    return walk(root)
  end
  local function interleave(...)
    local case_227_, case_228_, case_229_ = select("#", ...), ...
    if (case_227_ == 0) then
      return empty_cons
    elseif ((case_227_ == 1) and true) then
      local _3fs = case_228_
      local function _230_()
        return _3fs
      end
      return lazy_seq_2a(_230_)
    elseif ((case_227_ == 2) and true and true) then
      local _3fs1 = case_228_
      local _3fs2 = case_229_
      local function _231_()
        local s1 = seq(_3fs1)
        local s2 = seq(_3fs2)
        if (s1 and s2) then
          return cons(first(s1), cons(first(s2), interleave(rest(s1), rest(s2))))
        else
          return nil
        end
      end
      return lazy_seq_2a(_231_)
    elseif true then
      local _ = case_227_
      local cols = list(...)
      local function _233_()
        local seqs = map(seq, cols)
        local function _234_(_2410)
          return (nil ~= seq(_2410))
        end
        if every_3f(_234_, seqs) then
          return concat(map(first, seqs), interleave(unpack(map(rest, seqs))))
        else
          return nil
        end
      end
      return lazy_seq_2a(_233_)
    else
      return nil
    end
  end
  local function interpose(separator, coll)
    return drop(1, interleave(_repeat(separator), coll))
  end
  local function keys(t)
    assert(("assoc" == kind(t)), "expected an associative table")
    local function _237_(_241)
      return _241[1]
    end
    return map(_237_, t)
  end
  local function vals(t)
    assert(("assoc" == kind(t)), "expected an associative table")
    local function _238_(_241)
      return _241[2]
    end
    return map(_238_, t)
  end
  local function zipmap(keys0, vals0)
    local t = {}
    local function loop(s1, s2)
      if (s1 and s2) then
        t[first(s1)] = first(s2)
        return loop(next(s1), next(s2))
      else
        return nil
      end
    end
    loop(seq(keys0), seq(vals0))
    return t
  end
  local _local_240_ = require("io.gitlab.andreyorst.reduced")
  local reduced = _local_240_.reduced
  local reduced_3f = _local_240_["reduced?"]
  local function reduce(f, ...)
    local case_241_, case_242_, case_243_ = select("#", ...), ...
    if (case_241_ == 0) then
      return error("expected a collection")
    elseif ((case_241_ == 1) and true) then
      local _3fcoll = case_242_
      local case_244_ = count(_3fcoll)
      if (case_244_ == 0) then
        return f()
      elseif (case_244_ == 1) then
        return first(_3fcoll)
      else
        local _ = case_244_
        return reduce(f, first(_3fcoll), rest(_3fcoll))
      end
    elseif ((case_241_ == 2) and true and true) then
      local _3fval = case_242_
      local _3fcoll = case_243_
      local case_246_ = seq(_3fcoll)
      if (nil ~= case_246_) then
        local coll = case_246_
        local done_3f = false
        local res = _3fval
        for _, v in pairs_2a(coll) do
          if done_3f then break end
          local res0 = f(res, v)
          if reduced_3f(res0) then
            done_3f = true
            res = res0:unbox()
          else
            res = res0
          end
        end
        return res
      else
        local _ = case_246_
        return _3fval
      end
    else
      return nil
    end
  end
  return {first = first, rest = rest, nthrest = nthrest, next = next, nthnext = nthnext, cons = cons, seq = seq, rseq = rseq, ["seq?"] = seq_3f, ["empty?"] = empty_3f, ["lazy-seq*"] = lazy_seq_2a, list = list, ["list*"] = list_2a, ["every?"] = every_3f, ["some?"] = some_3f, pack = pack, unpack = unpack, count = count, concat = concat, map = map, ["map-indexed"] = map_indexed, mapcat = mapcat, take = take, ["take-while"] = take_while, ["take-last"] = take_last, ["take-nth"] = take_nth, drop = drop, ["drop-while"] = drop_while, ["drop-last"] = drop_last, remove = remove, ["split-at"] = split_at, ["split-with"] = split_with, partition = partition, ["partition-by"] = partition_by, ["partition-all"] = partition_all, filter = filter, keep = keep, ["keep-indexed"] = keep_indexed, ["contains?"] = contains_3f, distinct = distinct, cycle = cycle, ["repeat"] = _repeat, repeatedly = repeatedly, reductions = reductions, iterate = iterate, range = range, ["realized?"] = realized_3f, dorun = dorun, doall = doall, ["line-seq"] = line_seq, ["tree-seq"] = tree_seq, reverse = reverse, interleave = interleave, interpose = interpose, keys = keys, vals = vals, zipmap = zipmap, reduce = reduce, reduced = reduced, ["reduced?"] = reduced_3f, __VERSION = "0.1.127"}
end
package.preload["io.gitlab.andreyorst.reduced"] = package.preload["io.gitlab.andreyorst.reduced"] or function(...)
  --[[ MIT License
  
    Copyright (c) 2023 Andrey Listopadov
  
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the “Software”), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
  
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
  
    THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE. ]]
  
  local lib_include_path = ...
  
  if lib_include_path ~= "io.gitlab.andreyorst.reduced" then
    local msg = [[Invalid usage of the Reduced library: required as "%s" not as "io.gitlab.andreyorst.reduced".
  
  The Reduced library must be required by callind require with the string "io.gitlab.andreyorst.reduced" as the argument.
  This ensures that all of the code across all libraries uses the same entry from package.loaded.]]
    error(msg:format(lib_include_path))
  end
  
  local Reduced = {
    __index = {unbox = function (x) return x[1] end},
    __fennelview = function (x, view, options, indent)
      return "#<reduced: " .. view(x[1], options, (11 + indent)) .. ">"
    end,
    __name = "reduced",
    __tostring = function (x) return ("reduced: " .. tostring(x[1])) end
  }
  
  local function reduced(value) return setmetatable({value}, Reduced) end
  local function is_reduced(value) return rawequal(getmetatable(value), Reduced) end
  
  return {reduced = reduced, ["reduced?"] = is_reduced, is_reduced = is_reduced}
end
package.preload["io.gitlab.andreyorst.itable"] = package.preload["io.gitlab.andreyorst.itable"] or function(...)
  local t_2fsort = table.sort
  local t_2fconcat = table.concat
  local t_2fremove = table.remove
  local t_2fmove = table.move
  local t_2finsert = table.insert
  local itable = {__VERSION = "0.1.31"}
  local t_2funpack = (table.unpack or _G.unpack)
  local pairs_2a
  itable.pairs = function(t)
    local _251_
    do
      local case_250_ = getmetatable(t)
      if ((_G.type(case_250_) == "table") and (nil ~= case_250_.__pairs)) then
        local p = case_250_.__pairs
        _251_ = p
      else
        local _ = case_250_
        _251_ = pairs
      end
    end
    return _251_(t)
  end
  pairs_2a = itable.pairs
  local ipairs_2a
  itable.ipairs = function(t)
    local _256_
    do
      local case_255_ = getmetatable(t)
      if ((_G.type(case_255_) == "table") and (nil ~= case_255_.__ipairs)) then
        local i = case_255_.__ipairs
        _256_ = i
      else
        local _ = case_255_
        _256_ = ipairs
      end
    end
    return _256_(t)
  end
  ipairs_2a = itable.ipairs
  local length_2a
  itable.length = function(t)
    local _261_
    do
      local case_260_ = getmetatable(t)
      if ((_G.type(case_260_) == "table") and (nil ~= case_260_.__len)) then
        local l = case_260_.__len
        _261_ = l
      else
        local _ = case_260_
        local function _264_(...)
          return #...
        end
        _261_ = _264_
      end
    end
    return _261_(t)
  end
  length_2a = itable.length
  local function copy(t)
    if t then
      local tbl_21_ = {}
      for k, v in pairs_2a(t) do
        local k_22_, v_23_ = k, v
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
      return tbl_21_
    else
      return nil
    end
  end
  local function eq(...)
    local case_268_, case_269_, case_270_ = select("#", ...), ...
    if ((case_268_ == 0) or (case_268_ == 1)) then
      return true
    elseif ((case_268_ == 2) and true and true) then
      local _3fa = case_269_
      local _3fb = case_270_
      if (_3fa == _3fb) then
        return true
      else
        local _271_ = type(_3fb)
        if ((type(_3fa) == _271_) and (_271_ == "table")) then
          local res, count_a, count_b = true, 0, 0
          for k, v in pairs_2a(_3fa) do
            if not res then break end
            local function _272_(...)
              local res0 = nil
              for k_2a, v0 in pairs_2a(_3fb) do
                if res0 then break end
                if eq(k_2a, k) then
                  res0 = v0
                else
                end
              end
              return res0
            end
            res = eq(v, _272_(...))
            count_a = (count_a + 1)
          end
          if res then
            for _, _0 in pairs_2a(_3fb) do
              count_b = (count_b + 1)
            end
            res = (count_a == count_b)
          else
          end
          return res
        else
          return false
        end
      end
    elseif (true and true and true) then
      local _ = case_268_
      local _3fa = case_269_
      local _3fb = case_270_
      return (eq(_3fa, _3fb) and eq(select(2, ...)))
    else
      return nil
    end
  end
  itable.eq = eq
  local function deep_index(tbl, key)
    local res = nil
    for k, v in pairs_2a(tbl) do
      if res then break end
      if eq(k, key) then
        res = v
      else
        res = nil
      end
    end
    return res
  end
  local function deep_newindex(tbl, key, val)
    local done = false
    if ("table" == type(key)) then
      for k, _ in pairs_2a(tbl) do
        if done then break end
        if eq(k, key) then
          rawset(tbl, k, val)
          done = true
        else
        end
      end
    else
    end
    if not done then
      return rawset(tbl, key, val)
    else
      return nil
    end
  end
  local function immutable(t, opts)
    local t0
    if (opts and opts["fast-index?"]) then
      t0 = t
    else
      t0 = setmetatable(t, {__index = deep_index, __newindex = deep_newindex})
    end
    local len = length_2a(t0)
    local proxy = {}
    local __len
    local function _282_()
      return len
    end
    __len = _282_
    local __index
    local function _283_(_241, _242)
      return t0[_242]
    end
    __index = _283_
    local __newindex
    local function _284_()
      return error((tostring(proxy) .. " is immutable"), 2)
    end
    __newindex = _284_
    local __pairs
    local function _285_()
      local function _286_(_, k)
        return next(t0, k)
      end
      return _286_, nil, nil
    end
    __pairs = _285_
    local __ipairs
    local function _287_()
      local function _288_(_, k)
        return next(t0, k)
      end
      return _288_
    end
    __ipairs = _287_
    local __call
    local function _289_(_241, _242)
      return t0[_242]
    end
    __call = _289_
    local __fennelview
    local function _290_(_241, _242, _243, _244)
      return _242(t0, _243, _244)
    end
    __fennelview = _290_
    local __fennelrest
    local function _291_(_241, _242)
      return immutable({t_2funpack(t0, _242)})
    end
    __fennelrest = _291_
    return setmetatable(proxy, {__index = __index, __newindex = __newindex, __len = __len, __pairs = __pairs, __ipairs = __ipairs, __call = __call, __metatable = {__len = __len, __pairs = __pairs, __ipairs = __ipairs, __call = __call, __fennelrest = __fennelrest, __fennelview = __fennelview, __index = itable}})
  end
  itable.immutable = immutable
  itable.insert = function(t, ...)
    local t0 = copy(t)
    do
      local case_292_, case_293_, case_294_ = select("#", ...), ...
      if (case_292_ == 0) then
        error("wrong number of arguments to 'insert'")
      elseif ((case_292_ == 1) and true) then
        local _3fv = case_293_
        t_2finsert(t0, _3fv)
      elseif (true and true and true) then
        local _ = case_292_
        local _3fk = case_293_
        local _3fv = case_294_
        t_2finsert(t0, _3fk, _3fv)
      else
      end
    end
    return immutable(t0)
  end
  if t_2fmove then
    local function _296_(src, start, _end, tgt, dest)
      local src0 = copy(src)
      local dest0 = copy(dest)
      return immutable(t_2fmove(src0, start, _end, tgt, dest0))
    end
    itable.move = _296_
  else
    itable.move = nil
  end
  itable.pack = function(...)
    local function _298_(...)
      local tmp_9_ = {...}
      tmp_9_["n"] = select("#", ...)
      return tmp_9_
    end
    return immutable(_298_(...))
  end
  local function remove(t, key)
    local t0 = copy(t)
    local v = t_2fremove(t0, key)
    return immutable(t0), v
  end
  itable.remove = remove
  itable.concat = function(t, sep, start, _end, serializer, opts)
    local serializer0 = (serializer or tostring)
    local _299_
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for _, v in ipairs_2a(t) do
        local val_28_ = serializer0(v, opts)
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      _299_ = tbl_26_
    end
    return t_2fconcat(_299_, sep, start, _end)
  end
  itable.unpack = function(t, ...)
    return t_2funpack(copy(t), ...)
  end
  local function assoc(t, key, val, ...)
    local len = select("#", ...)
    if (0 ~= (len % 2)) then
      error(("no value supplied for key " .. tostring(select(len, ...))), 2)
    else
    end
    local t0
    do
      local tmp_9_ = copy(t)
      tmp_9_[key] = val
      t0 = tmp_9_
    end
    for i = 1, len, 2 do
      local k, v = select(i, ...)
      t0[k] = v
    end
    return immutable(t0)
  end
  itable.assoc = assoc
  local function assoc_in(t, _302_, val)
    local k = _302_[1]
    local ks = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_302_, 2)
    local t0 = (t or {})
    print(ks)
    if next(ks) then
      return assoc(t0, k, assoc_in((t0[k] or {}), ks, val))
    else
      return assoc(t0, k, val)
    end
  end
  itable["assoc-in"] = assoc_in
  local function update(t, key, f)
    local function _304_()
      local tmp_9_ = copy(t)
      tmp_9_[key] = f(t[key])
      return tmp_9_
    end
    return immutable(_304_())
  end
  itable.update = update
  local function update_in(t, _305_, f)
    local k = _305_[1]
    local ks = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_305_, 2)
    local t0 = (t or {})
    if next(ks) then
      return assoc(t0, k, update_in(t0[k], ks, f))
    else
      return update(t0, k, f)
    end
  end
  itable["update-in"] = update_in
  itable.deepcopy = function(x)
    local function deepcopy_2a(x0, seen)
      local case_307_ = type(x0)
      if (case_307_ == "table") then
        local case_308_ = seen[x0]
        if (case_308_ == true) then
          return error("immutable tables can't contain self reference", 2)
        else
          local _ = case_308_
          seen[x0] = true
          local function _309_()
            local tbl_21_ = {}
            for k, v in pairs_2a(x0) do
              local k_22_, v_23_ = deepcopy_2a(k, seen), deepcopy_2a(v, seen)
              if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
                tbl_21_[k_22_] = v_23_
              else
              end
            end
            return tbl_21_
          end
          return immutable(_309_())
        end
      else
        local _ = case_307_
        return x0
      end
    end
    return deepcopy_2a(x, {})
  end
  itable.first = function(_313_)
    local x = _313_[1]
    return x
  end
  itable.rest = function(t)
    return (remove(t, 1))
  end
  local function nthrest(t, n)
    local t_2a = {}
    for i = (n + 1), length_2a(t) do
      t_2finsert(t_2a, t[i])
    end
    return immutable(t_2a)
  end
  itable.nthrest = nthrest
  itable.last = function(t)
    return t[length_2a(t)]
  end
  itable.butlast = function(t)
    return (remove(t, length_2a(t)))
  end
  local function join(...)
    local case_314_, case_315_, case_316_ = select("#", ...), ...
    if (case_314_ == 0) then
      return nil
    elseif ((case_314_ == 1) and true) then
      local _3ft = case_315_
      return immutable(copy(_3ft))
    elseif ((case_314_ == 2) and true and true) then
      local _3ft1 = case_315_
      local _3ft2 = case_316_
      local to = copy(_3ft1)
      local from = (_3ft2 or {})
      for _, v in ipairs_2a(from) do
        t_2finsert(to, v)
      end
      return immutable(to)
    elseif (true and true and true) then
      local _ = case_314_
      local _3ft1 = case_315_
      local _3ft2 = case_316_
      return join(join(_3ft1, _3ft2), select(3, ...))
    else
      return nil
    end
  end
  itable.join = join
  local function take(n, t)
    local t_2a = {}
    for i = 1, n do
      t_2finsert(t_2a, t[i])
    end
    return immutable(t_2a)
  end
  itable.take = take
  itable.drop = function(n, t)
    return nthrest(t, n)
  end
  itable.partition = function(...)
    local res = {}
    local function partition_2a(...)
      local case_318_, case_319_, case_320_, case_321_, case_322_ = select("#", ...), ...
      if ((case_318_ == 0) or (case_318_ == 1)) then
        return error("wrong amount arguments to 'partition'")
      elseif ((case_318_ == 2) and true and true) then
        local _3fn = case_319_
        local _3ft = case_320_
        return partition_2a(_3fn, _3fn, _3ft)
      elseif ((case_318_ == 3) and true and true and true) then
        local _3fn = case_319_
        local _3fstep = case_320_
        local _3ft = case_321_
        local p = take(_3fn, _3ft)
        if (_3fn == length_2a(p)) then
          t_2finsert(res, p)
          return partition_2a(_3fn, _3fstep, {t_2funpack(_3ft, (_3fstep + 1))})
        else
          return nil
        end
      elseif (true and true and true and true and true) then
        local _ = case_318_
        local _3fn = case_319_
        local _3fstep = case_320_
        local _3fpad = case_321_
        local _3ft = case_322_
        local p = take(_3fn, _3ft)
        if (_3fn == length_2a(p)) then
          t_2finsert(res, p)
          return partition_2a(_3fn, _3fstep, _3fpad, {t_2funpack(_3ft, (_3fstep + 1))})
        else
          return t_2finsert(res, take(_3fn, join(p, _3fpad)))
        end
      else
        return nil
      end
    end
    partition_2a(...)
    return immutable(res)
  end
  itable.keys = function(t)
    local function _326_()
      local tbl_26_ = {}
      local i_27_ = 0
      for k, _ in pairs_2a(t) do
        local val_28_ = k
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      return tbl_26_
    end
    return immutable(_326_())
  end
  itable.vals = function(t)
    local function _328_()
      local tbl_26_ = {}
      local i_27_ = 0
      for _, v in pairs_2a(t) do
        local val_28_ = v
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      return tbl_26_
    end
    return immutable(_328_())
  end
  itable["group-by"] = function(f, t)
    local res = {}
    local ungroupped = {}
    for _, v in pairs_2a(t) do
      local k = f(v)
      if (nil ~= k) then
        local case_330_ = res[k]
        if (nil ~= case_330_) then
          local t_2a = case_330_
          t_2finsert(t_2a, v)
        else
          local _0 = case_330_
          res[k] = {v}
        end
      else
        t_2finsert(ungroupped, v)
      end
    end
    local function _333_()
      local tbl_21_ = {}
      for k, t0 in pairs_2a(res) do
        local k_22_, v_23_ = k, immutable(t0)
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
      return tbl_21_
    end
    return immutable(_333_()), immutable(ungroupped)
  end
  itable.frequencies = function(t)
    local res = setmetatable({}, {__index = deep_index, __newindex = deep_newindex})
    for _, v in pairs_2a(t) do
      local case_335_ = res[v]
      if (nil ~= case_335_) then
        local a = case_335_
        res[v] = (a + 1)
      else
        local _0 = case_335_
        res[v] = 1
      end
    end
    return immutable(res)
  end
  itable.sort = function(t, f)
    local function _337_()
      local tmp_9_ = copy(t)
      t_2fsort(tmp_9_, f)
      return tmp_9_
    end
    return immutable(_337_())
  end
  itable["immutable?"] = function(t)
    local case_338_ = getmetatable(t)
    if ((_G.type(case_338_) == "table") and (case_338_.__index == itable)) then
      return true
    else
      local _ = case_338_
      return false
    end
  end
  local function _340_(_, t, opts)
    local case_341_ = getmetatable(t)
    if ((_G.type(case_341_) == "table") and (case_341_.__index == itable)) then
      return t
    else
      local _0 = case_341_
      return immutable(copy(t), opts)
    end
  end
  return setmetatable(itable, {__call = _340_})
end
package.preload["io.gitlab.andreyorst.inst"] = package.preload["io.gitlab.andreyorst.inst"] or function(...)
  --[[ MIT License
  
  Copyright (c) 2021 Andrey Listopadov
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE. ]]
  
  local date, time = os.date, os.time
  
  local full_date_formats = {
      "(%-?%d%d%d%d)%-(1[012])%-([012]%d)",
      "(%-?%d%d%d%d)%-(1[012])%-(3[01])",
      "(%-?%d%d%d%d)%-(0%d)%-([012]%d)",
      "(%-?%d%d%d%d)%-(0%d)%-(3[01])",
      "(%-?%d%d%d%d)(1[012])([012]%d)",
      "(%-?%d%d%d%d)(1[012])(3[01])",
      "(%-?%d%d%d%d)(0%d)([012]%d)",
      "(%-?%d%d%d%d)(0%d)(3[01])",
  }
  
  local partial_date_formats = {
      "(%-?%d%d%d%d)%-(1[012])",
      "(%-?%d%d%d%d)%-(0%d)",
      "(%-?%d%d%d%d)(1[012])",
      "(%-?%d%d%d%d)(0%d)",
      "(%-?%d%d%d%d)",
  }
  
  local time_formats = {
      "([01]%d):([0-5]%d):([0-5]%d)%.(%d+)",
      "([2][0-4]):([0-5]%d):([0-5]%d)%.(%d+)",
      "([01]%d):([0-5]%d):(60)%.(%d+)",
      "([2][0-4]):([0-5]%d):(60)%.(%d+)",
      "([01]%d):([0-5]%d):([0-5]%d)",
      "([2][0-4]):([0-5]%d):([0-5]%d)",
      "([01]%d):([0-5]%d):(60)",
      "([2][0-4]):([0-5]%d):(60)",
  }
  
  local offset_formats = {
      "([+-])([01]%d):([0-5]%d)",
      "([+-])([2][0-4]):([0-5]%d)",
      "([+-])([01]%d)([0-5]%d)",
      "([+-])([2][0-4])([0-5]%d)",
      "([+-])([01]%d)",
      "([+-])([2][0-4])",
      "Z"
  }
  
  local months_w_thirty_one_days = {
      [1] = true,
      [3] = true,
      [5] = true,
      [7] = true,
      [8] = true,
      [10] = true,
      [12] = true
  }
  
  -- compiling all possible ISO8601 patterns
  local iso8601_formats = {}
  for _,date_fmt in ipairs(full_date_formats) do
      for _,time_fmt in ipairs(time_formats) do
          for _,offset_fmt in ipairs(offset_formats) do
              iso8601_formats[#iso8601_formats+1] = "^"..date_fmt.."T"..time_fmt..offset_fmt.."$"
  end end end
  
  local function is_leap_year(year)
      return 0 == year % 4 and (0 ~= year % 100 or 0 == year % 400)
  end
  
  local function parse_date_time (date_time_str)
      local year, mon, day, hh, mm, ss, ms, sign, off_h, off_m
  
      -- trying to parse a complete ISO8601 date
      for _,fmt in pairs(iso8601_formats) do
          year, mon, day, hh, mm, ss, ms, sign, off_h, off_m = date_time_str:match(fmt)
          if year then break end
      end
  
      -- milliseconds are optional, so offset may be stored in ms
      if not off_m and ms and ms:match("^[+-]") then
          off_m, off_h, sign, ms = off_h, sign, ms, 0
      end
  
      sign, off_h, off_m = sign or "+", off_h or 0, off_m or 0
  
      return year, mon, day, hh, mm, ss, ms, sign, off_h, off_m
  end
  
  local function parse_date (date_str)
      local year, mon, day
      for _,fmt in pairs(full_date_formats) do
          year, mon, day = date_str:match("^"..fmt.."$")
          if year ~= nil then break end
      end
      if not year then
          for _,fmt in pairs(partial_date_formats) do
              year, mon, day = date_str:match("^"..fmt.."$")
              if year ~= nil then break end
      end end
      return year, mon, day
  end
  
  local function parse_iso8601 (date_str)
      local year, mon, day, hh, mm, ss, ms, sign, off_h, off_m = parse_date_time(date_str)
  
      if not year then
          -- trying to parse only a year with optional month and day
          year, mon, day = parse_date(date_str)
      end
  
      if not year then
          error(("invalid date '%s': date string doesn't match ISO8601 pattern"):format(date_str), 2)
      end
  
      if is_leap_year(tonumber(year)) and mon and tonumber(mon) == 2 and day and tonumber(day) > 29 then
          error(("invalid date '%s': February has 29 days in leap years"):format(date_str), 2)
      elseif not is_leap_year(tonumber(year)) and mon and tonumber(mon) == 2 and day and tonumber(day) > 28 then
          error(("invalid date '%s': February has 28 days in non leap years"):format(date_str), 2)
      end
  
      if mon and day and tonumber(day) == 31 and not months_w_thirty_one_days[tonumber(mon)] then
          error(("invalid date '%s': month %d has 30 days"):format(date_str, mon), 2)
      end
  
      return { year = year,
               month = tonumber(mon) or 1,
               day = tonumber(day) or 1,
               hour = (tonumber(hh) or 0) - (tonumber(sign..off_h) or 0),
               min = (tonumber(mm) or 0) - (tonumber(sign..off_m) or 0),
               sec = tonumber(ss or 0),
               msec = tonumber(ms or 0) }
  end
  
  local function inst (date_str)
      local inst = parse_iso8601(date_str)
      return setmetatable(inst, {
          __tostring = function ()
              return ("#inst \"%04d-%s.%03d-00:00\""):format(inst.year, date("%m-%dT%H:%M:%S", time(inst)), inst.msec)
          end,
          __len = function (inst) return inst end
      })
  end
  
  return inst
end
package.preload["io.gitlab.andreyorst.async"] = package.preload["io.gitlab.andreyorst.async"] or function(...)
  --[[ "Copyright (c) 2023 Andrey Listopadov and contributors.  All rights reserved.
  The use and distribution terms for this software are covered by the Eclipse
  Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php) which
  can be found in the file LICENSE at the root of this distribution.  By using
  this software in any fashion, you are agreeing to be bound by the terms of
  this license.
  You must not remove this notice, or any other, from this software." ]]
  local lib_name = (... or "io.gitlab.andreyorst.async")
  local main_thread = (coroutine.running() or error((lib_name .. " requires Lua 5.2 or higher")))
  local or_343_ = package.preload["io.gitlab.andreyorst.reduced"]
  if not or_343_ then
    local function _344_()
      local Reduced
      local function _346_(_345_, view, options, indent)
        local x = _345_[1]
        return ("#<reduced: " .. view(x, options, (11 + indent)) .. ">")
      end
      local function _348_(_347_)
        local x = _347_[1]
        return x
      end
      local function _350_(_349_)
        local x = _349_[1]
        return ("reduced: " .. tostring(x))
      end
      Reduced = {__fennelview = _346_, __index = {unbox = _348_}, __name = "reduced", __tostring = _350_}
      local function reduced(value)
        return setmetatable({value}, Reduced)
      end
      local function reduced_3f(value)
        return rawequal(getmetatable(value), Reduced)
      end
      return {is_reduced = reduced_3f, reduced = reduced, ["reduced?"] = reduced_3f}
    end
    or_343_ = _344_
  end
  package.preload["io.gitlab.andreyorst.reduced"] = or_343_
  local _local_351_ = require("io.gitlab.andreyorst.reduced")
  local reduced = _local_351_.reduced
  local reduced_3f = _local_351_["reduced?"]
  local gethook, sethook
  do
    local case_352_ = _G.debug
    if ((_G.type(case_352_) == "table") and (nil ~= case_352_.gethook) and (nil ~= case_352_.sethook)) then
      local gethook0 = case_352_.gethook
      local sethook0 = case_352_.sethook
      gethook, sethook = gethook0, sethook0
    else
      local _ = case_352_
      io.stderr:write("WARNING: debug library is unawailable.  ", lib_name, " uses debug.sethook to advance timers.  ", "Time-related features are disabled.\n")
      gethook, sethook = nil
    end
  end
  local t_2fremove = table.remove
  local t_2fconcat = table.concat
  local t_2finsert = table.insert
  local t_2fsort = table.sort
  local t_2funpack = (_G.unpack or table.unpack)
  local c_2frunning = coroutine.running
  local c_2fresume = coroutine.resume
  local c_2fyield = coroutine.yield
  local c_2fcreate = coroutine.create
  local m_2fmin = math.min
  local m_2frandom = math.random
  local m_2fceil = math.ceil
  local m_2ffloor = math.floor
  local m_2fmodf = math.modf
  local function main_thread_3f()
    local case_354_, case_355_ = c_2frunning()
    if (case_354_ == nil) then
      return true
    elseif (true and (case_355_ == true)) then
      local _ = case_354_
      return true
    else
      local _ = case_354_
      return false
    end
  end
  local function merge_2a(t1, t2)
    local res = {}
    do
      local tbl_21_ = res
      for k, v in pairs(t1) do
        local k_22_, v_23_ = k, v
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
    end
    local tbl_21_ = res
    for k, v in pairs(t2) do
      local k_22_, v_23_ = k, v
      if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
        tbl_21_[k_22_] = v_23_
      else
      end
    end
    return tbl_21_
  end
  local function merge_with(f, t1, t2)
    local res
    do
      local tbl_21_ = {}
      for k, v in pairs(t1) do
        local k_22_, v_23_ = k, v
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
      res = tbl_21_
    end
    local tbl_21_ = res
    for k, v in pairs(t2) do
      local k_22_, v_23_
      do
        local case_360_ = res[k]
        if (nil ~= case_360_) then
          local e = case_360_
          k_22_, v_23_ = k, f(e, v)
        elseif (case_360_ == nil) then
          k_22_, v_23_ = k, v
        else
          k_22_, v_23_ = nil
        end
      end
      if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
        tbl_21_[k_22_] = v_23_
      else
      end
    end
    return tbl_21_
  end
  local function active_3f(h)
    if (nil == h) then
      _G.error("Missing argument h on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:203", 2)
    else
    end
    return h["active?"](h)
  end
  local function blockable_3f(h)
    if (nil == h) then
      _G.error("Missing argument h on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:204", 2)
    else
    end
    return h["blockable?"](h)
  end
  local function commit(h)
    if (nil == h) then
      _G.error("Missing argument h on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:205", 2)
    else
    end
    return h:commit()
  end
  local _local_366_ = {["active?"] = active_3f, ["blockable?"] = blockable_3f, commit = commit}
  local active_3f0 = _local_366_["active?"]
  local blockable_3f0 = _local_366_["blockable?"]
  local commit0 = _local_366_.commit
  local Handler = _local_366_
  local function fn_handler(f, ...)
    local blockable
    if (0 == select("#", ...)) then
      blockable = true
    else
      blockable = ...
    end
    local _368_ = {}
    do
      do
        local case_369_ = Handler["active?"]
        if (nil ~= case_369_) then
          local f_3_auto = case_369_
          local function _370_(_)
            return true
          end
          _368_["active?"] = _370_
        else
          local _ = case_369_
          error("Protocol Handler doesn't define method active?")
        end
      end
      do
        local case_372_ = Handler["blockable?"]
        if (nil ~= case_372_) then
          local f_3_auto = case_372_
          local function _373_(_)
            return blockable
          end
          _368_["blockable?"] = _373_
        else
          local _ = case_372_
          error("Protocol Handler doesn't define method blockable?")
        end
      end
      local case_375_ = Handler.commit
      if (nil ~= case_375_) then
        local f_3_auto = case_375_
        local function _376_(_)
          return f
        end
        _368_["commit"] = _376_
      else
        local _ = case_375_
        error("Protocol Handler doesn't define method commit")
      end
    end
    local function _378_(_241)
      return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Handler" .. ">")
    end
    return setmetatable({}, {__fennelview = _378_, __index = _368_, __name = "reify"})
  end
  local fhnop
  local function _379_()
    return nil
  end
  fhnop = fn_handler(_379_)
  local socket
  do
    local case_380_, case_381_ = pcall(require, "socket")
    if ((case_380_ == true) and (nil ~= case_381_)) then
      local s = case_381_
      socket = s
    else
      local _ = case_380_
      socket = nil
    end
  end
  local posix
  do
    local case_383_, case_384_ = pcall(require, "posix")
    if ((case_383_ == true) and (nil ~= case_384_)) then
      local p = case_384_
      posix = p
    else
      local _ = case_383_
      posix = nil
    end
  end
  local time, sleep, time_type
  local _387_
  do
    local t_386_ = socket
    if (nil ~= t_386_) then
      t_386_ = t_386_.gettime
    else
    end
    _387_ = t_386_
  end
  if _387_ then
    local sleep0 = socket.sleep
    local function _389_(_241)
      return sleep0((_241 / 1000))
    end
    time, sleep, time_type = socket.gettime, _389_, "socket"
  else
    local _391_
    do
      local t_390_ = posix
      if (nil ~= t_390_) then
        t_390_ = t_390_.clock_gettime
      else
      end
      _391_ = t_390_
    end
    if _391_ then
      local gettime = posix.clock_gettime
      local nanosleep = posix.nanosleep
      local function _393_()
        local s, ns = gettime()
        return (s + (ns / 1000000000))
      end
      local function _394_(_241)
        local s, ms = m_2fmodf((_241 / 1000))
        return nanosleep(s, (1000000 * 1000 * ms))
      end
      time, sleep, time_type = _393_, _394_, "posix"
    else
      time, sleep, time_type = os.time, nil, "lua"
    end
  end
  local difftime
  local function _396_(_241, _242)
    return (_241 - _242)
  end
  difftime = _396_
  local function add_21(buffer, item)
    if (nil == item) then
      _G.error("Missing argument item on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:244", 2)
    else
    end
    if (nil == buffer) then
      _G.error("Missing argument buffer on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:244", 2)
    else
    end
    return buffer["add!"](buffer, item)
  end
  local function close_buf_21(buffer)
    if (nil == buffer) then
      _G.error("Missing argument buffer on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:245", 2)
    else
    end
    return buffer["close-buf!"](buffer)
  end
  local function full_3f(buffer)
    if (nil == buffer) then
      _G.error("Missing argument buffer on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:242", 2)
    else
    end
    return buffer["full?"](buffer)
  end
  local function remove_21(buffer)
    if (nil == buffer) then
      _G.error("Missing argument buffer on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:243", 2)
    else
    end
    return buffer["remove!"](buffer)
  end
  local _local_402_ = {["add!"] = add_21, ["close-buf!"] = close_buf_21, ["full?"] = full_3f, ["remove!"] = remove_21}
  local add_210 = _local_402_["add!"]
  local close_buf_210 = _local_402_["close-buf!"]
  local full_3f0 = _local_402_["full?"]
  local remove_210 = _local_402_["remove!"]
  local Buffer = _local_402_
  local FixedBuffer
  local function _404_(_403_)
    local buffer = _403_.buf
    local size = _403_.size
    return (#buffer >= size)
  end
  local function _406_(_405_)
    local buffer = _405_.buf
    return #buffer
  end
  local function _408_(_407_, val)
    local buffer = _407_.buf
    local this = _407_
    assert((val ~= nil), "value must not be nil")
    buffer[(1 + #buffer)] = val
    return this
  end
  local function _410_(_409_)
    local buffer = _409_.buf
    if (#buffer > 0) then
      return t_2fremove(buffer, 1)
    else
      return nil
    end
  end
  local function _412_(_)
    return nil
  end
  FixedBuffer = {type = Buffer, ["full?"] = _404_, length = _406_, ["add!"] = _408_, ["remove!"] = _410_, ["close-buf!"] = _412_}
  local DroppingBuffer
  local function _413_()
    return false
  end
  local function _415_(_414_)
    local buffer = _414_.buf
    return #buffer
  end
  local function _417_(_416_, val)
    local buffer = _416_.buf
    local size = _416_.size
    local this = _416_
    assert((val ~= nil), "value must not be nil")
    if (#buffer < size) then
      buffer[(1 + #buffer)] = val
    else
    end
    return this
  end
  local function _420_(_419_)
    local buffer = _419_.buf
    if (#buffer > 0) then
      return t_2fremove(buffer, 1)
    else
      return nil
    end
  end
  local function _422_(_)
    return nil
  end
  DroppingBuffer = {type = Buffer, ["full?"] = _413_, length = _415_, ["add!"] = _417_, ["remove!"] = _420_, ["close-buf!"] = _422_}
  local SlidingBuffer
  local function _423_()
    return false
  end
  local function _425_(_424_)
    local buffer = _424_.buf
    return #buffer
  end
  local function _427_(_426_, val)
    local buffer = _426_.buf
    local size = _426_.size
    local this = _426_
    assert((val ~= nil), "value must not be nil")
    buffer[(1 + #buffer)] = val
    if (size < #buffer) then
      t_2fremove(buffer, 1)
    else
    end
    return this
  end
  local function _430_(_429_)
    local buffer = _429_.buf
    if (#buffer > 0) then
      return t_2fremove(buffer, 1)
    else
      return nil
    end
  end
  local function _432_(_)
    return nil
  end
  SlidingBuffer = {type = Buffer, ["full?"] = _423_, length = _425_, ["add!"] = _427_, ["remove!"] = _430_, ["close-buf!"] = _432_}
  local no_val = {}
  local PromiseBuffer
  local function _433_()
    return false
  end
  local function _434_(this)
    if rawequal(no_val, this.val) then
      return 0
    else
      return 1
    end
  end
  local function _436_(this, val)
    assert((val ~= nil), "value must not be nil")
    if rawequal(no_val, this.val) then
      this["val"] = val
    else
    end
    return this
  end
  local function _439_(_438_)
    local value = _438_.val
    return value
  end
  local function _441_(_440_)
    local value = _440_.val
    local this = _440_
    if rawequal(no_val, value) then
      this["val"] = nil
      return nil
    else
      return nil
    end
  end
  PromiseBuffer = {type = Buffer, val = no_val, ["full?"] = _433_, length = _434_, ["add!"] = _436_, ["remove!"] = _439_, ["close-buf!"] = _441_}
  local function buffer_2a(size, buffer_type)
    do local _ = (size and assert(("number" == type(size)), ("size must be a number: " .. tostring(size)))) end
    assert(not tostring(size):match("%."), "size must be integer")
    local function _443_(self)
      return self:length()
    end
    local function _444_(_241)
      return ("#<" .. tostring(_241):gsub("table:", "buffer:") .. ">")
    end
    return setmetatable({size = size, buf = {}}, {__index = buffer_type, __name = "buffer", __len = _443_, __fennelview = _444_})
  end
  local function buffer(n)
    return buffer_2a(n, FixedBuffer)
  end
  local function dropping_buffer(n)
    return buffer_2a(n, DroppingBuffer)
  end
  local function sliding_buffer(n)
    return buffer_2a(n, SlidingBuffer)
  end
  local function promise_buffer()
    return buffer_2a(1, PromiseBuffer)
  end
  local function buffer_3f(obj)
    if ((_G.type(obj) == "table") and (obj.type == Buffer)) then
      return true
    else
      local _ = obj
      return false
    end
  end
  local function unblocking_buffer_3f(buff)
    local case_446_ = (buffer_3f(buff) and getmetatable(buff).__index)
    if (case_446_ == SlidingBuffer) then
      return true
    elseif (case_446_ == DroppingBuffer) then
      return true
    elseif (case_446_ == PromiseBuffer) then
      return true
    else
      local _ = case_446_
      return false
    end
  end
  local timeouts = {}
  local dispatched_tasks = {}
  local os_2fclock = os.clock
  local n_instr, register_time, orig_hook, orig_mask, orig_n = 1000000
  local function schedule_hook(hook, n)
    if (gethook and sethook) then
      local hook_2a, mask, n_2a = gethook()
      if (hook ~= hook_2a) then
        register_time, orig_hook, orig_mask, orig_n = os_2fclock(), hook_2a, mask, n_2a
        return sethook(main_thread, hook, "", n)
      else
        return nil
      end
    else
      return nil
    end
  end
  local function cancel_hook(hook)
    if (gethook and sethook) then
      local case_450_, case_451_, case_452_ = gethook(main_thread)
      if ((case_450_ == hook) and true and true) then
        local _3fmask = case_451_
        local _3fn = case_452_
        sethook(main_thread, orig_hook, orig_mask, orig_n)
        return _3fmask, _3fn
      else
        return nil
      end
    else
      return nil
    end
  end
  local function process_messages(event)
    local took = (os_2fclock() - register_time)
    local _, n = cancel_hook(process_messages)
    if (event ~= "count") then
      n_instr = n
    else
      n_instr = m_2ffloor((0.01 / (took / n)))
    end
    do
      local done = nil
      for _0 = 1, 1024 do
        if done then break end
        local case_456_ = next(dispatched_tasks)
        if (nil ~= case_456_) then
          local f = case_456_
          local _457_
          do
            pcall(f)
            _457_ = f
          end
          dispatched_tasks[_457_] = nil
          done = nil
        elseif (case_456_ == nil) then
          done = true
        else
          done = nil
        end
      end
    end
    for t, ch in pairs(timeouts) do
      if (0 >= difftime(t, time())) then
        timeouts[t] = ch["close!"](ch)
      else
      end
    end
    if (next(dispatched_tasks) or next(timeouts)) then
      return schedule_hook(process_messages, n_instr)
    else
      return nil
    end
  end
  local function dispatch(f)
    if (gethook and sethook) then
      dispatched_tasks[f] = true
      schedule_hook(process_messages, n_instr)
    else
      f()
    end
    return nil
  end
  local function put_active_3f(_462_)
    local handler = _462_[1]
    return handler["active?"](handler)
  end
  local function cleanup_21(t, pred)
    local to_keep
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for i, v in ipairs(t) do
        local val_28_
        if pred(v) then
          val_28_ = v
        else
          val_28_ = nil
        end
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      to_keep = tbl_26_
    end
    while t_2fremove(t) do
    end
    for _, v in ipairs(to_keep) do
      t_2finsert(t, v)
    end
    return t
  end
  local MAX_QUEUE_SIZE = 1024
  local MAX_DIRTY = 64
  local Channel = {["dirty-puts"] = 0, ["dirty-takes"] = 0}
  Channel.abort = function(_465_)
    local puts = _465_.puts
    local function recur()
      local putter = t_2fremove(puts, 1)
      if (nil ~= putter) then
        local put_handler = putter[1]
        local val = putter[2]
        if put_handler["active?"](put_handler) then
          local put_cb = put_handler:commit()
          local function _466_()
            return put_cb(true)
          end
          return dispatch(_466_)
        else
          return recur()
        end
      else
        return nil
      end
    end
    return recur
  end
  Channel["put!"] = function(_469_, val, handler, enqueue_3f)
    local buf = _469_.buf
    local closed = _469_.closed
    local this = _469_
    assert((val ~= nil), "Can't put nil on a channel")
    if not handler["active?"]() then
      return {not closed}
    elseif closed then
      handler:commit()
      return {false}
    elseif (buf and not buf["full?"](buf)) then
      local takes = this.takes
      local add_211 = this["add!"]
      handler:commit()
      local done_3f = reduced_3f(add_211(buf, val))
      local take_cbs
      local function recur(takers)
        if (next(takes) and (#buf > 0)) then
          local taker = t_2fremove(takes, 1)
          if taker["active?"](taker) then
            local ret = taker:commit()
            local val0 = buf["remove!"](buf)
            local function _470_()
              local function _471_()
                return ret(val0)
              end
              t_2finsert(takers, _471_)
              return takers
            end
            return recur(_470_())
          else
            return recur(takers)
          end
        else
          return takers
        end
      end
      take_cbs = recur({})
      if done_3f then
        this:abort()
      else
      end
      if next(take_cbs) then
        for _, f in ipairs(take_cbs) do
          dispatch(f)
        end
      else
      end
      return {true}
    else
      local takes = this.takes
      local taker
      local function recur()
        local taker0 = t_2fremove(takes, 1)
        if taker0 then
          if taker0["active?"](taker0) then
            return taker0
          else
            return recur()
          end
        else
          return nil
        end
      end
      taker = recur()
      if taker then
        local take_cb = taker:commit()
        handler:commit()
        local function _478_()
          return take_cb(val)
        end
        dispatch(_478_)
        return {true}
      else
        local puts = this.puts
        local dirty_puts = this["dirty-puts"]
        if (dirty_puts > MAX_DIRTY) then
          this["dirty-puts"] = 0
          cleanup_21(puts, put_active_3f)
        else
          this["dirty-puts"] = (1 + dirty_puts)
        end
        if handler["blockable?"](handler) then
          assert((#puts < MAX_QUEUE_SIZE), ("No more than " .. MAX_QUEUE_SIZE .. " pending puts are allowed on a single channel." .. " Consider using a windowed buffer."))
          local handler_2a
          if (main_thread_3f() or enqueue_3f) then
            handler_2a = handler
          else
            local thunk = c_2frunning()
            local _480_ = {}
            do
              do
                local case_481_ = Handler["active?"]
                if (nil ~= case_481_) then
                  local f_3_auto = case_481_
                  local function _482_(_)
                    return handler["active?"](handler)
                  end
                  _480_["active?"] = _482_
                else
                  local _ = case_481_
                  error("Protocol Handler doesn't define method active?")
                end
              end
              do
                local case_484_ = Handler["blockable?"]
                if (nil ~= case_484_) then
                  local f_3_auto = case_484_
                  local function _485_(_)
                    return handler["blockable?"](handler)
                  end
                  _480_["blockable?"] = _485_
                else
                  local _ = case_484_
                  error("Protocol Handler doesn't define method blockable?")
                end
              end
              local case_487_ = Handler.commit
              if (nil ~= case_487_) then
                local f_3_auto = case_487_
                local function _488_(_)
                  local function _489_(...)
                    return c_2fresume(thunk, ...)
                  end
                  return _489_
                end
                _480_["commit"] = _488_
              else
                local _ = case_487_
                error("Protocol Handler doesn't define method commit")
              end
            end
            local function _491_(_241)
              return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Handler" .. ">")
            end
            handler_2a = setmetatable({}, {__fennelview = _491_, __index = _480_, __name = "reify"})
          end
          t_2finsert(puts, {handler_2a, val})
          if (handler ~= handler_2a) then
            local val0 = c_2fyield()
            handler:commit()(val0)
            return {val0}
          else
            return nil
          end
        else
          return nil
        end
      end
    end
  end
  Channel["take!"] = function(_497_, handler, enqueue_3f)
    local buf = _497_.buf
    local this = _497_
    if not handler["active?"](handler) then
      return nil
    elseif (not (nil == buf) and (#buf > 0)) then
      local case_498_ = handler:commit()
      if (nil ~= case_498_) then
        local take_cb = case_498_
        local puts = this.puts
        local val = buf["remove!"](buf)
        if (not buf["full?"](buf) and next(puts)) then
          local add_211 = this["add!"]
          local function recur(cbs)
            local putter = t_2fremove(puts, 1)
            local put_handler = putter[1]
            local val0 = putter[2]
            local cb = (put_handler["active?"](put_handler) and put_handler:commit())
            local cbs0
            if cb then
              t_2finsert(cbs, cb)
              cbs0 = cbs
            else
              cbs0 = cbs
            end
            local done_3f
            if cb then
              done_3f = reduced_3f(add_211(buf, val0))
            else
              done_3f = nil
            end
            if (not done_3f and not buf["full?"](buf) and next(puts)) then
              return recur(cbs0)
            else
              return {done_3f, cbs0}
            end
          end
          local _let_502_ = recur({})
          local done_3f = _let_502_[1]
          local cbs = _let_502_[2]
          if done_3f then
            this:abort()
          else
          end
          for _, cb in ipairs(cbs) do
            local function _504_()
              return cb(true)
            end
            dispatch(_504_)
          end
        else
        end
        return {val}
      else
        return nil
      end
    else
      local puts = this.puts
      local putter
      local function recur()
        local putter0 = t_2fremove(puts, 1)
        if putter0 then
          local tgt_507_ = putter0[1]
          if (tgt_507_)["active?"](tgt_507_) then
            return putter0
          else
            return recur()
          end
        else
          return nil
        end
      end
      putter = recur()
      if putter then
        local put_cb = putter[1]:commit()
        handler:commit()
        local function _510_()
          return put_cb(true)
        end
        dispatch(_510_)
        return {putter[2]}
      elseif this.closed then
        if buf then
          this["add!"](buf)
        else
        end
        if (handler["active?"](handler) and handler:commit()) then
          local has_val = (buf and next(buf.buf))
          local val
          if has_val then
            val = buf["remove!"](buf)
          else
            val = nil
          end
          return {val}
        else
          return nil
        end
      else
        local takes = this.takes
        local dirty_takes = this["dirty-takes"]
        if (dirty_takes > MAX_DIRTY) then
          this["dirty-takes"] = 0
          local function _514_(_241)
            return _241["active?"](_241)
          end
          cleanup_21(takes, _514_)
        else
          this["dirty-takes"] = (1 + dirty_takes)
        end
        if handler["blockable?"](handler) then
          assert((#takes < MAX_QUEUE_SIZE), ("No more than " .. MAX_QUEUE_SIZE .. " pending takes are allowed on a single channel."))
          local handler_2a
          if (main_thread_3f() or enqueue_3f) then
            handler_2a = handler
          else
            local thunk = c_2frunning()
            local _516_ = {}
            do
              do
                local case_517_ = Handler["active?"]
                if (nil ~= case_517_) then
                  local f_3_auto = case_517_
                  local function _518_(_)
                    return handler["active?"](handler)
                  end
                  _516_["active?"] = _518_
                else
                  local _ = case_517_
                  error("Protocol Handler doesn't define method active?")
                end
              end
              do
                local case_520_ = Handler["blockable?"]
                if (nil ~= case_520_) then
                  local f_3_auto = case_520_
                  local function _521_(_)
                    return handler["blockable?"](handler)
                  end
                  _516_["blockable?"] = _521_
                else
                  local _ = case_520_
                  error("Protocol Handler doesn't define method blockable?")
                end
              end
              local case_523_ = Handler.commit
              if (nil ~= case_523_) then
                local f_3_auto = case_523_
                local function _524_(_)
                  local function _525_(...)
                    return c_2fresume(thunk, ...)
                  end
                  return _525_
                end
                _516_["commit"] = _524_
              else
                local _ = case_523_
                error("Protocol Handler doesn't define method commit")
              end
            end
            local function _527_(_241)
              return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Handler" .. ">")
            end
            handler_2a = setmetatable({}, {__fennelview = _527_, __index = _516_, __name = "reify"})
          end
          t_2finsert(takes, handler_2a)
          if (handler ~= handler_2a) then
            local val = c_2fyield()
            handler:commit()(val)
            return {val}
          else
            return nil
          end
        else
          return nil
        end
      end
    end
  end
  Channel["close!"] = function(this)
    if this.closed then
      return nil
    else
      local buf = this.buf
      local takes = this.takes
      this.closed = true
      if (buf and (0 == #this.puts)) then
        this["add!"](buf)
      else
      end
      local function recur()
        local taker = t_2fremove(takes, 1)
        if (nil ~= taker) then
          if taker["active?"](taker) then
            local take_cb = taker:commit()
            local val
            if (buf and next(buf.buf)) then
              val = buf["remove!"](buf)
            else
              val = nil
            end
            local function _535_()
              return take_cb(val)
            end
            dispatch(_535_)
          else
          end
          return recur()
        else
          return nil
        end
      end
      recur()
      if buf then
        buf["close-buf!"](buf)
      else
      end
      return nil
    end
  end
  do
    Channel["type"] = Channel
    Channel["close"] = Channel["close!"]
  end
  local function err_handler_2a(e)
    io.stderr:write(tostring(e), "\n")
    return nil
  end
  local function add_21_2a(buf, ...)
    local case_540_, case_541_ = select("#", ...), ...
    if ((case_540_ == 1) and true) then
      local _3fval = case_541_
      return buf["add!"](buf, _3fval)
    elseif (case_540_ == 0) then
      return buf
    else
      return nil
    end
  end
  local function chan(buf_or_n, xform, err_handler)
    local buffer0
    if ((_G.type(buf_or_n) == "table") and (buf_or_n.type == Buffer)) then
      buffer0 = buf_or_n
    elseif (buf_or_n == 0) then
      buffer0 = nil
    elseif (nil ~= buf_or_n) then
      local size = buf_or_n
      buffer0 = buffer(size)
    else
      buffer0 = nil
    end
    local add_211
    if xform then
      assert((nil ~= buffer0), "buffer must be supplied when transducer is")
      add_211 = xform(add_21_2a)
    else
      add_211 = add_21_2a
    end
    local err_handler0 = (err_handler or err_handler_2a)
    local handler
    local function _545_(ch, err)
      local case_546_ = err_handler0(err)
      if (nil ~= case_546_) then
        local res = case_546_
        return ch["put!"](ch, res, fhnop)
      else
        return nil
      end
    end
    handler = _545_
    local c = {puts = {}, takes = {}, buf = buffer0, ["err-handler"] = handler}
    c["add!"] = function(...)
      local case_548_, case_549_ = pcall(add_211, ...)
      if ((case_548_ == true) and true) then
        local _ = case_549_
        return _
      elseif ((case_548_ == false) and (nil ~= case_549_)) then
        local e = case_549_
        return handler(c, e)
      else
        return nil
      end
    end
    local function _551_(_241)
      return ("#<" .. tostring(_241):gsub("table:", "ManyToManyChannel:") .. ">")
    end
    return setmetatable(c, {__index = Channel, __name = "ManyToManyChannel", __fennelview = _551_})
  end
  local function promise_chan(xform, err_handler)
    return chan(promise_buffer(), xform, err_handler)
  end
  local function chan_3f(obj)
    if ((_G.type(obj) == "table") and (obj.type == Channel)) then
      return true
    else
      local _ = obj
      return false
    end
  end
  local function closed_3f(port)
    assert(chan_3f(port), "expected a channel")
    return port.closed
  end
  local warned = false
  local function timeout(msecs)
    assert((gethook and sethook), "Can't advance timers - debug.sethook unavailable")
    local dt
    if (time_type == "lua") then
      local s = (msecs / 1000)
      if (not warned and not (m_2fceil(s) == s)) then
        warned = true
        local function _553_()
          warned = false
          return nil
        end
        local tgt_554_ = timeout(10000)
        do end (tgt_554_)["take!"](tgt_554_, fn_handler(_553_))
        io.stderr:write(("WARNING Lua doesn't support sub-second time precision.  " .. "Timeout rounded to the next nearest whole second.  " .. "Install luasocket or luaposix to get sub-second precision.\n"))
      else
      end
      dt = s
    else
      local _ = time_type
      dt = (msecs / 1000)
    end
    local t = ((m_2fceil((time() * 100)) / 100) + dt)
    local c
    local or_557_ = timeouts[t]
    if not or_557_ then
      local c0 = chan()
      timeouts[t] = c0
      or_557_ = c0
    end
    c = or_557_
    schedule_hook(process_messages, n_instr)
    return c
  end
  local function take_21(port, fn1, ...)
    assert(chan_3f(port), "expected a channel as first argument")
    assert((nil ~= fn1), "expected a callback")
    local on_caller_3f
    if (select("#", ...) == 0) then
      on_caller_3f = true
    else
      on_caller_3f = ...
    end
    do
      local case_560_ = port["take!"](port, fn_handler(fn1))
      if (nil ~= case_560_) then
        local retb = case_560_
        local val = retb[1]
        if on_caller_3f then
          fn1(val)
        else
          local function _561_()
            return fn1(val)
          end
          dispatch(_561_)
        end
      else
      end
    end
    return nil
  end
  local function try_sleep()
    local timers
    do
      local tmp_9_
      do
        local tbl_26_ = {}
        local i_27_ = 0
        for timer in pairs(timeouts) do
          local val_28_ = timer
          if (nil ~= val_28_) then
            i_27_ = (i_27_ + 1)
            tbl_26_[i_27_] = val_28_
          else
          end
        end
        tmp_9_ = tbl_26_
      end
      t_2fsort(tmp_9_)
      timers = tmp_9_
    end
    local case_565_ = timers[1]
    local and_566_ = (nil ~= case_565_)
    if and_566_ then
      local t = case_565_
      and_566_ = (sleep and not next(dispatched_tasks))
    end
    if and_566_ then
      local t = case_565_
      local t0 = (t - time())
      if (t0 > 0) then
        sleep(t0)
        process_messages("manual")
      else
      end
      return true
    else
      local _ = case_565_
      if next(dispatched_tasks) then
        process_messages("manual")
        return true
      else
        return nil
      end
    end
  end
  local function _3c_21_21(port)
    assert(main_thread_3f(), "<!! used not on the main thread")
    local val = nil
    local function _571_(_241)
      val = _241
      return nil
    end
    take_21(port, _571_)
    while ((val == nil) and not port.closed and try_sleep()) do
    end
    if ((nil == val) and not port.closed) then
      error(("The " .. tostring(port) .. " is not ready and there are no scheduled tasks." .. " Value will never arrive."), 2)
    else
    end
    return val
  end
  local function _3c_21(port)
    assert(not main_thread_3f(), "<! used not in (go ...) block")
    assert(chan_3f(port), "expected a channel as first argument")
    local case_573_ = port["take!"](port, fhnop)
    if (nil ~= case_573_) then
      local retb = case_573_
      return retb[1]
    else
      return nil
    end
  end
  local function put_21(port, val, ...)
    assert(chan_3f(port), "expected a channel as first argument")
    local case_575_ = select("#", ...)
    if (case_575_ == 0) then
      local case_576_ = port["put!"](port, val, fhnop)
      if (nil ~= case_576_) then
        local retb = case_576_
        return retb[1]
      else
        local _ = case_576_
        return true
      end
    elseif (case_575_ == 1) then
      return put_21(port, val, ..., true)
    elseif (case_575_ == 2) then
      local fn1, on_caller_3f = ...
      local case_578_ = port["put!"](port, val, fn_handler(fn1))
      if (nil ~= case_578_) then
        local retb = case_578_
        local ret = retb[1]
        if on_caller_3f then
          fn1(ret)
        else
          local function _579_()
            return fn1(ret)
          end
          dispatch(_579_)
        end
        return ret
      else
        local _ = case_578_
        return true
      end
    else
      return nil
    end
  end
  local function _3e_21_21(port, val)
    assert(main_thread_3f(), ">!! used not on the main thread")
    local not_done, res = true
    local function _583_(_241)
      not_done, res = false, _241
      return nil
    end
    put_21(port, val, _583_)
    while (not_done and try_sleep(port)) do
    end
    if (not_done and not port.closed) then
      error(("The " .. tostring(port) .. " is not ready and there are no scheduled tasks." .. " Value was sent but there's no one to receive it"), 2)
    else
    end
    return res
  end
  local function _3e_21(port, val)
    assert(not main_thread_3f(), ">! used not in (go ...) block")
    local case_585_ = port["put!"](port, val, fhnop)
    if (nil ~= case_585_) then
      local retb = case_585_
      return retb[1]
    else
      return nil
    end
  end
  local function close_21(port)
    assert(chan_3f(port), "expected a channel")
    return port:close()
  end
  local function go_2a(fn1)
    local c = chan(1)
    do
      local case_587_, case_588_
      local function _589_()
        do
          local case_590_ = fn1()
          if (nil ~= case_590_) then
            local val = case_590_
            _3e_21(c, val)
          else
          end
        end
        return close_21(c)
      end
      case_587_, case_588_ = c_2fresume(c_2fcreate(_589_))
      if ((case_587_ == false) and (nil ~= case_588_)) then
        local msg = case_588_
        c["err-handler"](c, msg)
        close_21(c)
      else
      end
    end
    return c
  end
  local function random_array(n)
    local ids
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for i = 1, n do
        local val_28_ = i
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      ids = tbl_26_
    end
    for i = n, 2, -1 do
      local j = m_2frandom(i)
      local ti = ids[i]
      ids[i] = ids[j]
      ids[j] = ti
    end
    return ids
  end
  local function alt_flag()
    local atom = {flag = true}
    local _594_ = {}
    do
      do
        local case_595_ = Handler["active?"]
        if (nil ~= case_595_) then
          local f_3_auto = case_595_
          local function _596_(_)
            return atom.flag
          end
          _594_["active?"] = _596_
        else
          local _ = case_595_
          error("Protocol Handler doesn't define method active?")
        end
      end
      do
        local case_598_ = Handler["blockable?"]
        if (nil ~= case_598_) then
          local f_3_auto = case_598_
          local function _599_(_)
            return true
          end
          _594_["blockable?"] = _599_
        else
          local _ = case_598_
          error("Protocol Handler doesn't define method blockable?")
        end
      end
      local case_601_ = Handler.commit
      if (nil ~= case_601_) then
        local f_3_auto = case_601_
        local function _602_(_)
          atom.flag = false
          return true
        end
        _594_["commit"] = _602_
      else
        local _ = case_601_
        error("Protocol Handler doesn't define method commit")
      end
    end
    local function _604_(_241)
      return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Handler" .. ">")
    end
    return setmetatable({}, {__fennelview = _604_, __index = _594_, __name = "reify"})
  end
  local function alt_handler(flag, cb)
    local _605_ = {}
    do
      do
        local case_606_ = Handler["active?"]
        if (nil ~= case_606_) then
          local f_3_auto = case_606_
          local function _607_(_)
            return flag["active?"](flag)
          end
          _605_["active?"] = _607_
        else
          local _ = case_606_
          error("Protocol Handler doesn't define method active?")
        end
      end
      do
        local case_609_ = Handler["blockable?"]
        if (nil ~= case_609_) then
          local f_3_auto = case_609_
          local function _610_(_)
            return true
          end
          _605_["blockable?"] = _610_
        else
          local _ = case_609_
          error("Protocol Handler doesn't define method blockable?")
        end
      end
      local case_612_ = Handler.commit
      if (nil ~= case_612_) then
        local f_3_auto = case_612_
        local function _613_(_)
          flag:commit()
          return cb
        end
        _605_["commit"] = _613_
      else
        local _ = case_612_
        error("Protocol Handler doesn't define method commit")
      end
    end
    local function _615_(_241)
      return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Handler" .. ">")
    end
    return setmetatable({}, {__fennelview = _615_, __index = _605_, __name = "reify"})
  end
  local function alts_21(ports, ...)
    assert(not main_thread_3f(), "called alts! on the main thread")
    assert((#ports > 0), "alts must have at least one channel operation")
    local n = #ports
    local arglen = select("#", ...)
    local no_def = {}
    local opts
    do
      local case_616_, case_617_ = select("#", ...), ...
      if (case_616_ == 0) then
        opts = {default = no_def}
      else
        local and_618_ = ((case_616_ == 1) and (nil ~= case_617_))
        if and_618_ then
          local t = case_617_
          and_618_ = ("table" == type(t))
        end
        if and_618_ then
          local t = case_617_
          local res = {default = no_def}
          for k, v in pairs(t) do
            res[k] = v
            res = res
          end
          opts = res
        else
          local _ = case_616_
          local res = {default = no_def}
          for i = 1, arglen, 2 do
            local k, v = select(i, ...)
            res[k] = v
            res = res
          end
          opts = res
        end
      end
    end
    local ids = random_array(n)
    local res_ch = chan(promise_buffer())
    local flag = alt_flag()
    local done = nil
    for i = 1, n do
      if done then break end
      local id
      if (opts and opts.priority) then
        id = i
      else
        id = ids[i]
      end
      local retb, port
      do
        local case_622_ = ports[id]
        local and_623_ = ((_G.type(case_622_) == "table") and true and true)
        if and_623_ then
          local _3fc = case_622_[1]
          local _3fv = case_622_[2]
          and_623_ = chan_3f(_3fc)
        end
        if and_623_ then
          local _3fc = case_622_[1]
          local _3fv = case_622_[2]
          local function _625_(_241)
            put_21(res_ch, {_241, _3fc})
            return close_21(res_ch)
          end
          retb, port = _3fc["put!"](_3fc, _3fv, alt_handler(flag, _625_), true), _3fc
        else
          local and_626_ = true
          if and_626_ then
            local _3fc = case_622_
            and_626_ = chan_3f(_3fc)
          end
          if and_626_ then
            local _3fc = case_622_
            local function _628_(_241)
              put_21(res_ch, {_241, _3fc})
              return close_21(res_ch)
            end
            retb, port = _3fc["take!"](_3fc, alt_handler(flag, _628_), true), _3fc
          else
            local _ = case_622_
            retb, port = error(("expected a channel: " .. tostring(_)))
          end
        end
      end
      if (nil ~= retb) then
        _3e_21(res_ch, {retb[1], port})
        done = true
      else
      end
    end
    if (flag["active?"](flag) and (no_def ~= opts.default)) then
      flag:commit()
      return {opts.default, "default"}
    else
      return _3c_21(res_ch)
    end
  end
  local function offer_21(port, val)
    assert(chan_3f(port), "expected a channel as first argument")
    if (next(port.takes) or (port.buf and not port.buf["full?"](port.buf))) then
      local case_632_ = port["put!"](port, val, fhnop)
      if (nil ~= case_632_) then
        local retb = case_632_
        return retb[1]
      else
        return nil
      end
    else
      return nil
    end
  end
  local function poll_21(port)
    assert(chan_3f(port), "expected a channel")
    if (next(port.puts) or (port.buf and (nil ~= next(port.buf.buf)))) then
      local case_635_ = port["take!"](port, fhnop)
      if (nil ~= case_635_) then
        local retb = case_635_
        return retb[1]
      else
        return nil
      end
    else
      return nil
    end
  end
  local function pipe(from, to, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    local _let_639_ = require("io.gitlab.andreyorst.async")
    local go_3_auto = _let_639_["go*"]
    local function _640_()
      local function recur()
        local val = _3c_21(from)
        if (nil == val) then
          if close_3f then
            return close_21(to)
          else
            return nil
          end
        else
          _3e_21(to, val)
          return recur()
        end
      end
      return recur()
    end
    return go_3_auto(_640_)
  end
  local function pipeline_2a(n, to, xf, from, close_3f, err_handler, kind)
    local jobs = chan(n)
    local results = chan(n)
    local finishes = ((kind == "async") and chan(n))
    local process
    local function _643_(job)
      if (job == nil) then
        close_21(results)
        return nil
      elseif ((_G.type(job) == "table") and (nil ~= job[1]) and (nil ~= job[2])) then
        local v = job[1]
        local p = job[2]
        local res = chan(1, xf, err_handler)
        do
          local _let_644_ = require("io.gitlab.andreyorst.async")
          local go_1_auto = _let_644_["go*"]
          local function _645_()
            _3e_21(res, v)
            return close_21(res)
          end
          go_1_auto(_645_)
        end
        put_21(p, res)
        return true
      else
        return nil
      end
    end
    process = _643_
    local async
    local function _647_(job)
      if (job == nil) then
        close_21(results)
        close_21(finishes)
        return nil
      elseif ((_G.type(job) == "table") and (nil ~= job[1]) and (nil ~= job[2])) then
        local v = job[1]
        local p = job[2]
        local res = chan(1)
        xf(v, res)
        put_21(p, res)
        return true
      else
        return nil
      end
    end
    async = _647_
    for _ = 1, n do
      if (kind == "compute") then
        local _let_649_ = require("io.gitlab.andreyorst.async")
        local go_3_auto = _let_649_["go*"]
        local function _650_()
          local function recur()
            local job = _3c_21(jobs)
            if process(job) then
              return recur()
            else
              return nil
            end
          end
          return recur()
        end
        go_3_auto(_650_)
      elseif (kind == "async") then
        local _let_652_ = require("io.gitlab.andreyorst.async")
        local go_3_auto = _let_652_["go*"]
        local function _653_()
          local function recur()
            local job = _3c_21(jobs)
            if async(job) then
              _3c_21(finishes)
              return recur()
            else
              return nil
            end
          end
          return recur()
        end
        go_3_auto(_653_)
      else
      end
    end
    do
      local _let_656_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_656_["go*"]
      local function _657_()
        local function recur()
          local case_658_ = _3c_21(from)
          if (case_658_ == nil) then
            return close_21(jobs)
          elseif (nil ~= case_658_) then
            local v = case_658_
            local p = chan(1)
            _3e_21(jobs, {v, p})
            _3e_21(results, p)
            return recur()
          else
            return nil
          end
        end
        return recur()
      end
      go_3_auto(_657_)
    end
    local _let_660_ = require("io.gitlab.andreyorst.async")
    local go_3_auto = _let_660_["go*"]
    local function _661_()
      local function recur()
        local case_662_ = _3c_21(results)
        if (case_662_ == nil) then
          if close_3f then
            return close_21(to)
          else
            return nil
          end
        elseif (nil ~= case_662_) then
          local p = case_662_
          local case_664_ = _3c_21(p)
          if (nil ~= case_664_) then
            local res = case_664_
            local function loop_2a()
              local case_665_ = _3c_21(res)
              if (nil ~= case_665_) then
                local val = case_665_
                _3e_21(to, val)
                return loop_2a()
              else
                return nil
              end
            end
            loop_2a()
            if finishes then
              _3e_21(finishes, "done")
            else
            end
            return recur()
          else
            return nil
          end
        else
          return nil
        end
      end
      return recur()
    end
    return go_3_auto(_661_)
  end
  local function pipeline_async(n, to, af, from, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    return pipeline_2a(n, to, af, from, close_3f, nil, "async")
  end
  local function pipeline(n, to, xf, from, ...)
    local close_3f, err_handler
    if (select("#", ...) == 0) then
      close_3f, err_handler = true
    else
      close_3f, err_handler = ...
    end
    return pipeline_2a(n, to, xf, from, close_3f, err_handler, "compute")
  end
  local function split(p, ch, t_buf_or_n, f_buf_or_n)
    local tc = chan(t_buf_or_n)
    local fc = chan(f_buf_or_n)
    do
      local _let_672_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_672_["go*"]
      local function _673_()
        local function recur()
          local v = _3c_21(ch)
          if (nil == v) then
            close_21(tc)
            return close_21(fc)
          else
            local _674_
            if p(v) then
              _674_ = tc
            else
              _674_ = fc
            end
            if _3e_21(_674_, v) then
              return recur()
            else
              return nil
            end
          end
        end
        return recur()
      end
      go_3_auto(_673_)
    end
    return {tc, fc}
  end
  local function reduce(f, init, ch)
    local _let_679_ = require("io.gitlab.andreyorst.async")
    local go_3_auto = _let_679_["go*"]
    local function _680_()
      local _2_678_ = init
      local ret = _2_678_
      local function recur(ret0)
        local v = _3c_21(ch)
        if (nil == v) then
          return ret0
        else
          local res = f(ret0, v)
          if reduced_3f(res) then
            return res:unbox()
          else
            return recur(res)
          end
        end
      end
      return recur(_2_678_)
    end
    return go_3_auto(_680_)
  end
  local function transduce(xform, f, init, ch)
    local f0 = xform(f)
    local _let_683_ = require("io.gitlab.andreyorst.async")
    local go_1_auto = _let_683_["go*"]
    local function _684_()
      local ret = _3c_21(reduce(f0, init, ch))
      return f0(ret)
    end
    return go_1_auto(_684_)
  end
  local function onto_chan_21(ch, coll, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    local _let_686_ = require("io.gitlab.andreyorst.async")
    local go_1_auto = _let_686_["go*"]
    local function _687_()
      for _, v in ipairs(coll) do
        _3e_21(ch, v)
      end
      if close_3f then
        close_21(ch)
      else
      end
      return ch
    end
    return go_1_auto(_687_)
  end
  local function bounded_length(bound, t)
    return m_2fmin(bound, #t)
  end
  local function to_chan_21(coll)
    local ch = chan(bounded_length(100, coll))
    onto_chan_21(ch, coll)
    return ch
  end
  local function pipeline_unordered_2a(n, to, xf, from, close_3f, err_handler, kind)
    local closes
    local function _689_()
      local tbl_26_ = {}
      local i_27_ = 0
      for _ = 1, (n - 1) do
        local val_28_ = "close"
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      return tbl_26_
    end
    closes = to_chan_21(_689_())
    local process
    local function _691_(v, p)
      local res = chan(1, xf, err_handler)
      local _let_692_ = require("io.gitlab.andreyorst.async")
      local go_1_auto = _let_692_["go*"]
      local function _693_()
        _3e_21(res, v)
        close_21(res)
        local function loop()
          local case_694_ = _3c_21(res)
          if (nil ~= case_694_) then
            local v0 = case_694_
            put_21(p, v0)
            return loop()
          else
            return nil
          end
        end
        loop()
        return close_21(p)
      end
      return go_1_auto(_693_)
    end
    process = _691_
    for _ = 1, n do
      local _let_696_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_696_["go*"]
      local function _697_()
        local function recur()
          local case_698_ = _3c_21(from)
          if (nil ~= case_698_) then
            local v = case_698_
            local c = chan(1)
            if (kind == "compute") then
              local _let_699_ = require("io.gitlab.andreyorst.async")
              local go_1_auto = _let_699_["go*"]
              local function _700_()
                return process(v, c)
              end
              go_1_auto(_700_)
            elseif (kind == "async") then
              local _let_701_ = require("io.gitlab.andreyorst.async")
              local go_1_auto = _let_701_["go*"]
              local function _702_()
                return xf(v, c)
              end
              go_1_auto(_702_)
            else
            end
            local function loop()
              local case_704_ = _3c_21(c)
              if (nil ~= case_704_) then
                local res = case_704_
                if _3e_21(to, res) then
                  return loop()
                else
                  return nil
                end
              else
                local _0 = case_704_
                return true
              end
            end
            if loop() then
              return recur()
            else
              return nil
            end
          else
            local _0 = case_698_
            if (close_3f and (nil == _3c_21(closes))) then
              return close_21(to)
            else
              return nil
            end
          end
        end
        return recur()
      end
      go_3_auto(_697_)
    end
    return nil
  end
  local function pipeline_unordered(n, to, xf, from, ...)
    local close_3f, err_handler
    if (select("#", ...) == 0) then
      close_3f, err_handler = true
    else
      close_3f, err_handler = ...
    end
    return pipeline_unordered_2a(n, to, xf, from, close_3f, err_handler, "compute")
  end
  local function pipeline_async_unordered(n, to, af, from, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    return pipeline_unordered_2a(n, to, af, from, close_3f, nil, "async")
  end
  local function muxch_2a(_)
    return _["muxch*"](_)
  end
  local _local_712_ = {["muxch*"] = muxch_2a}
  local muxch_2a0 = _local_712_["muxch*"]
  local Mux = _local_712_
  local function tap_2a(_, ch, close_3f)
    if (nil == close_3f) then
      _G.error("Missing argument close? on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1208", 2)
    else
    end
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1208", 2)
    else
    end
    return _["tap*"](_, ch, close_3f)
  end
  local function untap_2a(_, ch)
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1209", 2)
    else
    end
    return _["untap*"](_, ch)
  end
  local function untap_all_2a(_)
    return _["untap-all*"](_)
  end
  local _local_716_ = {["tap*"] = tap_2a, ["untap*"] = untap_2a, ["untap-all*"] = untap_all_2a}
  local tap_2a0 = _local_716_["tap*"]
  local untap_2a0 = _local_716_["untap*"]
  local untap_all_2a0 = _local_716_["untap-all*"]
  local Mult = _local_716_
  local function mult(ch)
    local dctr = nil
    local atom = {cs = {}}
    local m
    do
      local _717_ = {}
      do
        do
          local case_718_ = Mux["muxch*"]
          if (nil ~= case_718_) then
            local f_3_auto = case_718_
            local function _719_(_)
              return ch
            end
            _717_["muxch*"] = _719_
          else
            local _ = case_718_
            error("Protocol Mux doesn't define method muxch*")
          end
        end
        do
          local case_721_ = Mult["tap*"]
          if (nil ~= case_721_) then
            local f_3_auto = case_721_
            local function _722_(_, ch0, close_3f)
              atom["cs"][ch0] = close_3f
              return nil
            end
            _717_["tap*"] = _722_
          else
            local _ = case_721_
            error("Protocol Mult doesn't define method tap*")
          end
        end
        do
          local case_724_ = Mult["untap*"]
          if (nil ~= case_724_) then
            local f_3_auto = case_724_
            local function _725_(_, ch0)
              atom["cs"][ch0] = nil
              return nil
            end
            _717_["untap*"] = _725_
          else
            local _ = case_724_
            error("Protocol Mult doesn't define method untap*")
          end
        end
        local case_727_ = Mult["untap-all*"]
        if (nil ~= case_727_) then
          local f_3_auto = case_727_
          local function _728_(_)
            atom["cs"] = {}
            return nil
          end
          _717_["untap-all*"] = _728_
        else
          local _ = case_727_
          error("Protocol Mult doesn't define method untap-all*")
        end
      end
      local function _730_(_241)
        return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Mux, Mult" .. ">")
      end
      m = setmetatable({}, {__fennelview = _730_, __index = _717_, __name = "reify"})
    end
    local dchan = chan(1)
    local done
    local function _731_(_)
      dctr = (dctr - 1)
      if (0 == dctr) then
        return put_21(dchan, true)
      else
        return nil
      end
    end
    done = _731_
    do
      local _let_733_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_733_["go*"]
      local function _734_()
        local function recur()
          local val = _3c_21(ch)
          if (nil == val) then
            for c, close_3f in pairs(atom.cs) do
              if close_3f then
                close_21(c)
              else
              end
            end
            return nil
          else
            local chs
            do
              local tbl_26_ = {}
              local i_27_ = 0
              for k in pairs(atom.cs) do
                local val_28_ = k
                if (nil ~= val_28_) then
                  i_27_ = (i_27_ + 1)
                  tbl_26_[i_27_] = val_28_
                else
                end
              end
              chs = tbl_26_
            end
            dctr = #chs
            for _, c in ipairs(chs) do
              if not put_21(c, val, done) then
                untap_2a0(m, c)
              else
              end
            end
            if next(chs) then
              _3c_21(dchan)
            else
            end
            return recur()
          end
        end
        return recur()
      end
      go_3_auto(_734_)
    end
    return m
  end
  local function tap(mult0, ch, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    tap_2a0(mult0, ch, close_3f)
    return ch
  end
  local function untap(mult0, ch)
    return untap_2a0(mult0, ch)
  end
  local function untap_all(mult0)
    return untap_all_2a0(mult0)
  end
  local function admix_2a(_, ch)
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1272", 2)
    else
    end
    return _["admix*"](_, ch)
  end
  local function solo_mode_2a(_, mode)
    if (nil == mode) then
      _G.error("Missing argument mode on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1276", 2)
    else
    end
    return _["solo-mode*"](_, mode)
  end
  local function toggle_2a(_, state_map)
    if (nil == state_map) then
      _G.error("Missing argument state-map on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1275", 2)
    else
    end
    return _["toggle*"](_, state_map)
  end
  local function unmix_2a(_, ch)
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1273", 2)
    else
    end
    return _["unmix*"](_, ch)
  end
  local function unmix_all_2a(_)
    return _["unmix-all*"](_)
  end
  local _local_745_ = {["admix*"] = admix_2a, ["solo-mode*"] = solo_mode_2a, ["toggle*"] = toggle_2a, ["unmix*"] = unmix_2a, ["unmix-all*"] = unmix_all_2a}
  local admix_2a0 = _local_745_["admix*"]
  local solo_mode_2a0 = _local_745_["solo-mode*"]
  local toggle_2a0 = _local_745_["toggle*"]
  local unmix_2a0 = _local_745_["unmix*"]
  local unmix_all_2a0 = _local_745_["unmix-all*"]
  local Mix = _local_745_
  local function mix(out)
    local atom = {cs = {}, ["solo-mode"] = "mute"}
    local solo_modes = {mute = true, pause = true}
    local change = chan(sliding_buffer(1))
    local changed
    local function _746_()
      return put_21(change, true)
    end
    changed = _746_
    local pick
    local function _747_(attr, chs)
      local tbl_21_ = {}
      for c, v in pairs(chs) do
        local k_22_, v_23_
        if v[attr] then
          k_22_, v_23_ = c, true
        else
          k_22_, v_23_ = nil
        end
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
      return tbl_21_
    end
    pick = _747_
    local calc_state
    local function _750_()
      local chs = atom.cs
      local mode = atom["solo-mode"]
      local solos = pick("solo", chs)
      local pauses = pick("pause", chs)
      local _751_
      do
        local tmp_9_
        if ((mode == "pause") and next(solos)) then
          local tbl_26_ = {}
          local i_27_ = 0
          for k in pairs(solos) do
            local val_28_ = k
            if (nil ~= val_28_) then
              i_27_ = (i_27_ + 1)
              tbl_26_[i_27_] = val_28_
            else
            end
          end
          tmp_9_ = tbl_26_
        else
          local tbl_26_ = {}
          local i_27_ = 0
          for k in pairs(chs) do
            local val_28_
            if not pauses[k] then
              val_28_ = k
            else
              val_28_ = nil
            end
            if (nil ~= val_28_) then
              i_27_ = (i_27_ + 1)
              tbl_26_[i_27_] = val_28_
            else
            end
          end
          tmp_9_ = tbl_26_
        end
        t_2finsert(tmp_9_, change)
        _751_ = tmp_9_
      end
      return {solos = solos, mutes = pick("mute", chs), reads = _751_}
    end
    calc_state = _750_
    local m
    do
      local _756_ = {}
      do
        do
          local case_757_ = Mux["muxch*"]
          if (nil ~= case_757_) then
            local f_3_auto = case_757_
            local function _758_(_)
              return out
            end
            _756_["muxch*"] = _758_
          else
            local _ = case_757_
            error("Protocol Mux doesn't define method muxch*")
          end
        end
        do
          local case_760_ = Mix["admix*"]
          if (nil ~= case_760_) then
            local f_3_auto = case_760_
            local function _761_(_, ch)
              atom.cs[ch] = {}
              return changed()
            end
            _756_["admix*"] = _761_
          else
            local _ = case_760_
            error("Protocol Mix doesn't define method admix*")
          end
        end
        do
          local case_763_ = Mix["unmix*"]
          if (nil ~= case_763_) then
            local f_3_auto = case_763_
            local function _764_(_, ch)
              atom.cs[ch] = nil
              return changed()
            end
            _756_["unmix*"] = _764_
          else
            local _ = case_763_
            error("Protocol Mix doesn't define method unmix*")
          end
        end
        do
          local case_766_ = Mix["unmix-all*"]
          if (nil ~= case_766_) then
            local f_3_auto = case_766_
            local function _767_(_)
              atom.cs = {}
              return changed()
            end
            _756_["unmix-all*"] = _767_
          else
            local _ = case_766_
            error("Protocol Mix doesn't define method unmix-all*")
          end
        end
        do
          local case_769_ = Mix["toggle*"]
          if (nil ~= case_769_) then
            local f_3_auto = case_769_
            local function _770_(_, state_map)
              atom.cs = merge_with(merge_2a, atom.cs, state_map)
              return changed()
            end
            _756_["toggle*"] = _770_
          else
            local _ = case_769_
            error("Protocol Mix doesn't define method toggle*")
          end
        end
        local case_772_ = Mix["solo-mode*"]
        if (nil ~= case_772_) then
          local f_3_auto = case_772_
          local function _773_(_, mode)
            if not solo_modes[mode] then
              local _774_
              do
                local tbl_26_ = {}
                local i_27_ = 0
                for k in pairs(solo_modes) do
                  local val_28_ = k
                  if (nil ~= val_28_) then
                    i_27_ = (i_27_ + 1)
                    tbl_26_[i_27_] = val_28_
                  else
                  end
                end
                _774_ = tbl_26_
              end
              assert(false, ("mode must be one of: " .. t_2fconcat(_774_, ", ")))
            else
            end
            atom["solo-mode"] = mode
            return changed()
          end
          _756_["solo-mode*"] = _773_
        else
          local _ = case_772_
          error("Protocol Mix doesn't define method solo-mode*")
        end
      end
      local function _778_(_241)
        return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Mux, Mix" .. ">")
      end
      m = setmetatable({}, {__fennelview = _778_, __index = _756_, __name = "reify"})
    end
    do
      local _let_780_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_780_["go*"]
      local function _781_()
        local _2_779_ = calc_state()
        local solos = _2_779_.solos
        local mutes = _2_779_.mutes
        local reads = _2_779_.reads
        local state = _2_779_
        local function recur(_782_)
          local solos0 = _782_.solos
          local mutes0 = _782_.mutes
          local reads0 = _782_.reads
          local state0 = _782_
          local _let_783_ = alts_21(reads0)
          local v = _let_783_[1]
          local c = _let_783_[2]
          local res = _let_783_
          if ((nil == v) or (c == change)) then
            if (nil == v) then
              atom.cs[c] = nil
            else
            end
            return recur(calc_state())
          else
            if (solos0[c] or (not next(solos0) and not mutes0[c])) then
              if _3e_21(out, v) then
                return recur(state0)
              else
                return nil
              end
            else
              return recur(state0)
            end
          end
        end
        return recur(_2_779_)
      end
      go_3_auto(_781_)
    end
    return m
  end
  local function admix(mix0, ch)
    return admix_2a0(mix0, ch)
  end
  local function unmix(mix0, ch)
    return unmix_2a0(mix0, ch)
  end
  local function unmix_all(mix0)
    return unmix_all_2a0(mix0)
  end
  local function toggle(mix0, state_map)
    return toggle_2a0(mix0, state_map)
  end
  local function solo_mode(mix0, mode)
    return solo_mode_2a0(mix0, mode)
  end
  local function sub_2a(_, v, ch, close_3f)
    if (nil == close_3f) then
      _G.error("Missing argument close? on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1377", 2)
    else
    end
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1377", 2)
    else
    end
    if (nil == v) then
      _G.error("Missing argument v on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1377", 2)
    else
    end
    return _["sub*"](_, v, ch, close_3f)
  end
  local function unsub_2a(_, v, ch)
    if (nil == ch) then
      _G.error("Missing argument ch on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1378", 2)
    else
    end
    if (nil == v) then
      _G.error("Missing argument v on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1378", 2)
    else
    end
    return _["unsub*"](_, v, ch)
  end
  local function unsub_all_2a(_, v)
    if (nil == v) then
      _G.error("Missing argument v on .deps/git/andreyorst/async.fnl/ea0a63f2c87651f9c63ee775f2a066281b868573/src/io/gitlab/andreyorst/async/init.fnl:1379", 2)
    else
    end
    return _["unsub-all*"](_, v)
  end
  local _local_794_ = {["sub*"] = sub_2a, ["unsub*"] = unsub_2a, ["unsub-all*"] = unsub_all_2a}
  local sub_2a0 = _local_794_["sub*"]
  local unsub_2a0 = _local_794_["unsub*"]
  local unsub_all_2a0 = _local_794_["unsub-all*"]
  local Pub = _local_794_
  local function pub(ch, topic_fn, buf_fn)
    local buf_fn0
    local or_795_ = buf_fn
    if not or_795_ then
      local function _796_()
        return nil
      end
      or_795_ = _796_
    end
    buf_fn0 = or_795_
    local atom = {mults = {}}
    local ensure_mult
    local function _797_(topic)
      local case_798_ = atom.mults[topic]
      if (nil ~= case_798_) then
        local m = case_798_
        return m
      elseif (case_798_ == nil) then
        local mults = atom.mults
        local m = mult(chan(buf_fn0(topic)))
        do
          mults[topic] = m
        end
        return m
      else
        return nil
      end
    end
    ensure_mult = _797_
    local p
    do
      local _800_ = {}
      do
        do
          local case_801_ = Mux["muxch*"]
          if (nil ~= case_801_) then
            local f_3_auto = case_801_
            local function _802_(_)
              return ch
            end
            _800_["muxch*"] = _802_
          else
            local _ = case_801_
            error("Protocol Mux doesn't define method muxch*")
          end
        end
        do
          local case_804_ = Pub["sub*"]
          if (nil ~= case_804_) then
            local f_3_auto = case_804_
            local function _805_(_, topic, ch0, close_3f)
              local m = ensure_mult(topic)
              return tap_2a0(m, ch0, close_3f)
            end
            _800_["sub*"] = _805_
          else
            local _ = case_804_
            error("Protocol Pub doesn't define method sub*")
          end
        end
        do
          local case_807_ = Pub["unsub*"]
          if (nil ~= case_807_) then
            local f_3_auto = case_807_
            local function _808_(_, topic, ch0)
              local case_809_ = atom.mults[topic]
              if (nil ~= case_809_) then
                local m = case_809_
                return untap_2a0(m, ch0)
              else
                return nil
              end
            end
            _800_["unsub*"] = _808_
          else
            local _ = case_807_
            error("Protocol Pub doesn't define method unsub*")
          end
        end
        local case_812_ = Pub["unsub-all*"]
        if (nil ~= case_812_) then
          local f_3_auto = case_812_
          local function _813_(_, topic)
            if topic then
              atom["mults"][topic] = nil
              return nil
            else
              atom["mults"] = {}
              return nil
            end
          end
          _800_["unsub-all*"] = _813_
        else
          local _ = case_812_
          error("Protocol Pub doesn't define method unsub-all*")
        end
      end
      local function _816_(_241)
        return ("#<" .. tostring(_241):gsub("table:", "reify:") .. ": " .. "Mux, Pub" .. ">")
      end
      p = setmetatable({}, {__fennelview = _816_, __index = _800_, __name = "reify"})
    end
    do
      local _let_817_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_817_["go*"]
      local function _818_()
        local function recur()
          local val = _3c_21(ch)
          if (nil == val) then
            for _, m in pairs(atom.mults) do
              close_21(muxch_2a0(m))
            end
            return nil
          else
            local topic = topic_fn(val)
            do
              local case_819_ = atom.mults[topic]
              if (nil ~= case_819_) then
                local m = case_819_
                if not _3e_21(muxch_2a0(m), val) then
                  atom["mults"][topic] = nil
                else
                end
              else
              end
            end
            return recur()
          end
        end
        return recur()
      end
      go_3_auto(_818_)
    end
    return p
  end
  local function sub(pub0, topic, ch, ...)
    local close_3f
    if (select("#", ...) == 0) then
      close_3f = true
    else
      close_3f = ...
    end
    return sub_2a0(pub0, topic, ch, close_3f)
  end
  local function unsub(pub0, topic, ch)
    return unsub_2a0(pub0, topic, ch)
  end
  local function unsub_all(pub0, topic)
    return unsub_all_2a0(pub0, topic)
  end
  local function map(f, chs, buf_or_n)
    local dctr = nil
    local out = chan(buf_or_n)
    local cnt = #chs
    local rets = {n = cnt}
    local dchan = chan(1)
    local done
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for i = 1, cnt do
        local val_28_
        local function _824_(ret)
          rets[i] = ret
          dctr = (dctr - 1)
          if (0 == dctr) then
            return put_21(dchan, rets)
          else
            return nil
          end
        end
        val_28_ = _824_
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      done = tbl_26_
    end
    if (0 == cnt) then
      close_21(out)
    else
      local _let_827_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_827_["go*"]
      local function _828_()
        local function recur()
          dctr = cnt
          for i = 1, cnt do
            local case_829_ = pcall(take_21, chs[i], done[i])
            if (case_829_ == false) then
              dctr = (dctr - 1)
            else
            end
          end
          local rets0 = _3c_21(dchan)
          local _831_
          do
            local res = false
            for i = 1, rets0.n do
              if res then break end
              res = (nil == rets0[i])
            end
            _831_ = res
          end
          if _831_ then
            return close_21(out)
          else
            _3e_21(out, f(t_2funpack(rets0)))
            return recur()
          end
        end
        return recur()
      end
      go_3_auto(_828_)
    end
    return out
  end
  local function merge(chs, buf_or_n)
    local out = chan(buf_or_n)
    do
      local _let_835_ = require("io.gitlab.andreyorst.async")
      local go_3_auto = _let_835_["go*"]
      local function _836_()
        local _2_834_ = chs
        local cs = _2_834_
        local function recur(cs0)
          if (#cs0 > 0) then
            local _let_837_ = alts_21(cs0)
            local v = _let_837_[1]
            local c = _let_837_[2]
            if (nil == v) then
              local function _838_()
                local tbl_26_ = {}
                local i_27_ = 0
                for _, c_2a in ipairs(cs0) do
                  local val_28_
                  if (c_2a ~= c) then
                    val_28_ = c_2a
                  else
                    val_28_ = nil
                  end
                  if (nil ~= val_28_) then
                    i_27_ = (i_27_ + 1)
                    tbl_26_[i_27_] = val_28_
                  else
                  end
                end
                return tbl_26_
              end
              return recur(_838_())
            else
              _3e_21(out, v)
              return recur(cs0)
            end
          else
            return close_21(out)
          end
        end
        return recur(_2_834_)
      end
      go_3_auto(_836_)
    end
    return out
  end
  local function into(t, ch)
    local function _843_(_241, _242)
      _241[(1 + #_241)] = _242
      return _241
    end
    return reduce(_843_, t, ch)
  end
  local function take(n, ch, buf_or_n)
    local out = chan(buf_or_n)
    do
      local _let_844_ = require("io.gitlab.andreyorst.async")
      local go_1_auto = _let_844_["go*"]
      local function _845_()
        local done = false
        for i = 1, n do
          if done then break end
          local case_846_ = _3c_21(ch)
          if (nil ~= case_846_) then
            local v = case_846_
            _3e_21(out, v)
          elseif (case_846_ == nil) then
            done = true
          else
          end
        end
        return close_21(out)
      end
      go_1_auto(_845_)
    end
    return out
  end
  return {buffer = buffer, ["dropping-buffer"] = dropping_buffer, ["sliding-buffer"] = sliding_buffer, ["promise-buffer"] = promise_buffer, ["unblocking-buffer?"] = unblocking_buffer_3f, ["main-thread?"] = main_thread_3f, chan = chan, ["chan?"] = chan_3f, ["promise-chan"] = promise_chan, ["take!"] = take_21, ["<!!"] = _3c_21_21, ["<!"] = _3c_21, timeout = timeout, ["put!"] = put_21, [">!!"] = _3e_21_21, [">!"] = _3e_21, ["close!"] = close_21, ["go*"] = go_2a, ["alts!"] = alts_21, ["offer!"] = offer_21, ["poll!"] = poll_21, pipe = pipe, ["pipeline-async"] = pipeline_async, pipeline = pipeline, ["pipeline-async-unordered"] = pipeline_async_unordered, ["pipeline-unordered"] = pipeline_unordered, reduce = reduce, reduced = reduced, ["reduced?"] = reduced_3f, transduce = transduce, split = split, ["onto-chan!"] = onto_chan_21, ["to-chan!"] = to_chan_21, mult = mult, tap = tap, untap = untap, ["untap-all"] = untap_all, mix = mix, admix = admix, unmix = unmix, ["unmix-all"] = unmix_all, toggle = toggle, ["solo-mode"] = solo_mode, pub = pub, sub = sub, unsub = unsub, ["unsub-all"] = unsub_all, map = map, merge = merge, into = into, take = take, buffers = {FixedBuffer = FixedBuffer, SlidingBuffer = SlidingBuffer, DroppingBuffer = DroppingBuffer, PromiseBuffer = PromiseBuffer}, __VERSION = "1.6.42"}
end
spoons = require("spoons")
local active_space_indicator
package.preload["active-space-indicator"] = package.preload["active-space-indicator"] or function(...)
  local function get_spaces_str()
    local title = {}
    local spaces_layout = hs.spaces.allSpaces()
    local active_spaces = hs.spaces.activeSpaces()
    local num_spaces = 0
    for _, screen in ipairs(hs.screen.allScreens()) do
      table.insert(title, (screen:name() .. ": "))
      local screen_uuid = screen:getUUID()
      local active_space = active_spaces[screen_uuid]
      for i, space in ipairs(spaces_layout[screen_uuid]) do
        local space_title = tostring((i + num_spaces))
        if (active_space and (active_space == space)) then
          table.insert(title, ("[" .. space_title .. "]"))
        else
          table.insert(title, (" " .. space_title .. " "))
        end
      end
      num_spaces = (num_spaces + #spaces_layout[screen_uuid])
      table.insert(title, "  ")
    end
    table.remove(title)
    return table.concat(title)
  end
  local function handle_space_switch(...)
    local rest = {...}
    return hs.alert(get_spaces_str())
  end
  local space_watcher = hs.spaces.watcher.new(handle_space_switch)
  space_watcher:start()
  local screen_watcher = hs.screen.watcher.new(handle_space_switch)
  screen_watcher:start()
  local expose = hs.expose.new()
  local function _1558_()
    return expose:toggleShow()
  end
  hs.hotkey.bind("ctrl-cmd", "e", "Expose", _1558_)
  return {}
end
active_space_indicator = require("active-space-indicator")
local file_watchers
package.preload["file-watchers"] = package.preload["file-watchers"] or function(...)
  local _local_1559_ = require("io.gitlab.andreyorst.cljlib.core")
  local mapv = _local_1559_.mapv
  local assoc = _local_1559_.assoc
  local _local_1581_ = require("events")
  local dispatch_event = _local_1581_["dispatch-event"]
  local tag_events = _local_1581_["tag-events"]
  local _local_1588_ = require("behaviors")
  local register_behavior = _local_1588_["register-behavior"]
  tag_events("file-watchers.events/file-change", "file-watchers", {"file-watchers.tags/file-change"})
  local function handle_reload(files, attrs)
    local evs
    local function _1589_(_241, _242)
      return assoc(_241, "file-path", _242)
    end
    evs = mapv(_1589_, attrs, files)
    for _, ev in ipairs(evs) do
      dispatch_event("file-watchers.events/file-change", "file-watchers", ev)
    end
    return nil
  end
  local my_watcher = hs.pathwatcher.new(hs.configdir, handle_reload)
  __fnl_global__file_2dwatchers_2fpath_2dwatcher = my_watcher:start()
  local reloading_3f = false
  local reload = hs.timer.delayed.new(0.5, hs.reload)
  local function _1590_(file_change_event)
    local path
    do
      local t_1591_ = file_change_event
      if (nil ~= t_1591_) then
        t_1591_ = t_1591_["event-data"]
      else
      end
      if (nil ~= t_1591_) then
        t_1591_ = t_1591_["file-path"]
      else
      end
      path = t_1591_
    end
    if (not reloading_3f and (nil ~= path) and (".hammerspoon/init.lua" == path:sub(-21))) then
      hs.alert("reloading")
      return reload:start()
    else
      return nil
    end
  end
  register_behavior("file-watchers.behaviors/reload-hammerspoon", "When init.lua changes, reload hammerspoon.", {"file-watchers.tags/file-change"}, _1590_)
  local function _1595_(file_change_event)
    local path
    do
      local t_1596_ = file_change_event
      if (nil ~= t_1596_) then
        t_1596_ = t_1596_["event-data"]
      else
      end
      if (nil ~= t_1596_) then
        t_1596_ = t_1596_["file-path"]
      else
      end
      path = t_1596_
    end
    if ((nil ~= path) and (".fnl" == path:sub(-4))) then
      return print(hs.execute("./compile.sh", true))
    else
      return nil
    end
  end
  register_behavior("file-watchers.behaviors/hammerspoon-compile-fennel", "Watch fennel files in hammerspoon folder and recompile them.", {"file-watchers.tags/file-change"}, _1595_)
  return {}
end
package.preload["events"] = package.preload["events"] or function(...)
  local fnl = require("fennel")
  --[[ example-event {:event-data {:window-id 123 :x 10 :y 20} :event-name "window-move" :event-tags ["some" "tags"] :origin "windows-watcher" :timestamp 0} ]]
  local processing_3f = false
  local events_queue = {}
  local event_handlers = {}
  local get_event_tags
  do
    local pairs_106_auto
    local function _1560_(t_107_auto)
      local case_1561_ = getmetatable(t_107_auto)
      if ((_G.type(case_1561_) == "table") and (nil ~= case_1561_.__pairs)) then
        local p_108_auto = case_1561_.__pairs
        return p_108_auto(t_107_auto)
      else
        local _ = case_1561_
        return pairs(t_107_auto)
      end
    end
    pairs_106_auto = _1560_
    local _let_1563_ = require("io.gitlab.andreyorst.cljlib.core")
    local eq_109_auto = _let_1563_.eq
    local function _1564_(t_107_auto, ...)
      local dispatch_value_114_auto
      local function _1565_(ev)
        return {ev["event-name"], ev.origin}
      end
      dispatch_value_114_auto = _1565_(...)
      local view_115_auto
      do
        local case_1566_, case_1567_ = pcall(require, "fennel")
        if ((case_1566_ == true) and (nil ~= case_1567_)) then
          local fennel_116_auto = case_1567_
          local function _1568_(_241)
            return fennel_116_auto.view(_241, {["one-line"] = true})
          end
          view_115_auto = _1568_
        else
          local _ = case_1566_
          view_115_auto = tostring
        end
      end
      return (t_107_auto[dispatch_value_114_auto] or t_107_auto[(({}).default or "default")] or error(("No method in multimethod '" .. "get-event-tags" .. "' for dispatch value: " .. view_115_auto(dispatch_value_114_auto)), 2))(...)
    end
    local function _1570_(t_107_auto, key_110_auto)
      local res_111_auto = nil
      for k_112_auto, v_113_auto in pairs_106_auto(t_107_auto) do
        if res_111_auto then break end
        if eq_109_auto(k_112_auto, key_110_auto) then
          res_111_auto = v_113_auto
        else
          res_111_auto = nil
        end
      end
      return res_111_auto
    end
    get_event_tags = setmetatable({}, {__call = _1564_, __fennelview = tostring, __index = _1570_, __name = ("multifn " .. "get-event-tags"), ["cljlib/type"] = "multifn"})
  end
  do
    local dispatch_118_auto = "default"
    local multifn_119_auto = get_event_tags
    local and_1573_ = not multifn_119_auto[dispatch_118_auto]
    if and_1573_ then
      local function fn_1572_(...)
        local _ = ...
        do
          local cnt_54_auto = select("#", ...)
          if (1 ~= cnt_54_auto) then
            error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1572_"))
          else
          end
        end
        return {"event/unknown"}
      end
      multifn_119_auto[dispatch_118_auto] = fn_1572_
      and_1573_ = multifn_119_auto
    end
    do local _ = and_1573_ end
  end
  local function tag_events(ev_name, orig, tags)
    local dispatch_118_auto = {ev_name, orig}
    local multifn_119_auto = get_event_tags
    local and_1576_ = not multifn_119_auto[dispatch_118_auto]
    if and_1576_ then
      local function fn_1575_(...)
        local _ = ...
        do
          local cnt_54_auto = select("#", ...)
          if (1 ~= cnt_54_auto) then
            error(("Wrong number of args (%s) passed to %s"):format(cnt_54_auto, "fn_1575_"))
          else
          end
        end
        return tags
      end
      multifn_119_auto[dispatch_118_auto] = fn_1575_
      and_1576_ = multifn_119_auto
    end
    return and_1576_
  end
  local function add_event_handler(handler)
    local idx = (1 + #event_handlers)
    table.insert(event_handlers, handler)
    local function _1578_()
      event_handlers[idx] = nil
      return nil
    end
    return _1578_
  end
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
  local function dispatch_event(event_name, origin, event_data)
    local event = {timestamp = hs.timer.secondsSinceEpoch(), ["event-name"] = event_name, origin = origin, ["event-data"] = event_data}
    event["event-tags"] = get_event_tags(event)
    table.insert(events_queue, event)
    if not processing_3f then
      return process_events()
    else
      return nil
    end
  end
  local function _1580_(event)
    return print("got event", fnl.view(event))
  end
  add_event_handler(_1580_)
  return {["tag-events"] = tag_events, ["add-event-handler"] = add_event_handler, ["dispatch-event"] = dispatch_event}
end
package.preload["behaviors"] = package.preload["behaviors"] or function(...)
  local _local_1582_ = require("io.gitlab.andreyorst.cljlib.core")
  local mapcat = _local_1582_.mapcat
  local into = _local_1582_.into
  local mapv = _local_1582_.mapv
  local hash_set = _local_1582_["hash-set"]
  local _local_1583_ = require("events")
  local add_event_handler = _local_1583_["add-event-handler"]
  --[[ example-behavior {:description "Some example behavior" :enabled? true :fn (fn [event] (print (fnl.view event))) :name "example-behavior" :respond-to ["example-tag"]} ]]
  local behaviors_register = {}
  local tag_to_behavior_map = {}
  local function register_behavior(name, desc, tags, f)
    local behavior = {name = name, description = desc, ["enabled?"] = true, ["respond-to"] = tags, fn = f}
    behaviors_register[name] = behavior
    for _, tag in pairs(tags) do
      if (nil == tag_to_behavior_map[tag]) then
        tag_to_behavior_map[tag] = {}
      else
      end
      table.insert(tag_to_behavior_map[tag], name)
    end
    return nil
  end
  local function get_behaviors_for_tags(tags)
    local function _1585_(_241)
      return behaviors_register[_241]
    end
    local function _1586_(_241)
      return tag_to_behavior_map[_241]
    end
    return mapv(_1585_, into(hash_set(), mapcat(_1586_, tags)))
  end
  local function _1587_(event)
    local bs = get_behaviors_for_tags(event["event-tags"])
    for _, behavior in pairs(bs) do
      local f = behavior.fn
      f(event)
    end
    return nil
  end
  add_event_handler(_1587_)
  return {["register-behavior"] = register_behavior}
end
file_watchers = require("file-watchers")
hs.window.animationDuration = 0.0
hs.ipc.cliInstall()
notify.warn("Reload Succeeded")
return {}
