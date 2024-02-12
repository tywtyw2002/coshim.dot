local obj = {
    entry_length = 20,
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
                    name = key .. MOD_MAPPING[modifier] .. " + "
                end
            end
        end
        -- finally append key, e.g. 'f', after modifers
        return name .. key
    end
end

function obj:init(conf)
    conf = conf or {}
    setmetatable(conf, self)
    self.__index = self

    conf.canvas = hs.canvas.new({ x = 0, y = 0, h = 0, w = 0 })
    conf.canvas:level(hs.canvas.windowLevels.tornOffMenu)
    conf.canvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = { hex = "#1c1c1e", alpha = 0.85 },
        roundedRectRadii = { xRadius = 10, yRadius = 10 },
    }

    return conf
end

function obj:format_text(txt)
    if txt:len() > self.entry_length then
        return txt:sub(1, self.entry_length - 2) .. "…"
    end
    return txt
end

function obj:insert(o)
    table.insert(self.canvas, o)
end

function obj:add_section(title, entries, x, y)
    local t = {
        type = "text",
        text = self:format_text(title),
        textFont = "SF Mono-Bold",
        textSize = 18,
        textColor = { hex = "#ffffff", alpha = 1 },
        textAlignment = "left",
        frame = {
            x = x * 50,
            y = y * 30,
            w = 50,
            h = 30,
        },
    }
    self:insert(t)

    local keys = ""
    local desc = ""

    for _, data in ipairs(entries) do
        local meta, key, msg = table.unpack(data)
        local key_name = format_key_name(meta, key)

        keys = keys .. key_name .. "\n"
        desc = desc .. self:format_text(msg) .. "\n"
    end

    self:insert({
        type = "text",
        text = keys,
        textFont = "SF Mono-Bold",
        textSize = 16,
        textColor = { hex = "#0A84FF", alpha = 1 },
        textAlignment = "center",
        frame = {
            x = x * 50,
            y = y * 30 + 30,
            w = 15,
            h = 30 * #entries,
        },
    })

    self:insert({
        type = "text",
        text = desc,
        textFont = "SF Mono",
        textSize = 16,
        textColor = { hex = "#EBEBF5", alpha = 1 },
        textAlignment = "center",
        frame = {
            x = x * 50 + 15,
            y = y * 30 + 30,
            w = 35,
            h = 30 * #entries,
        },
    })
end

return obj
