require "/scripts/status.lua"

function init()
  local nearby = world.entityQuery(mcontroller.position(), 30, {includedTypes = {"monster", "npc"}, order = "nearest"})
  target = nearby[1]
end

function update(dt)
  local pos = world.entityPosition(target)
  mcontroller.setPosition(pos)
end