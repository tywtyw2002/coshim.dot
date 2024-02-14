local KM = require("libs.key_manager_next")

local M = {}

local keymaps = {
    {
        --title = "App",
        title = "",
        loc = { 1, 1 },
        binds = {
            { "", "f", "com.apple.finder", "Finder" },
            { "", "m", "md.obsidian", "Obsidian" },
            { "", "c", "com.google.Chrome", "Chrome" },
            {},
            { "", "s", "com.sublimetext.4", "Sublime" },
            { "", "t", "com.googlecode.iterm2", "iTerm2" },
            { "", "w", "com.github.wez.wezterm", "Wezterm" },
            {},
            { "", "\\", "", "Get BundleID" },
            { "", "space", "", "Window Hints" },
        },
    },
}

local function get_app_bundle_id()
    local fwin = hs.window.focusedWindow()
    if not fwin then
        hs.alert.show("Unable to get Bundle ID")
        return
    end
    local bundleid = fwin:application():bundleID()
    hs.alert.show("BundleID: " .. bundleid)
    hs.pasteboard.setContents(bundleid)
end

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

function M:init(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

function M:bind_keys(meta, key)
    self.KM = KM:init({
        helper_title = "Mode: App Selector",
        show_helper = true,
        helper_timeout = 0,
    })
    self.KM:new(meta, key, "App Selector")

    local fn = function(app_name)
        return function()
            call_app(app_name)
        end
    end
    for _, section in ipairs(keymaps) do
        self.KM:bind_keymaps(section, fn)
    end

    -- extra binds
    self.KM:bind("", "space", "", function()
        hs.hints.windowHints()
    end)

    self.KM:bind("", "\\", "", function()
        get_app_bundle_id()
    end)
end

return M
