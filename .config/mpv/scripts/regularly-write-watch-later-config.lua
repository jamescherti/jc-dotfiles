-- Written by myself
local mp = require 'mp'
local interval_write_watch_later_config = 60.0  -- seconds
mp.add_periodic_timer(interval_write_watch_later_config, function()
  mp.command("write-watch-later-config")
  -- mp.osd_message("show-text 'Position updated'")
end)
