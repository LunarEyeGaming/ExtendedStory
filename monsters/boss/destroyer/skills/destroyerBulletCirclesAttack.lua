--------------------------------------------------------------------------------
destroyerBulletCirclesAttack = {}

function destroyerBulletCirclesAttack.enter()
  if not hasTarget() then return nil end

  rangedAttack.setConfig(config.getParameter("destroyerBulletCirclesAttack.projectile.type"), config.getParameter("destroyerBulletCirclesAttack.projectile.config"), config.getParameter("destroyerBulletCirclesAttack.fireInterval"))

  return {
    timer = 0,
    orbitTime = config.getParameter("destroyerBulletCirclesAttack.orbitTime"),
    orbitRadius = config.getParameter("destroyerBulletCirclesAttack.orbitRadius"),
    skillTime = config.getParameter("destroyerBulletCirclesAttack.skillTime"),
    direction = util.randomDirection(),
    vDirection = util.randomDirection(),
    basePosition = self.spawnPosition,
    cruiseDistance = config.getParameter("cruiseDistance")
  }
end

function destroyerBulletCirclesAttack.enteringState(stateData)
  monster.setActiveSkillName(nil)
end

function destroyerBulletCirclesAttack.update(dt, stateData)
  mcontroller.controlFace(1)
  if not hasTarget() then return true end

  local projectileOffset = config.getParameter("destroyerBulletCirclesAttack.projectileOffset")

  local toTarget = vec2.norm(world.distance(self.targetPosition, monster.toAbsolutePosition(projectileOffset)))
  rangedAttack.aim(projectileOffset, toTarget)
  rangedAttack.fireContinuous()

  local position = mcontroller.position()

  stateData.timer = stateData.timer + dt
  local angle = 2.0 * math.pi * stateData.timer / stateData.orbitTime
  local targetPosition = {
    self.targetPosition[1] + stateData.orbitRadius * math.sin(angle),
    self.targetPosition[2] + stateData.orbitRadius * math.cos(angle)
  }
  flyTo(targetPosition)

  if stateData.timer > stateData.skillTime then
    return true
  else
    return false
  end
end

function destroyerBulletCirclesAttack.leavingState(stateData)
end
