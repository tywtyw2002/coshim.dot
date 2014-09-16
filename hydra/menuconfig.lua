dofile(package.searchpath("updateconfig", package.path))

-- show a helpful menu
hydra.menu.show(function()
    return {
      {title = "Reload Config", fn = hydra.reload},
      {title = "Open REPL",fn = repl.open},
      {title = "-"},
      {title = "About", fn = hydra.showabout},
      {title = "Check for Updates...", fn = function() hydra.updates.check(nil, true) end},
      {title = "Quit Hydra", fn = os.exit},
    }
end)
