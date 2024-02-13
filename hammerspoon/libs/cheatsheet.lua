local obj = {
    title = nil,
    entry_length = 25,
    background = { hex = "#08080A", alpha = 0.85 },

    title_color = { hex = "#FFD60A", alpha = 0.8 },
    desc_color = { hex = "#EBEBF5", alpha = 0.8 },
    meta_color = { hex = "#EBEBF5", alpha = 0.6 },
    key_color = { hex = "#EBEBF5", alpha = 0.6 },
    upper_key_color = { hex = "#0A84FF", alpha = 1 },
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

local KEY_SPECIAL_MAP = {
    space = "␣",
    ["return"] = "↩",
    delete = "⌫",
    escape = "⎋",
    ["left"] = "←",
    ["right"] = "→",
    ["up"] = "↑",
    ["down"] = "↓",
    ["home"] = "⇱",
    ["end"] = "⇲",
    ["pageup"] = "⇞",
    ["pagedown"] = "⇟",
    ["tab"] = "⇥",
    ["forwarddelete"] = "⌦",
    ["help"] = "⍰",
    ["clear"] = "⌧",
}

local function keyboardUpper(key)
    local upperTable = {
        A = true,
        B = true,
        C = true,
        D = true,
        E = true,
        F = true,
        G = true,
        H = true,
        I = true,
        J = true,
        K = true,
        L = true,
        M = true,
        N = true,
        O = true,
        P = true,
        Q = true,
        R = true,
        S = true,
        T = true,
        U = true,
        V = true,
        W = true,
        X = true,
        Y = true,
        Z = true,
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
    local colored = false

    if uppperKey then
        if uppperKey == true then
            colored = true
        else
            key = uppperKey
        end
    end

    return key, colored
end

function obj:format_key_string(mod, key, idx)
    local colored = false
    local attrs = {}
    local meta = ""
    local key_font = "SF Mono"

    if KEY_SPECIAL_MAP[key] then
        key = KEY_SPECIAL_MAP[key]
        key_font = nil
    else
        key = key:upper()
    end

    if #mod == 1 and mod[1] == "shift" then
        key, colored = keyboardUpper(key)
    else
        if #mod >= 1 then
            for count = 1, #mod do
                local modifier = mod[count]
                meta = meta .. MOD_MAPPING[modifier]
            end
        end
        meta = meta .. " "
        table.insert(attrs, {
            starts = idx,
            ends = idx + meta:len(),
            attributes = {
                color = self.meta_color,
                font = { size = 16 },
                paragraphStyle = { alignment = "right" },
            },
        })
        idx = idx + meta:len()
    end

    local nsstring = meta .. key
    table.insert(attrs, {
        starts = idx,
        ends = idx + key:len(),
        attributes = {
            color = colored and self.upper_key_color or self.key_color,
            font = { name = key_font, size = 16 },
            -- font = {size = 16},
            paragraphStyle = { alignment = "right" },
        },
    })

    return nsstring, attrs
end

local title_height = 20
local title_padding_top_neg = 10
local base_padding = 25
local padding = 10

function obj:init(conf)
    conf = conf or {}
    setmetatable(conf, self)
    self.__index = self

    conf.canvas = hs.canvas.new({ x = 0, y = 0, h = 0, w = 0 })
    conf.canvas:level(hs.canvas.windowLevels.tornOffMenu)
    conf.canvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = conf.background,
        roundedRectRadii = { xRadius = 10, yRadius = 10 },
    }

    conf.draw_pos = {}
    conf.rendered = false
    conf.row_base_zero = base_padding - padding

    if conf.title then
        conf.canvas[2] = {
            type = "text",
            text = conf.title,
            textSize = 20,
            textColor = conf.title_color,
            textAlignment = "center",
            frame = {
                x = base_padding,
                y = base_padding - title_padding_top_neg,
                w = 0,
                h = title_height + title_padding_top_neg,
            },
        }
        conf.row_base_zero = conf.row_base_zero + title_height
    end

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

local col_width = 240
local col_key_width = 60
local col_desc_width = col_width - col_key_width
local row_height = 19
local nav_height = 25

function obj:add_section(title, entries, row, col)
    local row_base = (self.draw_pos[col] or self.row_base_zero) + padding
    local col_base = (col - 1) * (col_width + base_padding) + base_padding

    local t = {
        type = "text",
        text = self:format_text(title),
        textSize = 18,
        textColor = { hex = "#ffffff", alpha = 1 },
        textAlignment = "left",
        frame = {
            x = col_base,
            y = row_base,
            w = col_width,
            h = nav_height,
        },
    }
    self:insert(t)

    local keys = ""
    local desc = ""
    local key_idx = 1
    local key_attrs = {}

    for _, data in ipairs(entries) do
        local meta, key, msg = table.unpack(data)
        local keystring, attrs = self:format_key_string(meta, key, key_idx)

        keys = keys .. keystring .. "\n"
        for _, attr in ipairs(attrs) do
            table.insert(key_attrs, attr)
        end
        key_idx = key_idx + keystring:len() + 1
        desc = desc .. self:format_text(msg) .. "\n"
    end

    -- keys
    table.insert(key_attrs, 1, keys)
    local ns_key = hs.styledtext.new(key_attrs)

    self:insert({
        type = "text",
        text = ns_key,
        frame = {
            x = col_base + col_desc_width,
            y = row_base + nav_height,
            w = col_key_width,
            h = row_height * #entries,
        },
    })

    -- desc
    self:insert({
        type = "text",
        text = desc,
        textSize = 16,
        textColor = self.desc_color,
        textAlignment = "left",
        frame = {
            x = col_base,
            y = row_base + nav_height,
            w = col_desc_width,
            h = row_height * #entries,
        },
    })

    self.draw_pos[col] = row_base + #entries * row_height + nav_height
end

function obj:show()
    if not self.rendered then
        self.rendered = true
        local max_x, max_y = 0, 0
        for col, y in pairs(self.draw_pos) do
            if y > max_y then
                max_y = y
            end
            if col > max_x then
                max_x = col
            end
        end
        local w = col_width * max_x
            + (max_x - 1) * base_padding
            + base_padding * 2
        self.canvas:frame({
            x = 0,
            y = 0,
            w = w,
            h = max_y + base_padding,
        })
        --reszie title w
        if self.title then
            self.canvas[2]["frame"]["w"] = w - base_padding * 2
        end
    end
    self.canvas:show()
end

function obj:toggle()
    if self.canvas:isShowing() then
        self.canvas:hide()
    else
        self:show()
    end
end

function obj:hide()
    if self.canvas:isShowing() then
        self.canvas:hide()
    end
end

return obj
