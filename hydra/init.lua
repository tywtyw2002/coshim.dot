dofile(package.searchpath("grid", package.path))
dofile(package.searchpath("menuconfig", package.path))

--set autostart 
hydra.autolaunch.set(true)

--watch for change
pathwatcher.new(os.getenv("HOME") .. "/.hydra/", hydra.reload):start()

--notify on start
hydra.alert("CosHiM Start!", 1)



mod = {"cmd", "ctrl"}
mod2 = {"cmd", "ctrl", "alt"}
mod3 = {"cmd", "ctrl", "shift"}

--hotkey.bind({"cmd","alt"}, "R", function() repl.open(); logger.show() end)
hotkey.bind(mod2, "L", ext.grid.righthalf)
hotkey.bind(mod2, "H", ext.grid.lefthalf)
hotkey.bind(mod2, "K", ext.grid.fullscreen)
hotkey.bind(mod2, "P", ext.grid.pushwindow)
hotkey.bind(mod2, "J", ext.grid.center)
hotkey.bind(mod2, "O", ext.grid.movecycle)
hotkey.bind(mod2, "U", ext.grid.move4cycle)
hotkey.bind(mod2, "N", ext.grid.linc)
hotkey.bind(mod2, "M", ext.grid.lrec)
    

hotkey.bind(mod3, "H", function() window.focusedwindow():focuswindow_west() end)
hotkey.bind(mod3, "J", function() window.focusedwindow():focuswindow_south() end)
hotkey.bind(mod3, "K", function() window.focusedwindow():focuswindow_north() end)
hotkey.bind(mod3, "L", function() window.focusedwindow():focuswindow_east() end)


hotkey.bind(mod, 'T', function() application.launchorfocus("iTerm") end)
hotkey.bind(mod, 'R', function() application.launchorfocus("Terminal") end)
hotkey.bind(mod, "P", function() application.launchorfocus("preview") end)
hotkey.bind(mod, "C", function() application.launchorfocus("Google Chrome") end)
hotkey.bind(mod, "F", function() application.launchorfocus("Finder") end)
