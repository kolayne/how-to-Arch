ModMain = "SUPER + "
ModExtra = "ALT + "
ModShifting = "SHIFT + "

--- Combines default rofi arguments with supplied
---@param args string Arguments to `rofi`
---@return string Command to call rofi, including default arguments
local function rofi(args)
  return "rofi -config ~/.config/rofi.rasi " .. args
end

-- Workspaces
hl.bind(ModMain .. "Tab", hl.dsp.focus({ workspace = "previous" }))
for i = 1, 10 do
  local key = i % 10
  hl.bind(ModMain .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(ModMain .. ModShifting .. key, hl.dsp.window.move({ workspace = i, follow = false }))
  hl.bind(ModMain .. ModExtra .. ModShifting .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- For window focusing/moving functions (`FocusLeftWindow`, `MoveWindowLeft`, etc)
require('land.common')

-- Move focus: normal
hl.bind(ModMain .. "Left", FocusLeftWindow)
hl.bind(ModMain .. "Right", FocusRightWindow)
hl.bind(ModMain .. "Up", FocusTopWindow)
hl.bind(ModMain .. "Down", FocusBottomWindow)

-- Move focus: jump over groups
hl.bind(ModMain .. ModExtra .. "Left", hl.dsp.focus({ direction = "l" }))
hl.bind(ModMain .. ModExtra .. "Right", hl.dsp.focus({ direction = "r" }))

-- Move window in direction
hl.bind(ModMain .. ModShifting .. "Left", MoveWindowLeft)
hl.bind(ModMain .. ModShifting .. "Right", MoveWindowRight)
hl.bind(ModMain .. ModShifting .. "Up", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(ModMain .. ModShifting .. "Down", hl.dsp.window.move({ direction = "d", group_aware = true }))

-- Swap windows
hl.bind(ModMain .. ModExtra .. ModShifting .. "Left", hl.dsp.window.swap({ direction = "l" }))
hl.bind(ModMain .. ModExtra .. ModShifting .. "Right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(ModMain .. ModExtra .. ModShifting .. "Up", hl.dsp.window.swap({ direction = "u" }))
hl.bind(ModMain .. ModExtra .. ModShifting .. "Down", hl.dsp.window.swap({ direction = "d" }))

-- Move workspaces between monitors
hl.bind(ModMain .. ModShifting .. "CTRL + Left", hl.dsp.workspace.move({ monitor = "left" }))
hl.bind(ModMain .. ModShifting .. "CTRL + Right", hl.dsp.workspace.move({ monitor = "right" }))
hl.bind(ModMain .. ModShifting .. "CTRL + Up", hl.dsp.workspace.move({ monitor = "top" }))
hl.bind(ModMain .. ModShifting .. "CTRL + Down", hl.dsp.workspace.move({ monitor = "bottom" }))

-- Special workspace (scratchpad)
hl.bind(ModMain .. "Minus", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(ModMain .. ModShifting .. "Minus", function()
  hl.dispatch(hl.dsp.window.float({ action = "on" }))
  hl.dispatch(hl.dsp.window.move({ workspace = "special:scratch", follow = false }))
end)
hl.bind(ModMain .. ModExtra .. ModShifting .. "Minus", function()
  hl.dispatch(hl.dsp.window.float({ action = "on" }))
  hl.dispatch(hl.dsp.window.move({ workspace = "special:scratch", follow = true }))
end)

-- Groups
local function createGroupOrToggleLock()
  local group = hl.get_active_window().group
  if group == nil then
    hl.dispatch(hl.dsp.group.toggle())
  else
    hl.dispatch(hl.dsp.group.lock_active({ action = "toggle" }))
  end
end
hl.bind(ModMain .. "W", createGroupOrToggleLock)
hl.bind(ModMain .. ModShifting .. "W", hl.dsp.group.toggle())

-- Other window management key bindins
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind(ModMain .. ModShifting .. "B", hl.dsp.window.float())
local function switchFocusBetweenFloatingAndTiled()
  if hl.get_active_window().floating then
    hl.dispatch(hl.dsp.focus({ window = "tiled" }))
  else
    hl.dispatch(hl.dsp.focus({ window = "floating" }))
  end
end
hl.bind(ModMain .. "B", switchFocusBetweenFloatingAndTiled)
hl.bind(ModMain .. "P", hl.dsp.window.pin({ action = "toggle" }))
hl.bind(ModMain .. "E", hl.dsp.layout("togglesplit"))  -- dwindle: toggle split direction

-- Resize window via keyboard
hl.define_submap("resize", function()
  hl.bind("Left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
  hl.bind("Right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
  hl.bind("Up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
  hl.bind("Down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
  hl.bind("Escape", hl.dsp.submap("reset"))
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind(ModMain .. "R", hl.dsp.submap("reset"))
end)
hl.bind(ModMain .. "R", hl.dsp.submap("resize"))

-- Move/resize window with modMain + LMB/RMB and dragging
hl.bind(ModMain .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(ModMain .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume and brightness keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_raw("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_raw("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_raw("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_raw("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_raw("light -A 10"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_raw("light -U 10"), { locked = true, repeating = true })

-- Multimedia playback keys
hl.bind("XF86AudioPrev", hl.dsp.exec_raw("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_raw("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_raw("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_raw("playerctl play-pause"), { locked = true })

-- Fullscreenness management
hl.bind("F11", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(ModExtra .. "F11", hl.dsp.send_shortcut({ mods = "", key = "F11" }))
hl.bind(ModMain .. "F", hl.dsp.window.fullscreen_state({ internal = 2, client = -1, action = "toggle" }))
hl.bind(ModMain .. ModExtra .. "F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(ModMain .. ModExtra .. "0", hl.dsp.window.fullscreen_state({ internal = 0, client = 0, action = "set" }))

-- Launchers
hl.bind(ModMain .. "Return", hl.dsp.exec_raw("terminator"))
hl.bind(ModMain .. ModShifting .. "Return", hl.dsp.exec_cmd("foot -f 'Adwaita Mono'", { float = true }))
hl.bind("ALT + F2", hl.dsp.exec_raw(rofi("-show run")))
hl.bind(ModMain .. "D", hl.dsp.exec_raw(rofi("-show drun -show-icons -drun-show-actions")))
hl.bind(ModMain .. "G", hl.dsp.exec_raw("chromium"))
hl.bind("Print", hl.dsp.exec_raw("flameshot gui"))
hl.bind("CTRL + Print", hl.dsp.exec_raw("flameshot screen --clipboard"))
hl.bind("XF86Calculator", hl.dsp.exec_raw("gnome-calculator"))

-- Lock screen
hl.bind(ModMain .. "L", hl.dsp.exec_raw("loginctl lock-session"))

-- Shutdown menu
local shutdownLine = "hyprshutdown --no-fork --post-cmd 'shutdown now'\\0display\\x1fShutdown\n"
local rebootLine   = "hyprshutdown --no-fork --post-cmd 'reboot'\\0display\\x1fReboot\n"
local exitLine     = "hyprshutdown --no-fork\\0display\\x1fExit Hyprland\\n"
hl.bind(ModMain .. ModShifting .. "E", hl.dsp.exec_cmd(
  "echo -en \"" .. shutdownLine .. rebootLine .. exitLine .. "\" | " .. rofi("-dmenu -no-custom") .. " | sh"
))

hl.bind(ModMain .. ModShifting .. "R", hl.dsp.exec_raw("hyprctl reload"), { locked = true })
