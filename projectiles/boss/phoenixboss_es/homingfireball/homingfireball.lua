require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  local players = world.entityQuery(entity.position(), 200, {includedTypes = {"player"}})
  players = util.filter(shuffled(players), function(entityId)
      return not world.lineTileCollision(entity.position(), world.entityPosition(entityId))
    end)
  self.controlForce = config.getParameter("controlForce")
  self.maxSpeed = config.getParameter("maxSpeed")
  self.target = players[1]
end

function update(dt)
  mcontroller.setRotation(math.atan(mcontroller.velocity()[2], mcontroller.velocity()[1]))
  if self.target and world.entityExists(self.target) then
    local toTarget = world.distance(world.entityPosition(self.target), mcontroller.position())
    toTarget = vec2.norm(toTarget)

    if not self.initialTargetDir then
      self.initialTargetDir = { util.toDirection(toTarget[1]), util.toDirection(toTarget[2]) }
    end

    if vec2.dot(self.initialTargetDir, toTarget) < 0 then
      self.passedTarget = true
    end

    if not self.passedTarget then
      mcontroller.approachVelocity(vec2.mul(toTarget, self.maxSpeed), self.controlForce)
    end
  end
end
