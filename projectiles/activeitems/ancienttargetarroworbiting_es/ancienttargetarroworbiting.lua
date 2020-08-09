require "/scripts/vec2.lua"

function init()
  self.orbitRadius = config.getParameter("orbitRadius")
  self.orbitPeriod = config.getParameter("orbitPeriod")
  self.orbitControlForce = config.getParameter("orbitControlForce")
  self.masterId = config.getParameter("masterId")
  self.startAngle = config.getParameter("startAngle")
  self.orbitAngle = self.startAngle

  self.projectileType = config.getParameter("firedProjectile")
  self.projectileConfig = config.getParameter("firedProjectileConfig")
  self.projectileConfig.power = self.projectileConfig.power or projectile.power()

  message.setHandler("kill", function(_, _, id)
    targetId = id
    projectile.die()
  end)
  
  mcontroller.setVelocity({0, 0})
end

function update(dt)
  if not self.masterId or not world.entityExists(self.masterId) then return end

  if projectile.timeToLive() > 0 then
    projectile.setTimeToLive(0.5)
  end

  self.orbitAngle = self.orbitAngle + (dt * 2 * math.pi / self.orbitPeriod)
  local orbitOffset = vec2.mul({math.cos(self.orbitAngle), math.sin(self.orbitAngle)}, self.orbitRadius)
  local orbitPosition = vec2.add(world.entityPosition(self.masterId), orbitOffset)
  local toOrbitVelocity = vec2.mul(vec2.norm(world.distance(orbitPosition, mcontroller.position())), projectile.getParameter("speed"))
  mcontroller.approachVelocity(toOrbitVelocity, self.orbitControlForce)
end

function destroy()
  local selfPosition = mcontroller.position()
  if projectile.sourceEntity() and world.entityExists(projectile.sourceEntity()) and targetId then
    world.spawnProjectile(self.projectileType, selfPosition, projectile.sourceEntity(), world.distance(world.entityPosition(targetId), selfPosition), false, self.projectileConfig)
    local foundTargetAction = config.getParameter("foundTargetAction")
    if next(foundTargetAction) ~= nil then
      projectile.processAction(foundTargetAction)
    end
  end
end
