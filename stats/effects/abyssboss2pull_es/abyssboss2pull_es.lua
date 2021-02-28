require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.monsterUniqueId = config.getParameter("monsterUniqueId")
  self.pullSpeed = config.getParameter("pullSpeed", 1)
  self.pullOffset = config.getParameter("pullOffset", {0, 0})
  self.findMonster = util.uniqueEntityTracker(self.monsterUniqueId, 0.2)
end

function update(dt)
  local monsterPosition = self.findMonster()
  if monsterPosition then
    local pullPosition = vec2.add(monsterPosition, self.pullOffset)
    local aimVector = vec2.norm(world.distance(pullPosition, mcontroller.position()))
    mcontroller.setVelocity(vec2.mul(aimVector, self.pullSpeed))
  end
  mcontroller.controlParameters({
    collisionEnabled = false
  })
end

function uninit()
  
end
