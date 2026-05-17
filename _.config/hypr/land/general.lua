hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- For `BorderSize`
require('land.common')

hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 0,

    border_size = BorderSize,

    col = {
      active_border = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },

    -- Enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = true,
    hover_icon_on_border = false,
    extend_border_grab_area = 0,

    layout = "dwindle",
  }
})

hl.config({
  misc = {
    middle_click_paste = true,
  }
})

hl.config({
  binds = {
    -- This setting is not working the way I want it; I reimplemented it in binds.lua instead
    movefocus_cycles_groupfirst = false,
    allow_pin_fullscreen = true,
  }
})

hl.config({
  cursor = {
    no_warps = true,
  }
})

hl.config({
  input = {
    kb_layout = "us,ru",
    kb_options = "grp:win_space_toggle",

    follow_mouse = 1,
    mouse_refocus = true,

    sensitivity = 0,  -- -1.0 ~ 1.0, 0 means no modification

    special_fallthrough = true,

    touchpad = {
      disable_while_typing = false,
      natural_scroll = true,
      tap_to_click = true,
      drag_lock = 0,  -- Disabled
      tap_and_drag = true,
    }
  }
})

hl.config({
  decoration = {
    rounding = 10,
    rounding_power = 2,

    -- Transparency of focused and unfocused windows
    active_opacity = 1,
    inactive_opacity = 1,

    -- Special workspaces dim windows under them
    dim_special = 0.2,

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },

    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  }
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })
