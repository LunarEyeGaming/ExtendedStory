require "/scripts/stagehandutil.lua"
require "/scripts/extendedstoryutil.lua"


function init()
  message.setHandler("placeDungeon", function()
    world.placeDungeon(config.getParameter("dungeonType"), entity.position())
  end)
end

function update(dt)
end