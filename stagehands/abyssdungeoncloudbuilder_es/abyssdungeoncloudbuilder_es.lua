require "/scripts/vec2.lua"

function init()
  dungeonType = config.getParameter("dungeonType")
  dungeonDensity = config.getParameter("dungeonDensity")
  dungeonOffset = config.getParameter("dungeonOffset")
  broadcastArea = config.getParameter("broadcastArea")

  dungeonPosition = vec2.add(entity.position(), dungeonOffset)
  for x = broadcastArea[1], broadcastArea[3] do
    for y = broadcastArea[2], broadcastArea[4] do
      chanceVal = math.random()
      if chanceVal < dungeonDensity then
        pos = vec2.add(dungeonPosition, {x, y})
        world.placeDungeon(dungeonType, pos)
      end
    end
  end  
  stagehand.die()
end

function update()
  
end

function uninit()
  
end
