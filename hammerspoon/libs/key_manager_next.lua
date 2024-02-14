local CheatSheet = require("libs.cheatsheet")

local M = {
    max_key = 1,
    exit_on_key = true,
    show_helper = false,

    -- display config
    helper_timeout = 30,
    helper_title = nil,
}

function M:init(conf)
    conf = conf or {}
    setmetatable(conf, self)
    self.__index = self

    conf.timer = nil

    conf.cheatsheet = nil

    return conf
end

function M:new(mods, key, message, exit_message)
    if self.k then
        print("Key Modal already inited.")
    end
    self.message = message
    self.exit_message = exit_message
    local k = hs.hotkey.modal.new(mods, key)
    self.k = k

    k.km = self
    function k:entered()
        self.km:callback_enter()
    end

    function k:exited()
        self.km:callback_exit()
    end

    -- reset init value
    self.count = 0

    -- default key bind
    if self.exit_on_key then
        self.k:bind("", "escape", self:callback_bind())
        self.k:bind("", "space", self:callback_bind())
    end

    if self.show_helper then
        self.cheatsheet = CheatSheet:init({ title = self.helper_title })
    end
end

function M:bind(mod, key, msg, fn)
    self.k:bind(mod, key, self:callback_bind(fn))
end

function M:bind_keymaps(keymap, fn)
    local binds = keymap.binds
    local entries = {}

    for _, m in ipairs(binds) do
        if #m == 0 then
            table.insert(entries, { "", "", "" })
        else
            local meta, key, cmd, msg = table.unpack(m)
            if msg and msg ~= "" then
                table.insert(entries, { meta, key, msg })
            end
            -- process the function
            -- possible to add cheatsheet without binding
            if cmd ~= nil and cmd ~= "" then
                if type(cmd) == "function" then
                    self:bind(meta, key, nil, cmd)
                else
                    self:bind(meta, key, nil, fn(cmd))
                end
            end
        end
    end

    if self.cheatsheet and not keymap.hide_cheatsheet and keymap.title then
        self.cheatsheet:add_section(
            keymap.title,
            entries,
            keymap.loc[1],
            keymap.loc[2]
        )
    end
end

function M:callback_enter()
    self.count = 0

    if self.show_helper then
        self:display_helper()
    end
end

function M:callback_exit()
    if self.cheatsheet then
        self.cheatsheet:hide()
    end

    if self.timer then
        self.timer:stop()
        self.timer = nil
    end
end

function M:callback_bind(fn)
    if fn == nil then
        fn = function()
            self.k:exit()
            self.count = 0
        end
    end
    return function()
        fn()
        self.count = self.count + 1
        if self.count >= self.max_key then
            self.k:exit()
        end
    end
end

function M:start_helper_timer()
    if self.timer then
        self.timer:stop()
    end

    self.timer = hs.timer.delayed.new(self.helper_timeout, function()
        self.k:exit()
    end)
    self.timer:start()
end

function M:display_helper()
    if not self.show_helper then
        return
    end

    self.cheatsheet:show()

    if self.helper_timeout > 0 then
        self:start_helper_timer()
    end
end

return M
