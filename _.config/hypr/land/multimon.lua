require 'land.binds'

local builtin_output <const> = "eDP-1"

-- Which output to set with the following keybind
local control_output = builtin_output

-- Switching outputs modes
local function outputsSubmap()
  hl.bind("Equal", function()
    control_output = builtin_output
  end)

  -- Scale 1
  hl.bind("1", function()
    hl.monitor({
      output = control_output,
      scale = 1,
    })
    hl.dispatch(hl.dsp.submap("reset"))
  end)
  -- Scale 1.33
  hl.bind("3", function()
    hl.monitor({
      output = control_output,
      scale = 1.33,
    })
    hl.dispatch(hl.dsp.submap("reset"))
  end)

  -- Lab mode
  hl.bind("l", function()
    hl.monitor({
      output = builtin_output,
      scale = 1.33,
      position = "1920x700",
    })
    hl.dispatch(hl.dsp.submap("reset"))
  end)

  -- Mirror built-in output by default
  hl.bind("m", function()
    hl.monitor({
      output = "",
      mirror = builtin_output,
    })
    hl.dispatch(hl.dsp.submap("reset"))
  end)

  -- Auto
  -- hl.bind("a", function()
  --   hl.monitor({
  --     output = "",
  --     scale = 1.33,
  --     -- position = "auto",
  --   })
  --   -- Unfortunately, could not achieve the desired action with `hl.monitor`.
  --   -- So, this has a side effect of reloading the whole config :(
  --   hl.dispatch(hl.dsp.submap("reset"))
  --   -- hl.dispatch(hl.dsp.exec_raw("hyprctl reload"))
  -- end)

  hl.bind("Escape", hl.dsp.submap("reset"))
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind(ModMain .. "O", hl.dsp.submap("reset"))
end

hl.define_submap("outputs", outputsSubmap)
hl.bind(ModMain .. "O", function() control_output = hl.get_active_monitor().name end)
hl.bind(ModMain .. "O", hl.dsp.submap("outputs"))

hl.bind("switch:off:Lid Switch", function()
  hl.monitor({
    output = builtin_output,
    disabled = false,
  })
end)

hl.bind("switch:on:Lid Switch", function()
  if #hl.get_monitors() > 1 then
    hl.monitor({
      output = builtin_output,
      disabled = true,
      scale = 1,
    })
  end
end)
