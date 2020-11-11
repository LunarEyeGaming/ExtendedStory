require "/scripts/vec2.lua"

function init()
  self.masterId = config.getParameter("masterId")
  self.followOffset = config.getParameter("followOffset")
end

function update(dt)
  if not self.masterId or not world.entityExists(self.masterId) then return end
  local masterPosition = vec2.add(world.entityPosition(self.masterId), self.followOffset)
  mcontroller.setPosition(masterPosition, self.orbitControlForce)
end