local M = {}

-- Move Cursor to center of screen or window
M.center_cursor = function(isScreen)
	if isScreen then
		local cres = hs.mouse.getCurrentScreen():frame()
		hs.mouse.absolutePosition({ x = cres.x + cres.w / 2, y = cres.y + cres.h / 2 })
	else
		local cwin = hs.window.focusedWindow()
		local wf = cwin:frame()
		if cwin then
			hs.mouse.absolutePosition({ x = wf.x + wf.w / 2, y = wf.y + wf.h / 2 })
		end
	end
end

M.move_to_next_screen = function()
	local screen_obj = hs.screen.allScreens()
	if #screen_obj < 2 then
		return
	end

	local screen = hs.mouse.getCurrentScreen()
	local next_screen = screen:next()

	local ration_x = next_screen:frame().w / screen:frame().w
	local ration_y = next_screen:frame().h / screen:frame().h

	local p = hs.mouse.getRelativePosition()
	hs.mouse.setRelativePosition({ ["x"] = p.x * ration_x, ["y"] = p.y * ration_y }, next_screen)
end

return M
