hl.config({
  gestures = {
    workspace_swipe_distance = 390,
    workspace_swipe_min_speed_to_force = 10,
    workspace_swipe_cancel_ratio = 0.5,
    workspace_swipe_direction_lock = false,
    workspace_swipe_forever = true,
  }
})

-- For window focusing functions (`FocusLeftWindow`, etc)
require('land.common')

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.gesture({ fingers = 3, direction = "pinchout", action = function()
  hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
end })

hl.gesture({ fingers = 3, direction = "down", action = function()
  hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "Tab" }))
end })

hl.gesture({ fingers = 3, direction = "up", action = function()
  hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL + SHIFT", key = "Tab" }))
end })

hl.gesture({ fingers = 4, direction = "left", action = FocusLeftWindow })
hl.gesture({ fingers = 4, direction = "right", action = FocusRightWindow })
hl.gesture({ fingers = 4, direction = "up", action = FocusTopWindow })
hl.gesture({ fingers = 4, direction = "down", action = FocusBottomWindow })
