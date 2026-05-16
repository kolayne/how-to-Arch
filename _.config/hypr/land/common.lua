-- Decoration: window border size
BorderSize = 2

-- Window management helper functions

---@return boolean True if the active window is either ungroupped or the first window in the group
function ActiveIsUngroupedOrGroupedFirst()
  local group = hl.get_active_window().group
  return group == nil or group.current_index == 1
end

---@return boolean True if the active window is either ungroupped or the last window in the group
function ActiveIsUngroupedOrGroupedLast()
  local group = hl.get_active_window().group
  return group == nil or group.current_index == group.size
end

function FocusLeftWindow()
  if ActiveIsUngroupedOrGroupedFirst() then
    hl.dispatch(hl.dsp.focus({ direction = "l" }))
  else
    hl.dispatch(hl.dsp.group.prev())
  end
  -- Bring floating to top:
  hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end

function FocusRightWindow()
  if ActiveIsUngroupedOrGroupedLast() then
    hl.dispatch(hl.dsp.focus({ direction = "r" }))
  else
    hl.dispatch(hl.dsp.group.next())
  end
  -- Bring floating to top:
  hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end

function FocusTopWindow()
  hl.dispatch(hl.dsp.focus({ direction = "u" }))
  -- Bring floating to top:
  hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end

function FocusBottomWindow()
  hl.dispatch(hl.dsp.focus({ direction = "d" }))
  -- Bring floating to top:
  hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end

function MoveWindowLeft()
  if ActiveIsUngroupedOrGroupedFirst() then
    hl.dispatch(hl.dsp.window.move({ direction = "l", group_aware = true }))
  else
    hl.dispatch(hl.dsp.group.move_window({ forward = false }))
  end
end

function MoveWindowRight()
  if ActiveIsUngroupedOrGroupedLast() then
    hl.dispatch(hl.dsp.window.move({ direction = "r", group_aware = true }))
  else
    hl.dispatch(hl.dsp.group.move_window({ forward = true }))
  end
end
