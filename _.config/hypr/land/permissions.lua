-- Note: permissions are only reloaded when Hyprland is restarted

hl.config({
  ecosystem = {
    enforce_permissions = true
  }
})

hl.permission({
  binary = "/usr/bin/grim",
  type = "screencopy",
  mode = "allow",
})

hl.permission({
  binary = "/usr/lib/xdg-desktop-portal-hyprland",
  type = "screencopy",
  mode = "allow",
})

hl.permission({
  binary = "/usr/bin/hyprlock",
  type = "screencopy",
  mode = "allow",
})

hl.permission({
  binary = ".*",
  type = "screencopy",
  mode = "ask",
})

hl.permission({
  binary = ".*",
  type = "plugin",
  mode = "deny",
})

-- This was not working correctly last I checked:
-- e.g., keyboards connected before start of Hyprland continue to work when denied
--[[
hl.permission({
  binary = ".*",
  type = "keyboard",
  mode = "ask",
})
]]
