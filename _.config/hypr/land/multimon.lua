require 'land.binds'

BuiltinOutput = "eDP-1"

-- Which output to set with the following keybind
local control_output = BuiltinOutput

-- Switching outputs modes
local function outputsSubmap()
  hl.bind("Equal", function()
    control_output = BuiltinOutput
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
    for _, monitor in ipairs(hl.get_monitors()) do
      hl.monitor({
        output = monitor.name,
        scale = 1,
        position = "auto-left",
      })
    end
    hl.monitor({
      output = BuiltinOutput,
      scale = 1.33,
      position = "0x700",
    })
    hl.dispatch(hl.dsp.submap("reset"))
  end)

  -- Mirror built-in output by default
  hl.bind("m", function()
    hl.monitor({
      output = BuiltinOutput,
      scale = 1,
      mode = "1920x1080",
    })
    hl.monitor({
      output = "",
      mirror = BuiltinOutput,
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
    output = BuiltinOutput,
    disabled = false,
    scale = 1,
  })
end)

hl.bind("switch:on:Lid Switch", function()
  if #hl.get_monitors() > 1 then
    hl.monitor({
      output = BuiltinOutput,
      disabled = true,
    })
  end
end)
