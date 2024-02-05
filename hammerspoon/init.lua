hs.window.animationDuration = 0

local W = require("libs.ws_manager")

local mash = { 'cmd', 'ctrl' }
local mash_shift = { 'cmd', 'ctrl', 'shift' }


hs.hotkey.bind(mash, 'L', function()
    W.shift(W.DIRECTION_RIGHT)
end)

hs.hotkey.bind(mash, 'H', function()
    W.shift(W.DIRECTION_LEFT)
end)

hs.hotkey.bind(mash, 'J', function()
    W.shift(W.DIRECTION_DOWN)
end)

hs.hotkey.bind(mash, 'K', function()
    W.shift(W.DIRECTION_UP)
end)


hs.hotkey.bind(mash, 'I', function()
    W.resize_to()
end)

hs.hotkey.bind(mash, 'O', function() W.move_to_next_screen() end)
hs.hotkey.bind(mash_shift, 'O', function() W.center_cursor() end)

hs.hotkey.bind(mash, 'M', function()
    W.fullscreen()
end)

hs.hotkey.bind(mash, '3', function()
    W.to_tile(W.TILE_THIRD)
end)

hs.hotkey.bind(mash, '2', function()
    W.to_tile(W.TILE_HALF)
end)

hs.hotkey.bind(mash, '1', function()
    W.to_tile(W.TILE_FULL)
end)

hs.hotkey.bind(mash, 'E', function()
    hs.hints.windowHints()
end)

hs.hotkey.bind(mash, '=', function()
    W.step_resize(W.RESIZE_INCREASE, W.RESIZE_HORIZON)
end)

hs.hotkey.bind(mash, '-', function()
    W.step_resize(W.RESIZE_DECREASE, W.RESIZE_HORIZON)
end)

hs.hotkey.bind(mash, ']', function()
    W.step_resize(W.RESIZE_INCREASE, W.RESIZE_VERTICAL)
end)

hs.hotkey.bind(mash, '[', function()
    W.step_resize(W.RESIZE_DECREASE, W.RESIZE_VERTICAL)
end)

hs.hotkey.bind(mash_shift, 'H', function() hs.window.focusedWindow():focusWindowWest() end)
hs.hotkey.bind(mash_shift, 'L', function() hs.window.focusedWindow():focusWindowEast() end)
hs.hotkey.bind(mash_shift, 'K', function() hs.window.focusedWindow():focusWindowNorth() end)
hs.hotkey.bind(mash_shift, 'J', function() hs.window.focusedWindow():focusWindowSouth() end)
