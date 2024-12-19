local mp = require 'mp'

-- ALTERNATIVE
-- https://github.com/mpv-player/mpv/issues/9325
local function freeze_geometry(_, dimensions)
    local fullscreen = mp.get_property("fullscreen")
    if fullscreen == "yes" then
      return
    end

    if dimensions.w > 0 then
        -- mp.osd_message("Freeze geometry: " .. tostring(dimensions.w) .. "x" .. tostring(dimensions.h))
        mp.set_property('geometry', dimensions.w .. 'x' .. dimensions.h)
        -- msg.debug("OSD resized: " .. dimensions.w .. "x" .. dimensions.h)
        mp.unobserve_property(freeze_geometry)
    end
end

mp.observe_property('osd-dimensions', 'native', freeze_geometry)
