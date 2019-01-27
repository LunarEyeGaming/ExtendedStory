--------------------------------------------------------------------------------
destroyerSkyMegaLaserAttack = {}

function destroyerSkyMegaLaserAttack.enter()
  if not hasTarget() then return nil end

  rangedAttack.setConfig(config.getParameter("destroyerSkyMegaLaserAttack.projectile.type"), config.getParameter("destroyerSkyMegaLaserAttack.projectile.config"), config.getParameter("destroyerSkyMegaLaserAttack.fireInterval"))

  return {
    timer = 0,
    bobTime = config.getParameter("destroyerSkyMegaLaserAttack.bobTime"),
    bobHeight = config.getParameter("destroyerSkyMegaLaserAttack.bobHeight"),
    skillTime = config.getParameter("destroyerSkyMegaLaserAttack.skillTime"),
    direction = util.randomDirection(),
    vDirection = util.randomDirection(),
    basePosition = self.spawnPosition,
    cruiseDistance = config.getParameter("cruiseDistance")
  }
end

function destroyerSkyMegaLaserAttack.enteringState(stateData)
  monster.setActiveSkillName(nil)
end

function destroyerSkyMegaLaserAttack.update(dt, stateData)
  mcontroller.controlFace(1)
  if not hasTarget() then return true end

  local projectileOffset = config.getParameter("destroyerSkyMegaLaserAttack.projectileOffset")

  local toTarget = vec2.norm(world.distance(self.targetPosition, monster.toAbsolutePosition(projectileOffset)))
  rangedAttack.aim(projectileOffset, toTarget)
  rangedAttack.fireContinuous()

  local position = mcontroller.position()

  local toTarget = world.distance(self.targetPosition, position)
  if toTarget[1] < -stateData.cruiseDistance then
    stateData.direction = -1
  elseif toTarget[1] > stateData.cruiseDistance then
    stateData.direction = 1
  end
  
  if toTarget[2] < -stateData.cruiseDistance then
    stateData.vDirection = -1
  elseif toTarget[2] > stateData.cruiseDistance then
    stateData.vDirection = 1
  end

  stateData.timer = stateData.timer + dt
  local angle = 2.0 * math.pi * stateData.timer / stateData.bobTime
  local targetPosition = {
    position[1] + stateData.direction * 5,
    position[2] + stateData.vDirection * 5
  }
  flyTo(targetPosition)

  if stateData.timer > stateData.skillTime then
    return true
  else
    return false
  end
end

function destroyerSkyMegaLaserAttack.leavingState(stateData)
end
