-- save the time when updates are checked
function checkforupdates()
  updates.check(function(available)
    if available then
      notify.show("Hydra update available", "", "Click here to see the changelog and maybe even install it", "showupdate")
    else
      hydra.alert("No update available.")
    end
  end)
  settings.set('lastcheckedupdates', os.time())
end

-- show available updates
local function showupdate()
  os.execute('open https://github.com/sdegutis/Hydra/releases')
end

-- check for updates every week
notify.register("showupdate", showupdate)
timer.new(timer.weeks(1), hydra.updates.check):start()
hydra.updates.check()
