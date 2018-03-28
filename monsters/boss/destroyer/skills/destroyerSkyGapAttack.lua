--------------------------------------------------------------------------------
destroyerSkyGapAttack = {}

function destroyerSkyGapAttack.enter()
  if not hasTarget() then return nil end

  rangedAttack.setConfig(config.getParameter("destroyerSkyGapAttack.projectile.type"), config.getParameter("destroyerSkyGapAttack.projectile.config"), config.getParameter("destroyerSkyGapAttack.fireInterval"))

  return {
    timer = 0,
    bobTime = config.getParameter("destroyerSkyGapAttack.bobTime"),
    bobHeight = config.getParameter("destroyerSkyGapAttack.bobHeight"),
    skillTime = config.getParameter("destroyerSkyGapAttack.skillTime"),
    direction = util.randomDirection(),
    basePosition = self.spawnPosition,
    cruiseDistance = config.getParameter("cruiseDistance")
  }
end

function destroyerSkyGapAttack.enteringState(stateData)
  monster.setActiveSkillName(nil)
end

function destroyerSkyGapAttack.update(dt, stateData)
  mcontroller.controlFace(1)
  if not hasTarget() then return true end

  local projectileOffset = config.getParameter("destroyerSkyGapAttack.projectileOffset")

  local toTarget = vec2.norm(world.distance(self.targetPosition, monster.toAbsolutePosition(projectileOffset)))
  rangedAttack.aim(projectileOffset, toTarget)
  rangedAttack.fireContinuous()

  local position = mcontroller.position()

  local toTarget = world.distance(self.targetPosition, position)
  if toTarget[1] < -stateData.cruiseDistance or checkWalls(1) then
    stateData.direction = -1
  elseif toTarget[1] > stateData.cruiseDistance or checkWalls(-1) then
    stateData.direction = 1
  end

  stateData.timer = stateData.timer + dt
  local angle = 2.0 * math.pi * stateData.timer / stateData.bobTime
  local targetPosition = {
    position[1] + stateData.direction * 5,
    stateData.basePosition[2] + stateData.bobHeight * math.cos(angle)
  }
  flyTo(targetPosition)

  if stateData.timer > stateData.skillTime then
    return true
  else
    return false
  end
end

function destroyerSkyGapAttack.leavingState(stateData)
end
