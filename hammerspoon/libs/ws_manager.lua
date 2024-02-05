local M = {}

local function getWinframePercent(h)
    return math.floor(h * 100 + 0.5)
end

local tiled_label = {
    ['HALF'] = 'HALF',
    ['THIRD'] = 'THIRD',
    ['FULL'] = 'FULL',
    ['NONE'] = 'NONE'
}

local function isTiledWindow(height)
    local frameH = getWinframePercent(height)
    local result = -height
    local label = tiled_label.NONE

    -- half height case
    if frameH >= 48 and frameH <= 52 then
        result = 0.5
        label = tiled_label.HALF

        -- 1/3 height case
    elseif frameH >= 32 and frameH <= 35 then
        result = 0.33
        label = tiled_label.THIRD

    elseif frameH >= 95 then
        result = 1
        label = tiled_label.FULL
    end

    return label, result
end

local function isOnBottom(unitframe)
    return math.ceil(unitframe.y + unitframe.h) == 1
end


M.DIRECTION_LEFT = 0
M.DIRECTION_RIGHT = 1
M.DIRECTION_UP = 2
M.DIRECTION_DOWN = 3

-- shift
-- Left/Right, first time move windows to side.
-- Second time, move window to top.
-- Third time, tiled widnow.
M.shift = function(direction)
    if direction > M.DIRECTION_RIGHT then
        return M.shift_v(direction)
    end

    local win = hs.window.focusedWindow()
    if not win then return end
    --local screen = win:screen()
    local frame = win:screen():frame()
    local unitframe = win:frame():toUnitRect(frame)

    -- check window on side. First run
    if direction == M.DIRECTION_LEFT and unitframe.x ~= 0 then
        unitframe.x = 0
        win:setFrame(unitframe:fromUnitRect(frame))
        return
    elseif direction == M.DIRECTION_RIGHT and (unitframe.x + unitframe.w) ~= 1 then
        unitframe.x = 1 - unitframe.w
        win:setFrame(unitframe:fromUnitRect(frame))
        return
    end

    -- check window on top. Second run
    if unitframe.y ~= 0 then
        unitframe.y = 0
        win:setFrame(unitframe:fromUnitRect(frame))
        return
    end

    -- tiled window. w to half. Third run
    if unitframe.w ~= 0.5 then
        unitframe.w = 0.5
        unitframe.x = direction * 0.5
        win:setFrame(unitframe:fromUnitRect(frame))
    end
end

local T_matix = {
    ['0'] = {[M.DIRECTION_UP]=0.66, [M.DIRECTION_DOWN]=0.33},
    ['1'] = {[M.DIRECTION_UP]=0, [M.DIRECTION_DOWN]=0.66},
    ['2'] = {[M.DIRECTION_UP]=0.33, [M.DIRECTION_DOWN]=0},
    --['N'] = {[M.DIRECTION_UP]=0, [M.DIRECTION_DOWN]=0.66}
    ['N'] = {[M.DIRECTION_UP]=0.66, [M.DIRECTION_DOWN]=0}
}
-- Move windows vertically
-- first tiled move
-- second pass to top/bottom
M.shift_v = function(direction)
    local win = hs.window.focusedWindow()
    if not win then return end
    local frame = win:screen():frame()
    local unitframe = win:frame():toUnitRect(frame)

    local label, new_h = isTiledWindow(unitframe.h)
    local frame_y = getWinframePercent(unitframe.y)

    -- try tiled move
    if new_h > 0 then
        unitframe.h = new_h
        if (label == tiled_label.HALF) then
            if frame_y == 0 then
                unitframe.y = 0.5
            elseif frame_y == 50 then
                unitframe.y = 0
            else
                if direction == M.DIRECTION_DOWN then
                    unitframe.y = 0
                else
                    unitframe.y = 0.5
                end
            end
        elseif(label == tiled_label.THIRD) then
            if frame_y == 0 then
                unitframe.y = T_matix['0'][direction]
            elseif frame_y == 33 then
                unitframe.y = T_matix['1'][direction]
            elseif frame_y >= 65 and frame_y <= 68 then
                unitframe.y = T_matix['2'][direction]
            else
                unitframe.y = T_matix['N'][direction]
            end
        else
            return
        end
        win:setFrame(unitframe:fromUnitRect(frame))
        return
    end

    -- move to top/bottom
    if direction == M.DIRECTION_DOWN and unitframe.y ~= 0 then
        unitframe.y = 0
        win:setFrame(unitframe:fromUnitRect(frame))
    elseif direction == M.DIRECTION_UP and unitframe.y + unitframe.h ~= 1 then
        unitframe.y = 1 - unitframe.h
        win:setFrame(unitframe:fromUnitRect(frame))
    end

end


M.TILE_FULL = tiled_label.FULL
M.TILE_HALF = tiled_label.HALF
M.TILE_THIRD = tiled_label.THIRD

local tile_matrix = {
    [tiled_label.FULL] = 1,
    [tiled_label.HALF] = 2,
    [tiled_label.THIRD] = 3
}

local tile_height = {
    [tiled_label.FULL] = 1,
    [tiled_label.HALF] = 0.5,
    [tiled_label.THIRD] = 0.33
}

-- Make window to half screen width and 1/mode height
M.to_tile = function(mode)
    local win = hs.window.focusedWindow()
    local screen_frame = win:screen():frame()
    local unitframe = win:frame():toUnitRect(screen_frame)

    -- check win tiled status
    local label, new_h = isTiledWindow(unitframe.h)

    if label == mode then
        return
    end

    local on_bottom = isOnBottom(unitframe)
    -- set window height (h)
    unitframe.h = tile_height[mode]

    if mode == tiled_label.FULL then
        unitframe.y = 0
        win:setFrame(unitframe:fromUnitRect(screen_frame))
        return
    end

    -- check y position
    -- check win at bottom and window overflow.
    if on_bottom or unitframe.y + unitframe.h > 1 then
        unitframe.y = 1 - unitframe.h
    end

    win:setFrame(unitframe:fromUnitRect(screen_frame))
end

M.RESIZE_INCREASE = 1
M.RESIZE_DECREASE = 2
M.RESIZE_HORIZON = "H"
M.RESIZE_VERTICAL = "V"

local function step_resize_v(mode)
    local win = hs.window.focusedWindow()
    local screen_frame = win:screen():frame()
    local unitframe = win:frame():toUnitRect(screen_frame)
    local mode_decrease = mode == M.RESIZE_DECREASE

    if not mode_decrease and unitframe.h == 1 then
        return
    end

    if mode_decrease and unitframe.h < 0.15 then
        return
    end

    local unit = 0.05 * (mode_decrease and -1 or 1)
    local on_bottom = isOnBottom(unitframe)

    unitframe.h = unitframe.h + unit

    if unitframe.h > 1 then
        unitframe.h = 1
        unitframe.y = 0
    end

    if on_bottom then
        unitframe.y = 1 - unitframe.h
    end

    win:setFrame(unitframe:fromUnitRect(screen_frame))
end

-- resize window width as +/- 5%
M.step_resize = function(mode, direction)
    if direction == M.RESIZE_VERTICAL then
        return step_resize_v(mode)
    end

    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local screen_frame = win:screen():frame()
    local mode_decrease = mode == M.RESIZE_DECREASE

    -- do not do anything if fullscreen
    if not mode_decrease and screen_frame.w == frame.w then
        return
    end

    if mode_decrease and frame.w <= screen_frame.w * 0.15 then
        return
    end

    local unit = screen_frame.w * 0.05 * (mode_decrease and -1 or 1)

    -- check window right to screen
    if frame.w + frame.x == screen_frame.w then
        frame.x = frame.x - unit
    end

    -- change frame width
    frame.w = frame.w + unit
    if frame.w > screen_frame.w then
        frame.w = screen_frame.w
        frame.x = 0
    end
    win:setFrame(frame)
end

M.resize_to = function(size)
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

M.fullscreen = function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h
    win:setFrame(f)
end

-- Move window to next screen
M.move_to_next_screen = function()
    local screen_obj = hs.screen.allScreens()
    if #screen_obj < 2 then
        return
    end

    local win = hs.window.focusedWindow()

    local s1 = win:screen()
    local s2 = win:screen():next()

    win:move(win:frame():toUnitRect(s1:frame()), s2)
end

-- Move Cursor to center of screen or window
M.center_cursor = function()
    local cwin = hs.window.focusedWindow()
    local wf = cwin:frame()
    local cscreen = cwin:screen()
    local cres = cscreen:frame()
    if cwin then
        -- Center the cursor one the focused window
        hs.mouse.absolutePosition({ x = wf.x + wf.w / 2, y = wf.y + wf.h / 2 })
    else
        -- Center the cursor on the screen
        hs.mouse.absolutePosition({ x = cres.x + cres.w / 2, y = cres.y + cres.h / 2 })
    end
end


return M
