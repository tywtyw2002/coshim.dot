local unpack = table.unpack
local KM = require("libs.key_manager")
local CheatSheet = require("libs.cheatsheet")

local yabai = {}

local altctrl = { "alt", "ctrl" }
local altctrls = { "alt", "ctrl", "shift" }

local keymaps = {
    {
        title = "Navigation",
        hide_cheatsheet = false,
        loc = { 1, 1 }, -- row, col
        binds = {
            {
                altctrls,
                "k",
                "display --focus prev || @YABAI display --focus last",
                "Display: Previous",
            },
            {
                altctrls,
                "j",
                "display --focus next || @YABAI display --focus first",
                "Display: Next",
            },
            { altctrl, "1", "space --focus 1", "Space: Focus [1-4]" },
            { altctrl, "2", "space --focus 2" },
            { altctrl, "3", "space --focus 3" },
            { altctrl, "4", "space --focus 4" },
        },
    },
    {
        title = "Navigation - Window",
        loc = { 2, 1 },
        binds = {
            -- windows
            {
                altctrl,
                ",",
                "window --focus prev || @YABAI window --focus last",
                "Window: Previous",
            },
            {
                altctrl,
                ".",
                "window --focus next || @YABAI window --focus first",
                "Window: Next",
            },

            { altctrl, "g", "window --focus largest", "Window: Largest" },
            { altctrl, "m", "window --focus mouse", "Window: Mouse" },
            { altctrl, "/", "window --focus recent", "Window: Recent" },
            { altctrl, "0", "window --focus first", "Window: First" },
            { altctrl, "9", "window --focus last", "Window: Last" },

            { altctrl, "h", "window --focus west", "Window: Left" },
            { altctrl, "l", "window --focus east", "Window: Right" },
            { altctrl, "k", "window --focus north", "Window: UP" },
            { altctrl, "j", "window --focus south", "Window: Down" },
        },
    },
    {
        title = "Layout - Sapce",
        loc = { 1, 2 },
        binds = {
            { altctrl, "space", "space --balance", "Balance" },
            { altctrl, "x", "space --mirror x-axis", "Mirror - X" },
            { altctrl, "y", "space --mirror y-axis", "Mirror - Y" },
            { altctrl, "r", "space --rotate 90", "Rotate 90" },
            {
                altctrl,
                "a",
                "space --toggle mission-control",
                "Mission Control",
            },
        },
    },
    {
        title = "Layout - Window",
        loc = { 2, 2 },
        binds = {
            {
                altctrl,
                "o",
                "window --display next || @YABAI window --display first",
                "To next Display",
            },
            { altctrl, "'", "window --swap largest", "Swap: Largest" },
            { altctrl, "p", "window --swap prev", "Swap: Previous" },
            { altctrl, "]", "window --swap recent", "Swap: Recent" },
            { altctrl, "[", "window --swap mouse", "Swap: Mouse" },
            { altctrls, "0", "window --warp first", "Warp: First" },
            { altctrls, "9", "window --warp last", "Warp: Last" },
            { altctrls, "1", "window --space 1", "To Space [1-4]" },
            { altctrls, "2", "window --space 2" },
            { altctrls, "3", "window --space 3" },
            { altctrls, "4", "window --space 4" },
            -- win incr/desc
            {
                altctrls,
                "-",
                "window --resize left:-20:0 --resize right:-20:0",
                "Width: Decrease 5%",
            },
            {
                altctrls,
                "=",
                "window --resize left:20:0 --resize right:20:0",
                "Width: Increase 5%",
            },
            {
                altctrls,
                "[",
                "window --resize top:0:-20 --resize bottom:0:-20",
                "Height: Decrease 5%",
            },
            {
                altctrls,
                "]",
                "window --resize top:0:20 --resize bottom:0:20",
                "Height: Increase 5%",
            },
        },
    },
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
    self.cheatsheet = CheatSheet:init()

    _G["DEBUG_CHEATSHEET"] = self.cheatsheet

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

function yabai:bind_keymaps(keymap)
    local binds = keymap.binds
    local entries = {}

    for _, m in ipairs(binds) do
        local meta, key, cmd, msg = unpack(m)
        hs.hotkey.bind(meta, key, function()
            self:cmd(cmd)
        end)
        if msg and msg ~= "" then
            table.insert(entries, { meta, key, msg })
        end
    end

    if not keymap.hide_cheatsheet and keymap.title then
        self.cheatsheet:add_section(
            keymap.title,
            entries,
            keymap.loc[1],
            keymap.loc[2]
        )
    end
end

function yabai:bind_keys()
    if not self:ok() then
        return
    end

    for _, section in ipairs(keymaps) do
        self:bind_keymaps(section)
    end

    -- show cheatsheet
    hs.hotkey.bind(altctrl, "q", function()
        self.cheatsheet:toggle()
    end)

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
