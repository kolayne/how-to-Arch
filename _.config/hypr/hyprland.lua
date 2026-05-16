-- Misc
hl.config({
  debug = {
    -- Keep logs disabled (default), unless you are debugging hyprland
    disable_logs = true
  },
})

hl.monitor({
  output = "",  -- All
  mode = "preferred",
  position = "auto",
  scale = 1,
})

-- Key bindings
require('land.binds')
-- Gestures
require('land.gestures')
-- Miscellaneous config options and animations (but not window management options)
require('land.general')
-- Autostart
require('land.autostart')
-- Permissions
require('land.permissions')
-- Window management config options and rules
require('land.windows')
