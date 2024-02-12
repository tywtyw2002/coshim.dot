local M = {
    max_key = 1,
    exit_on_key = true,
    show_enter = true,
    show_exit = false,
    show_helper = false,

    -- display config
    helper_timeout = 30,
    helper_entry_per_line = 5,
    helper_entry_length = 20,
    helper_format = {
        atScreenEdge = 2,
        strokeColor = { white = 0, alpha = 2 },
        textFont = "SF Mono",
        textSize = 20,
    },
}

local MOD_MAPPING = {
    command = "⌘",
    cmd = "⌘",
    control = "⌃",
    ctrl = "⌃",
    option = "⌥",
    alt = "⌥",
    shift = "⇧",
}

local function keyboardUpper(key)
    local upperTable = {
        a = "A",
        b = "B",
        c = "C",
        d = "D",
        e = "E",
        f = "F",
        g = "G",
        h = "H",
        i = "I",
        j = "J",
        k = "K",
        l = "L",
        m = "M",
        n = "N",
        o = "O",
        p = "P",
        q = "Q",
        r = "R",
        s = "S",
        t = "T",
        u = "U",
        v = "V",
        w = "W",
        x = "X",
        y = "Y",
        z = "Z",
        ["`"] = "~",
        ["1"] = "!",
        ["2"] = "@",
        ["3"] = "#",
        ["4"] = "$",
        ["5"] = "%",
        ["6"] = "^",
        ["7"] = "&",
        ["8"] = "*",
        ["9"] = "(",
        ["0"] = ")",
        ["-"] = "_",
        ["="] = "+",
        ["["] = "}",
        ["]"] = "}",
        ["\\"] = "|",
        [";"] = ":",
        ["'"] = '"',
        [","] = "<",
        ["."] = ">",
        ["/"] = "?",
    }
    local uppperKey = upperTable[key]
    if uppperKey then
        return uppperKey
    else
        return key
    end
end

local function format_key_name(mod, key)
    -- key is in the form {{modifers}, key, (optional) name}
    -- create proper key name for helper
    -- add a little mapping for space
    if key == "space" then
        key = "SPC"
    end
    if #mod == 1 and mod[1] == "shift" and string.len(key) == 1 then
        -- shift + key map to Uppercase key
        -- shift + d --> D
        -- if key is not on letter(space), don't do it.
        return keyboardUpper(key)
    else
        -- append each modifiers together
        local name = ""
        if #mod >= 1 then
            for count = 1, #mod do
                local modifier = mod[count]
                if count == 1 then
                    name = MOD_MAPPING[modifier] .. " + "
                else
                    name = name .. MOD_MAPPING[modifier] .. " + "
                end
            end
        end
        -- finally append key, e.g. 'f', after modifers
        return name .. key
    end
end

function M:init(conf)
    conf = conf or {}
    setmetatable(conf, self)
    self.__index = self

    conf.helper_id = nil
    conf.timer = nil
    conf.keymaps = {}

    conf.helper_cache = nil

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
end

function M:bind(mod, key, msg, fn)
    if msg ~= "" then
        local name = format_key_name(mod, key)
        table.insert(self.keymaps, { name, msg })
    end
    self.k:bind(mod, key, self:callback_bind(fn))
end

function M:callback_enter()
    self.count = 0

    if self.show_helper then
        self:display_helper()
    elseif self.show_enter and self.message then
        hs.alert.show(self.message)
    end
end

function M:callback_exit()
    if self.helper_id then
        hs.alert.closeSpecific(self.helper_id)
    end

    if self.timer then
        self.timer:stop()
        self.timer = nil
    end

    if not self.show_helper and self.show_exit and self.exit_message then
        hs.alert.show(self.exit_message)
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
        if self.count == self.max_key then
            self.k:exit()
        end
    end
end

function M:build_helper_cache()
    local helper = ""
    local separator = ""
    local count = 0
    for _, data in ipairs(self.keymaps) do
        local key, msg = table.unpack(data)
        count = count + 1
        local new_entry = key .. " → " .. msg
        -- make sure each entry is of the same length
        if string.len(new_entry) > self.helper_entry_length then
            new_entry = string.sub(new_entry, 1, self.helper_entry_length - 2)
                .. ".."
        elseif string.len(new_entry) < self.helper_entry_length then
            new_entry = new_entry
                .. string.rep(
                    " ",
                    self.helper_entry_length - string.len(new_entry)
                )
        end
        -- create new line for every helperEntryEachLine entries
        if count == 1 then
            separator = " "
        elseif (count - 1) % self.helper_entry_per_line == 0 then
            separator = "\n "
        else
            separator = "  "
        end
        helper = helper .. separator .. new_entry
    end
    self.helper_cache = string.match(helper, "[^\n].+$")
end

function M:display_helper()
    if not self.show_helper then
        return
    end

    if self.helper_cache == nil then
        self:build_helper_cache()
    end

    self.helper_id = hs.alert.show(
        self.helper_cache,
        self.helper_format,
        self.helper_timeout
    )
    self.timer = hs.timer.delayed.new(self.helper_timeout, function()
        self.k:exit()
    end)
    self.timer:start()
end

return M
