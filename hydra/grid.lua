ext.grid = {}
ext.grid.BORDER = 2

function ext.grid.fullscreen()
  local win = window.focusedwindow()

  local screenframe = ext.grid.screenframe(win)
  win:setframe(screenframe)
end

function ext.grid.lefthalf()
  local win = window.focusedwindow()

  local screenframe = ext.grid.screenframe(win)
  local newframe = {
    x = screenframe.x,
    y = screenframe.y,
    w = screenframe.w / 2 - ext.grid.BORDER,
    h = screenframe.h,
  }

  win:setframe(newframe)
end

function ext.grid.lrec()
    local w = window.focusedwindow()
    local x = w:frame()

    local n = {
        x = x.x + 20,
        y = x.y,
        w = x.w - 20,
        h = x.h
    }
    w:setframe(n)
 end

function ext.grid.linc()
    local w = window.focusedwindow()
    local s = ext.grid.screenframe(w)
    local x = w:frame()
    local n = {
        x = x.x - 20,
        y = x.y,
        w = x.w + 20,
        h = x.h
    }

    w:setframe(n)
end

function ext.grid.righthalf()
  local win = window.focusedwindow()

  local screenframe = ext.grid.screenframe(win)
  local newframe = {
    x = screenframe.x + screenframe.w / 2 + ext.grid.BORDER,
    y = screenframe.y,
    w = screenframe.w / 2 - ext.grid.BORDER,
    h = screenframe.h,
  }

  win:setframe(newframe)
end

function ext.grid.topleft()
  local win = window.focusedwindow()

  local screenframe = ext.grid.screenframe(win)
  local newframe = {
    x = screenframe.x,
    y = screenframe.y,
    w = screenframe.w / 2 - ext.grid.BORDER,
    h = screenframe.h / 2 - ext.grid.BORDER,
  }

  win:setframe(newframe)
end

function ext.grid.bottomleft()
  local win = window.focusedwindow()

  local screenframe = ext.grid.screenframe(win)
  local newframe = {
    x = screenframe.x,
    y = screenframe.y + screenframe.h / 2 + ext.grid.BORDER,
    w = screenframe.w / 2 - ext.grid.BORDER,
    h = screenframe.h / 2 - ext.grid.BORDER,
  }

  win:setframe(newframe)
end

function ext.grid.topright()
  local win = window.focusedwindow()

  local screenframe = ext.grid.screenframe(win)
  local newframe = {
    x = screenframe.x + screenframe.w / 2 + ext.grid.BORDER,
    y = screenframe.y,
    w = screenframe.w / 2 - ext.grid.BORDER,
    h = screenframe.h / 2 - ext.grid.BORDER,
  }

  win:setframe(newframe)
end

function ext.grid.bottomright()
  local win = window.focusedwindow()

  local screenframe = ext.grid.screenframe(win)
  local newframe = {
    x = screenframe.x + screenframe.w / 2 + ext.grid.BORDER,
    y = screenframe.y + screenframe.h / 2 + ext.grid.BORDER,
    w = screenframe.w / 2 - ext.grid.BORDER,
    h = screenframe.h / 2 - ext.grid.BORDER,
  }

  win:setframe(newframe)
end

function ext.grid.pushwindow()
  local win = window.focusedwindow()

  local winframe = win:frame()
  local nextscreen = win:screen():next()
  local screenframe = nextscreen:frame_without_dock_or_menu()
  local newframe = {
    x = screenframe.x,
    y = screenframe.y,
    w = winframe.w,
    h = winframe.h,
  }

  win:setframe(newframe)
end

function ext.grid.center()
  local win = window.focusedwindow()
  local screenframe = ext.grid.screenframe(win)
  local f = win:frame()
  f.w = screenframe.w / 2
  f.h = screenframe.h / 2
  f.x = screenframe.x + ((screenframe.w / 2) - (f.w / 2))
  f.y = screenframe.y + ((screenframe.h / 2) - (f.h / 2))
  win:setframe(f)
end


function ext.grid.movecycle()
    local win = window.focusedwindow()
    local s = win:screen():frame_without_dock_or_menu()
    -- Vertical screen 1080 * 1920
    if s.w == 1080 and s.h == 1920 then
        local f = win:frame()
        f.x = s.x
        f.y = f.y + s.h / 3
        if f.y == s.y + s.h  then f.y = s.y  end
        if f.w ~= s.w + 2 and f.h ~= s.h / 3 then f.y = s.y end
        --hydra.alert("s.x" .. s.x .. "s.y" .. s.y .. "f.y" .. f.y)
        --hydra.alert("f.w" .. f.w .. "f.h" .. f.h .. "s.w" .. s.w .. "s.h" .. s.h)
        f.w = s.w 
        f.h = s.h / 3 
        win:setframe(f)
    else
        hydra.alert("Screen not dell u2312hm!", 0.5)
    end 
end

function ext.grid.move4cycle()
    local win = window.focusedwindow()
    local s = ext.grid.screenframe(win)
    local f = win:frame()
    if s.w > s.h then 
        if ( f.x ~= s.x and f.x ~= s.x + s.w / 2 ) or (f.y ~= s.y and f.y ~= s.y + s.h / 2 ) then
            --hydra.alert("x" .. f.x .. "   y  " .. f.y .. " s.x " .. s.x .. "s.y " .. s.y  )
            f.x = s.x
            f.y = s.y
        else 
            if f.x == s.x and f.y == s.y then f.x = s.w / 2 + s.x
            elseif f.x == s.w / 2 + s.x and f.y == s.y then 
                f.x = s.w / 2 + s.x; f.y = s.h / 2 + s.y;
            elseif f.x == s.w / 2 + s.x and f.y == s.h / 2 + s.y then f.x = s.x;
            elseif f.x == s.x and f.y == s.h / 2 + s.y  then f.x = s.x; f.y = s.y;
            end
        end
        f.w = s.w / 2 
        f.h = s.h / 2 
        win:setframe(f)
    else
        hydra.alert("Screen sould in horizonal")
    end
end

function ext.grid.screenframe(win)
  return win:screen():frame_without_dock_or_menu()
end
