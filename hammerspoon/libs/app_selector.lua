local M = {}

local function call_app(name)
	local app = hs.application.find(name)
	if app then
		local screen_id = hs.mouse.getCurrentScreen():id()
		local wins = app:allWindows()
		local fallback_win = nil
		for _, win in pairs(wins) do
			if not win:isMinimized() then
				local s = win:screen()
				if s:id() == screen_id then
					win:focus()
					return
				end
				fallback_win = win
			end
		end
		if fallback_win then
			fallback_win:focus()
		else
			hs.alert.show("Not Avaliable Windows.")
		end
	else
		--hs.application.launchOrFocus(name)
		hs.alert.show("App not found.")
	end
end

M.init = function(km, maps)
	for key, app_name in pairs(maps) do
		km:bind("", key, "", function()
			call_app(app_name)
		end)
	end
end

return M
