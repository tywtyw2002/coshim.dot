-- Perceptive, a weather notification module for Awesome WM.
--
-- Author: Ilia Glazkov
local awful = require('awful')
local naughty = require("naughty")
local timer = timer
local io = require("io")
local string = string
local print = print

module('perceptive')

local script_path = awful.util.getdir("config") .. '/weather-fetcher.py'
local script_cmd = script_path
local tmpfile = '/tmp/.awesome.weather'
local weather_data = ""
local notification = nil
local pattern = '%a.+'
local w_date = ""

function execute(cmd, output, callback)
    -- Executes command line, writes its output to temporary file, and
    -- runs the callback with output as an argument.
    local cmdline = cmd .. " > " .. output
    io.popen(cmdline):close()

    local execute_timer = timer({ timeout = 7 })
    execute_timer:connect_signal("timeout", function()
        execute_timer:stop()
        local f = io.open(output)
        callback(f:read("*all"))
        f:close()
    end)
    execute_timer:start()
end

function fetch_weather(wi)
    execute(script_cmd, tmpfile, function(text)
        old_weather_data = weather_data
        weather_data = string.gsub(text, "[\n]$", "")
        if notification ~= nil and old_weather_data ~= weather_data then
            show_notification()
        end
        wi:set_text(string.gsub(weather_data, "Now: ([^.]*)%.", "%1"))
    end)
end


function remove_notification()
    if notification ~= nil then
        naughty.destroy(notification)
        notification = nil
    end
end


function show_notification()
    remove_notification()
    notification = naughty.notify({
        text = weather_data,
        font = "monospace 9",
        --screen = mouse.screen,
    })
end


function register(widget)
    update_timer = timer({ timeout = 600 })
    update_timer:connect_signal("timeout", function()
        fetch_weather(widget)
        --show_current(widget)
    end)
    update_timer:start()
    fetch_weather(widget)
    --show_current(widget)


    widget:connect_signal("mouse::enter", function()
        show_notification()
    end)
    widget:connect_signal("mouse::leave", function()
        remove_notification()
    end)
end
