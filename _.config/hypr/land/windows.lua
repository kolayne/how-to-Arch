hl.config({
  dwindle = {
    force_split = 2,  -- Open new windows on the right/bottom
    preserve_split = true,  -- No automatic window swapping
  }
})

hl.config({
  misc = {
    focus_on_activate = true,  -- Allow focus stealing
    on_focus_under_fullscreen = 2,  -- Fullscreen get unfullscreened
    initial_workspace_tracking = 1,  -- A window is open on the workspace where it was invoked
    middle_click_paste = true,
  }
})

-- When a window is maximized, its border color is pink,
-- and so are floating windows over it.
hl.window_rule({
  name = "maximized-workspace",
  match = { workspace = "f[1]" },

  border_color = "rgba(ff80ccff)",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },

  no_focus = true,
})

-- Make file location picker windows floating (by title)
hl.window_rule({
  name = "file-picker",
  match = { title = "(Open Files?|Choose Files?|Save File|Save Image)" },

  float = true,
  -- Won't work very well because titles and classes vary
  persistent_size = true,
})

-- Chromium(-based) task manager windows (by title)
hl.window_rule({
  name = "chromium-task-manager",
  match = { title = "Task Manager - (Brave|Google Chrome|Chromium|Yandex Browser)" },

  float = true,
  persistent_size = true,
})

-- A few other floating windows
hl.window_rule({ match = { class = "org\\.gnome\\.Calculator" },     float = true })
hl.window_rule({ match = { class = "org\\.gnome\\.SystemMonitor" },  float = true, persistent_size = true })
hl.window_rule({ match = { class = "gnome-system-monitor" },         float = true, persistent_size = true })

hl.window_rule({
  name = "thunderbird-calendar-reminders",
  match = {
    class = "org.mozilla.Thunderbird",
    -- Initial title is this:
    title = "(Calendar Reminders|캘린더 알림)",
    -- and not this:
    -- title = "\d+ Reminders?",
  },

  float = true,
  no_initial_focus = true,
  focus_on_activate = false,
  pin = true,
})

-- For `BorderSize`
require('land.common')

hl.window_rule({
  -- Thunderbird new mail notification window.
  -- This rule also errorneously matches some other Thunderbird windows,
  -- such as windows displaying calendar event information.
  name = "thunderbird-new-mail",
  match = {
    class = "org.mozilla.Thunderbird",
    title = "^$",
  },

  float = true,
  no_initial_focus = true,
  pin = true,
  -- Put to the bottom right corner
  move = { "monitor_w - window_w - " .. BorderSize,  "monitor_h - window_h - " .. BorderSize },
})

-- Telegram media viewer: make it less noticable
hl.window_rule({
  name = "tg-media-viewer",
  match = {
    class = "org\\.telegram\\.desktop",
    title = "(Media viewer|미디어 뷰어)",
  },

  no_anim = true,
})

hl.window_rule({
  name = "zoom-annotate-toolbar",
  match = {
    class = "zoom",
    title = "annotate_toolbar",
  },

  float = true,
  no_initial_focus = true,
  size = {60, 60},
})

-- Float zoom notifications
hl.window_rule({
  name = "zoom-zoom",
  match = {
    class = "zoom",
    title = "zoom",
  },

  float = true,
  no_initial_focus = true,
})

-- Chromium-hyprland issue: a window requests to be maximized as soon as it exists fullscreen mode
hl.window_rule({ match = { class = "(chromium|google-chrome)" },  suppress_event = "maximize" })

-- flameshot: be floating to not mess with layout when taking a screenshot
hl.window_rule({ match = { class = "flameshot" },  float = true })

-- Picture in picture: keep aspect ratio
hl.window_rule({ match = { title = "Picture in picture" },  keep_aspect_ratio = true })
