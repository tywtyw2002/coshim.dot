hs.window.animationDuration = 0

-- Get list of screens and refresh that list whenever screens are plugged or unplugged:
local screens = hs.screen.allScreens()
local screenwatcher = hs.screen.watcher.new(function()
	screens = hs.screen.allScreens()
end)
screenwatcher:start()

mash = {'cmd', 'ctrl'}
mash_shift = {'cmd', 'ctrl', 'shift'}


hs.hotkey.bind(mash, 'L', function()
    --push(0.5, 0, 0.5, 1)
    shift(1)
end)

hs.hotkey.bind(mash, 'H', function()
    --push(0, 0, 0.5, 1)
   shift(0)
end)

-- Loop without change size
hs.hotkey.bind(mash, 'J', function()
    shift(-1)
end)

hs.hotkey.bind(mash, 'I', function()
    resize_1440_800()
end)

hs.hotkey.bind(mash, 'O', function() nextscreen() end)

hs.hotkey.bind(mash, 'M', function()
    push(0, 0, 1, 1)
end)

hs.hotkey.bind(mash, '3', function()
    resize(3)
end)

hs.hotkey.bind(mash, '2', function()
    resize(2)
end)

hs.hotkey.bind(mash, '1', function()
    resize(1)
end)

hs.hotkey.bind(mash, 'E', function()
    hs.hints.windowHints()
end)

hs.hotkey.bind(mash, '=', function()
    change_size()
end)

hs.hotkey.bind(mash, '-', function()
   change_size(true)
end)

hs.hotkey.bind(mash_shift, 'H', function() hs.window.focusedWindow():focusWindowWest() end)
hs.hotkey.bind(mash_shift, 'L', function() hs.window.focusedWindow():focusWindowEast() end)
hs.hotkey.bind(mash_shift, 'K', function() hs.window.focusedWindow():focusWindowNorth() end)
hs.hotkey.bind(mash_shift, 'J', function() hs.window.focusedWindow():focusWindowSouth() end)


function change_size(reduce)
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen():frame()

    -- do not do anything if fullscreen
    if not reduce and screen.w == f.w then
        return
    end

    if reduce and f.w <= screen.w * 0.15 then
        return
    end

    local si = screen.w * 0.05 * (reduce and -1 or 1)

    -- check window right to screen
    if f.w + f.x == screen.w then
        f.x = f.x - si
    end

    f.w = f.w + si
    if f.w > screen.w then
        f.w = screen.w
        f.x = 0
    end
    win:setFrame(f)
end

function getWinframePercent(h)
    return math.floor(h * 100 + 0.5)
end


function shift(side)
    --- side = {0, 1}
    --- 0: left
    --- 1: right
    --- -1: Do not change side
    local win = hs.window.focusedWindow()
    local screen = win:screen():frame()
    local tiled = true
    local moveside = false
    local resize = true

    if side == -1 then
        resize = false
    end

    unitframe = win:frame():toUnitRect(screen)

    if unitframe.x ~= 0 and unitframe.x ~= 0.5 then
        tiled = false
    end

    if tiled and unitframe.x == 0.5 * (side ~ 1) then
        moveside = true
    end

    if resize then
        -- set window side (x)
        unitframe.x = 0.5 * side

        -- set window width (w)
        unitframe.w = 0.5
    else
        unitframe.x = 0
    end

    frameH = getWinframePercent(unitframe.h)
    frameY = getWinframePercent(unitframe.y)
    --print(string.format("H: %d Y: %d, T: %s", frameH, frameY, tiled))
    --print(moveside)

    if not tiled then
        frameH = 100
    end

    if not moveside then
        unitframe.y = 0
    end

    -- 1/2 height case
    if frameH >= 48 and frameH <= 52 then
        unitframe.h = 0.5
        if moveside then;
        elseif frameY == 0 then
            unitframe.y = 0.5
        end

    -- 1/3 height case
    elseif frameH >= 32 and frameH <= 35 then
        unitframe.h = 0.33
        if moveside then;
        elseif frameY == 0 then
            unitframe.y = 0.33
        elseif frameY == 33 then
            unitframe.y = 0.66
        end

    -- full height case
    else
        unitframe.h = 1
    end

    -- set windows frame
    win:setFrame(unitframe:fromUnitRect(screen))


--[[    if (f.w ~= max.w * 0.5) then]]
        --f.w = max.w * 0.5
    --end

    --if (f.h ~= max.h) and (f.h ~= math.floor(max.h * 0.5)) and (f.h ~= math.floor(max.h * 0.33)) then
        --f.h = max.h
    --end

    --if (f.x ~= max.x) or (f.x ~= math.floor(max.x * 0.5)) then
        --f.x = max.x + (max.w * side * 0.5)
    --end

    --local y_axis = f.y - max.y
    --if y_axis == 0  then
        --if f.h == math.floor(max.h * 0.5) then
            --f.y = max.y + (max.h * 0.5)
        --elseif f.h == math.floor(max.h * 0.33) then
            --f.y = max.y + (max.h * 0.33)
        --end
    --elseif y_axis == math.floor(max.h * 0.5) or y_axis == math.floor(max.h * 0.66) then
        --f.y = max.y
    --elseif y_axis == math.floor(max.h * 0.33) then
            --f.y = max.y + (max.h * 0.66)
    --else
        --f.y = max.y
    --end

    --f.x = math.floor(f.x)
    --f.y = math.floor(f.y)
    --f.h = math.floor(f.h)
    --f.w = math.floor(f.w)
    --[[win:setFrame(f)]]
end

function resize(h)
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    if h ~= 0 then
        f.h = math.floor(max.h / h )
    end

    if f.x < math.floor(max.x + (max.w * 0.5)) then
        f.x = max.x
    else
       f.x = max.x + (max.w * 0.5)
    end
    f.y = max.y
    win:setFrame(f)
end

function nudge(xpos, ypos)
    local win = hs.window.focusedWindow()
    local f = win:frame()
    f.x = f.x + xpos
    f.y = f.y + ypos
    win:setFrame(f)
end

function push(x, y, w, h)
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w * x)
    f.y = max.y + (max.h * y)
    f.w = max.w * w
    f.h = max.h * h
    win:setFrame(f)
end


function resize_1440_800()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    if screen:fullFrame().w == 1440 then
        f.x = 320
        f.y = 180
        f.w = 800
        f.h = 550
    else
        f.x = max.x
        f.y = max.y
        f.w = 1400
        f.h = 890
    end
    win:setFrame(f)
end


function nextscreen()
    -- move window to next screen.
    local screen_obj = hs.screen.allScreens()

    if #screen_obj < 2 then
        return
    end

    local win = hs.window.focusedWindow()

    s1 = win:screen()
    s2 = win:screen():next()

    win:move(win:frame():toUnitRect(s1:frame()), s2)
    --- w:move(frame:toUnitRect(Screen1:frame), Screen2)
    -- Get relative geom rect of screen screen2:fromUnitRect(frame:toUnitRect(screen1:frame()))
    -- Get absoulte rect of screen frame:toUnitRect(screen:frame)

end
