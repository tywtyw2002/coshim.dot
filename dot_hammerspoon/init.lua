hs.window.animationDuration = 0

local W = require("libs.ws_manager")
local M = require("libs.mouse")
local KM = require("libs.key_manager")
local app_selector = require("libs.app_selector")

local mash = { "cmd", "ctrl" }
local mash_shift = { "cmd", "ctrl", "shift" }

--[[
Todo:
1. Move windows by grid/step 5% on each direction
2. Chrome tab operation with ModalMgr/hs.hotkey.modal vim style keybinds.
    use Surfingkeys.
3. Hotkey switch to application vim style keybinds.
4. win/mouse focus on each/same screen


https://github.com/ashfinal/awesome-hammerspoon/blob/master/init.lua
https://github.dev/Hammerspoon/Spoons/blob/master/Source/WinWin.spoon/init.lua

https://www.hammerspoon.org/Spoons/ModalMgr.html

--]]

local mouse_km = KM:init({ max_key = 2, show_exit = true })
mouse_km:new(mash, "U", "Mouse", "Normal")
mouse_km:bind("", "F", "", function()
	M.center_cursor()
end)
mouse_km:bind("", "S", "", function()
	M.center_cursor(true)
end)
mouse_km:bind("", "O", "", function()
	M.move_to_next_screen()
end)

local app_km = KM:init({ exit_on_key = false })
app_km:new(mash, "\\", "App Selcect")
local app_map = {
	s = "com.sublimetext.4",
	c = "com.google.Chrome",
	f = "com.apple.finder",
	m = "md.obsidian",
	w = "com.github.wez.wezterm",
    t = "com.googlecode.iterm2"
}

app_selector.init(app_km, app_map)

app_km:bind("", "space", "", function()
	hs.hints.windowHints()
end)

app_km:bind("", "\\", "", function()
	-- show bundleid for focused window
	local fwin = hs.window.focusedWindow()
	if not fwin then
		return
	end
	local bundleid = fwin:application():bundleID()
	hs.alert.show("BundleID: " .. bundleid)
	hs.pasteboard.setContents(bundleid)
end)

hs.hotkey.bind(mash, "L", function()
	W.shift(W.DIRECTION_RIGHT)
end)

hs.hotkey.bind(mash, "H", function()
	W.shift(W.DIRECTION_LEFT)
end)

hs.hotkey.bind(mash, "J", function()
	W.shift(W.DIRECTION_DOWN)
end)

hs.hotkey.bind(mash, "K", function()
	W.shift(W.DIRECTION_UP)
end)

hs.hotkey.bind(mash, "I", function()
	W.resize_to()
end)

hs.hotkey.bind(mash, "O", function()
	W.move_to_next_screen()
end)

hs.hotkey.bind(mash, "M", function()
	W.fullscreen()
end)

hs.hotkey.bind(mash, "3", function()
	W.to_tile(W.TILE_THIRD)
end)

hs.hotkey.bind(mash, "2", function()
	W.to_tile(W.TILE_HALF)
end)

hs.hotkey.bind(mash, "1", function()
	W.to_tile(W.TILE_FULL)
end)

--hs.hotkey.bind(mash, "E", function()
--	hs.hints.windowHints()
--end)

hs.hotkey.bind(mash, "=", function()
	W.step_resize(W.RESIZE_INCREASE, W.RESIZE_HORIZON)
end)

hs.hotkey.bind(mash, "-", function()
	W.step_resize(W.RESIZE_DECREASE, W.RESIZE_HORIZON)
end)

hs.hotkey.bind(mash, "]", function()
	W.step_resize(W.RESIZE_INCREASE, W.RESIZE_VERTICAL)
end)

hs.hotkey.bind(mash, "[", function()
	W.step_resize(W.RESIZE_DECREASE, W.RESIZE_VERTICAL)
end)

hs.hotkey.bind(mash_shift, "H", function()
	hs.window.focusedWindow():focusWindowWest()
end)
hs.hotkey.bind(mash_shift, "L", function()
	hs.window.focusedWindow():focusWindowEast()
end)
hs.hotkey.bind(mash_shift, "K", function()
	hs.window.focusedWindow():focusWindowNorth()
end)
hs.hotkey.bind(mash_shift, "J", function()
	hs.window.focusedWindow():focusWindowSouth()
end)
