local modMain = "SUPER + "
local modExtra = "ALT + "
local modShifting = "SHIFT + "

--- Combines default rofi arguments with supplied
---@param args string Arguments to `rofi`
---@return string Command to call rofi, including default arguments
local function rofi(args)
  return "rofi -config ~/.config/rofi.rasi " .. args
end

-- Workspaces
hl.bind(modMain .. "Tab", hl.dsp.focus({ workspace = "previous" }))
for i = 1, 10 do
  local key = i % 10
  hl.bind(modMain .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(modMain .. modShifting .. key, hl.dsp.window.move({ workspace = i, follow = false }))
  hl.bind(modMain .. modExtra .. modShifting .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- For window focusing/moving functions (`FocusLeftWindow`, `MoveWindowLeft`, etc)
require('land.common')

-- Move focus: normal
hl.bind(modMain .. "Left", FocusLeftWindow)
hl.bind(modMain .. "Right", FocusRightWindow)
hl.bind(modMain .. "Up", FocusTopWindow)
hl.bind(modMain .. "Down", FocusBottomWindow)

-- Move focus: jump over groups
hl.bind(modMain .. modExtra .. "Left", hl.dsp.focus({ direction = "l" }))
hl.bind(modMain .. modExtra .. "Right", hl.dsp.focus({ direction = "r" }))

-- Move window in direction
hl.bind(modMain .. modShifting .. "Left", MoveWindowLeft)
hl.bind(modMain .. modShifting .. "Right", MoveWindowRight)
hl.bind(modMain .. modShifting .. "Up", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(modMain .. modShifting .. "Down", hl.dsp.window.move({ direction = "d", group_aware = true }))

-- Swap windows
hl.bind(modMain .. modExtra .. modShifting .. "Left", hl.dsp.window.swap({ direction = "l" }))
hl.bind(modMain .. modExtra .. modShifting .. "Right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(modMain .. modExtra .. modShifting .. "Up", hl.dsp.window.swap({ direction = "u" }))
hl.bind(modMain .. modExtra .. modShifting .. "Down", hl.dsp.window.swap({ direction = "d" }))

-- Special workspace (scratchpad)
hl.bind(modMain .. "Minus", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(modMain .. modShifting .. "Minus", hl.dsp.window.move({ workspace = "special:scratch", follow = false }))

-- Groups
local function createGroupOrToggleLock()
  local group = hl.get_active_window().group
  if group == nil then
    hl.dispatch(hl.dsp.group.toggle())
  else
    hl.dispatch(hl.dsp.group.lock_active({ action = "toggle" }))
  end
end
hl.bind(modMain .. "W", createGroupOrToggleLock)
hl.bind(modMain .. modShifting .. "W", hl.dsp.group.toggle())

-- Other window management key bindins
hl.bind("ALT + F4", hl.dsp.window.kill())
hl.bind(modMain .. modShifting .. "B", hl.dsp.window.float())
local function switchFocusBetweenFloatingAndTiled()
  if hl.get_active_window().floating then
    hl.dispatch(hl.dsp.focus({ window = "tiled:true" }))
  else
    hl.dispatch(hl.dsp.focus({ window = "floating:true" }))
  end
end
hl.bind(modMain .. "B", switchFocusBetweenFloatingAndTiled)
--hl.bind(modMain .. "P", hl.dsp.window.pseudo())
hl.bind(modMain .. "E", hl.dsp.layout("togglesplit"))  -- dwindle: toggle split direction

-- Resize window via keyboard
hl.define_submap("resize", function()
  hl.bind("Left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
  hl.bind("Right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
  hl.bind("Up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
  hl.bind("Down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
  hl.bind("Escape", hl.dsp.submap("reset"))
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind(modMain .. "R", hl.dsp.submap("reset"))
end)
hl.bind(modMain .. "R", hl.dsp.submap("resize"))

-- Move/resize window with modMain + LMB/RMB and dragging
hl.bind(modMain .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(modMain .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

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
hl.bind(modExtra .. "F11", hl.dsp.send_shortcut({ mods = "", key = "F11" }))
hl.bind(modMain .. "F", hl.dsp.window.fullscreen_state({ internal = 2, client = -1, action = "toggle" }))
hl.bind(modMain .. modExtra .. "F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(modMain .. modExtra .. "0", hl.dsp.window.fullscreen_state({ internal = 0, client = 0, action = "set" }))

-- Launchers
--TODO: Improve shutdown
hl.bind(modMain .. modShifting .. "E", hl.dsp.exec_cmd("echo -e 'shutdown now\0display\x1fShutdown\nreboot\0display\x1fReboot\nhyprctl dispatch exit\0display\x1fExit Hyprland' | " .. rofi("-dmenu -no-custom") .. "| sh"))
hl.bind(modMain .. "Return", hl.dsp.exec_raw("terminator"))
hl.bind(modMain .. modShifting .. "Return", hl.dsp.exec_cmd("foot -f 'Adwaita Mono'", { float = true }))
hl.bind("ALT + F2", hl.dsp.exec_raw(rofi("-show run")))
hl.bind(modMain .. "D", hl.dsp.exec_raw(rofi("-show drun -show-icons -drun-show-actions")))
hl.bind(modMain .. "G", hl.dsp.exec_raw("chromium"))
hl.bind("Print", hl.dsp.exec_raw("flameshot gui"))
hl.bind("CTRL + Print", hl.dsp.exec_raw("flameshot screen --clipboard"))

-- Lock screen
hl.bind(modMain .. "L", hl.dsp.exec_raw("loginctl lock-session"))
