ancientbossSingleBeamAttack = {}

--------------------------------------------------------------------------------
function ancientbossSingleBeamAttack.enter()
  if not hasTarget() then return nil end

  local direction = util.randomDirection()

  return {
    windupTimer = 0.6,
    timer = config.getParameter("ancientbossSingleBeamAttack.skillTime", 12),
    rotateInterval = config.getParameter("ancientbossSingleBeamAttack.rotateInterval", 12),
    angleRange = direction * math.pi * 1.5,
    initialAngle = direction * math.pi / 4,
    angleAdjustment = -math.pi/2, --Because beams point down at 0 angle
    winddownTimer = 0.6,
    damagePerSecond = config.getParameter("ancientbossSingleBeamAttack.damagePerSecond", 1600),
    bobInterval = 0.5,
    bobHeight = 0.1
  }
end

--------------------------------------------------------------------------------
function ancientbossSingleBeamAttack.enteringState(stateData)
  animator.setAnimationState("firstBeams", "windup")
  animator.setAnimationState("eye", "windup")
  animator.setAnimationState("beamglow", "on")

  ancientbossSingleBeamAttack.rotateBeams(stateData.angleAdjustment + stateData.initialAngle, true)
end

--------------------------------------------------------------------------------
function ancientbossSingleBeamAttack.update(dt, stateData)
  ancientbossSingleBeamAttack.teleporttospawn(dt)
  ancientbossSingleBeamAttack.bob(dt, stateData)

  if stateData.windupTimer > 0 then
    stateData.windupTimer = stateData.windupTimer - dt
    return false
  end

  if stateData.timer > 0 then
    animator.setLightActive("beam1", true)
    animator.setLightActive("beam1-2", true)
    animator.setLightActive("beam2", true)
    animator.setLightActive("beam2-2", true)

    local angleFactor = math.max(0, (stateData.rotateInterval - stateData.timer)) / stateData.rotateInterval
    local angle = stateData.angleRange * angleFactor + stateData.initialAngle

    ancientbossSingleBeamAttack.rotateBeams(stateData.angleAdjustment + angle, true)

    local powerMultiplier = root.evalFunction("monsterLevelPowerMultiplier", monster.level())
    ancientbossSingleBeamAttack.spawnProjectiles(angle, stateData.damagePerSecond * powerMultiplier * dt)

    stateData.timer = stateData.timer - dt
    if stateData.timer < 0 then
      animator.setAnimationState("eye", "winddown")
    end

    return false
  end

  if stateData.winddownTimer > 0 then
    stateData.winddownTimer = stateData.winddownTimer - dt
    return false
  end

  return true
end

function ancientbossSingleBeamAttack.leavingState(stateData)
end

function ancientbossSingleBeamAttack.rotateBeams(angle, instant)
  --Beam 1
  animator.rotateGroup("beam1", angle, instant)
  animator.setLightPosition("beam1", vec2.rotate({0, 32}, angle))
  animator.setLightPosition("beam1-2", vec2.rotate({0, 20}, angle))

  --Beam 2
  animator.rotateGroup("beam2", angle + math.pi, instant)
  animator.setLightPosition("beam2", vec2.rotate({0, 32}, angle + math.pi))
  animator.setLightPosition("beam2-2", vec2.rotate({0, 20}, angle + math.pi))
end

function ancientbossSingleBeamAttack.spawnProjectiles(angle, power)
  for x = 0, 1 do
    local newAngle = angle + math.pi * x
    local aimVector = {-math.cos(newAngle), math.sin(newAngle)}
    world.spawnProjectile("crystalbeamdamage", mcontroller.position(), entity.id(), aimVector, true, {power = power, damageRepeatGroup = "crystalbossbeam"})
  end
end

function ancientbossSingleBeamAttack.bob(dt, stateData)
  local bobFactor = (stateData.bobInterval - (stateData.timer % stateData.bobInterval)) / stateData.bobInterval
  local bobOffset = math.sin(bobFactor * math.pi * 2) * stateData.bobHeight
  local targetPosition = {self.spawnPosition[1], self.spawnPosition[2] + bobOffset}
  local toTarget = world.distance(targetPosition, mcontroller.position())
  

  mcontroller.controlApproachVelocity(vec2.mul(toTarget, 1/dt), 30)
end

function ancientbossSingleBeamAttack.teleporttospawn(dt)
  local waitTime = 0.1
  local spawnBoundbox = {self.spawnPosition[1] + 5, self.spawnPosition[2] + 5, self.spawnPosition[1] - 5, self.spawnPosition[2] - 5}
  if not withinSpawnArea(spawnBoundbox) then
    animator.burstParticleEmitter("teleport")
	animator.playSound("teleportOut")
	ancientbossSingleBeamAttack.wait(dt, waitTime)
    mcontroller.setPosition(self.spawnPosition)
	mcontroller.setVelocity({0, 0})
	animator.burstParticleEmitter("teleport")
	animator.playSound("teleportIn")
  end
end

function withinSpawnArea(area)
  local currentPosition = mcontroller.position()
  if currentPosition[1] <= area[1] and currentPosition[1] >= area[3] and currentPosition[2] <= area[2] and currentPosition[2] >= area[4] then
    return true
  else
    return false
  end
end
function ancientbossSingleBeamAttack.wait(dt, waitTime)
  while waitTime > 0 do
	waitTime = waitTime - dt
  end
end