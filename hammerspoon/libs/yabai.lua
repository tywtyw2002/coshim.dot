local unpack = table.unpack
local KM = require("libs.key_manager")

local yabai = {}

local altctrl = { "alt", "ctrl" }
local altctrls = { "alt", "ctrl", "shift" }

local keymaps = {
    -- Display
    { altctrl, "o", "display --focus next || @YABAI display --focus first" },

    -- Space
    { altctrl, "space", "space --balance" },
    { altctrl, "x", "space --mirror x-axis" },
    { altctrl, "y", "space --mirror y-axis" },
    { altctrl, "r", "space --rotate 90" },
    { altctrl, "l", "space --toggle mission-control" },

    { altctrl, "1", "space --focus 1" },
    { altctrl, "2", "space --focus 2" },
    { altctrl, "3", "space --focus 3" },
    { altctrl, "4", "space --focus 4" },
    { altctrl, "5", "space --focus 5" },
    { altctrl, "6", "space --focus 6" },

    -- windows
    { altctrl, "h", "window --focus west" },
    { altctrl, "l", "window --focus east" },
    { altctrl, "k", "window --focus north" },
    { altctrl, "j", "window --focus south" },

    { altctrl, ".", "window --focus largest" },
    { altctrl, "m", "window --focus mouse" },
    { altctrl, ",", "window --focus recent" },
    { altctrl, "n", "window --focus next || @YABAI window --focus first" },
    { altctrl, "/", "window --focus first" },

    { altctrl, "]", "window --swap largest" },
    { altctrl, "[", "window --swap recent" },
    { altctrl, "p", "window --swap prev" },
    { altctrl, "'", "window --swap mouse" },

    { altctrls, "0", "window --warp first" },
    { altctrls, "9", "window --warp last" },

    -- resize
    { altctrls, "-", "window --resize left:-20:0 --resize right:-20:0" },
    { altctrls, "=", "window --resize left:20:0 --resize right:20:0" },
    { altctrls, "[", "window --resize top:0:-20 --resize bottom:0:-20" },
    { altctrls, "]", "window --resize top:0:20 --resize bottom:0:20" },

    { altctrls, "1", "window --space 1" },
    { altctrls, "2", "window --space 2" },
    { altctrls, "3", "window --space 3" },
    { altctrls, "4", "window --space 4" },
    { altctrls, "5", "window --space 5" },
    { altctrls, "6", "window --space 6" },
}

local options = {
    { "", "b", "space --layout bsp", "Layout: BSP" },
    { "", "f", "space --layout float", "Layout: Float" },
    { "", "c", "space --layout stack", "Layout: Stack" },
    { "", "g", "space --toggle gap --toggle padding", "Toggle Gap" },

    { "", "p", "window --toggle pip", "PIP" },
    { "", "s", "window --toggle split", "Split" },
    { "", "i", "window --toggle sticky", "Sticky" },
    { "", "d", "window --toggle zoom-parent", "Zoom Parent" },
    { "", "m", "window --toggle zoom-fullscreen", "FullScreen" },
    { "", "t", "window --toggle float", "Float" },

    { "", "x", "window --close", "Close Window" },

    { "", "h", "window --insert west", "Insert: West" },
    { "", "l", "window --insert east", "Insert: East" },
    { "", "k", "window --insert north", "Insert: North" },
    { "", "j", "window --insert south", "Insert: South" },
}

function yabai:init()
    local output, status = hs.execute("which yabai", true)
    if status then
        output = string.gsub(output, "%s+", "")
    else
        output = nil
        print("Yabai not found. Modules disabled.")
    end

    local y = { yabai_path = output }
    setmetatable(y, self)
    self.__index = self

    return y
end

function yabai:ok()
    return self.yabai_path ~= nil
end

function yabai:cmd(cmd)
    local y = self.yabai_path .. " -m "
    cmd = y .. cmd:gsub("@YABAI", y)
    local output, status = hs.execute(cmd, false)
    return output, status
end

function yabai:bind_keys()
    if not self:ok() then
        return
    end

    for _, m in ipairs(keymaps) do
        local meta, key, cmd = unpack(m)
        hs.hotkey.bind(meta, key, function()
            self:cmd(cmd)
        end)
    end

    self.kv =
        KM:init({ show_enter = false, show_helper = true, helper_timeout = 10 })
    self.kv:new(altctrl, "\\", "Yabai")
    for _, data in ipairs(options) do
        local meta, key, cmd, msg = unpack(data)
        self.kv:bind(meta, key, msg, function()
            self:cmd(cmd)
        end)
    end
end

return yabai
