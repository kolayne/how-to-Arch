hl.on("hyprland.start", function()
  -- Run each of the commands below
  for _, cmd in ipairs({
    "wlhangul -k Insert",
    "xremap ~/.config/xremap/config.yml",
    "pdeath_hup hypridle",  -- Needs to be under pdeath_hup until the bug is fixed: https://github.com/hyprwm/hypridle/issues/171
    "hyprsunset",
    "waybar",
    "pdeath_hup Docs/Rimokon/venv/bin/python Docs/Rimokon/rimokon_main.py",
  }) do
    hl.dispatch(hl.dsp.exec_raw(cmd))
  end

  -- Open Telegram on workspace 9 without switching to it
  hl.exec_cmd("Telegram", { workspace = 9, no_initial_focus = true })
end)
