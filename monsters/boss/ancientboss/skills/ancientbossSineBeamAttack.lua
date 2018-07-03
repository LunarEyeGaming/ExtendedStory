ancientbossSineBeamAttack = {}

--------------------------------------------------------------------------------
function ancientbossSineBeamAttack.enter()
  if not hasTarget() then return nil end
  return {
    windupTimer = 0.6,
    timer = config.getParameter("ancientbossSineBeamAttack.skillTime", 12),
    rotateInterval = config.getParameter("ancientbossSineBeamAttack.rotateInterval", 12),
    angleRange = 1.5,
    initialAngle = math.pi / 4,
    winddownTimer = 0.6,
    bobInterval = 0.5,
    bobHeight = 0.1
  }
end

--------------------------------------------------------------------------------
function ancientbossSineBeamAttack.enteringState(stateData)
  animator.setAnimationState("secondBeams", "windup")
  animator.setAnimationState("eye", "windup")
  animator.setAnimationState("beamglow", "on")

  ancientbossSineBeamAttack.damagePerSecond = config.getParameter("ancientbossSineBeamAttack.damagePerSecond")

  ancientbossSineBeamAttack.rotateBeams(math.pi/4, true)
end

--------------------------------------------------------------------------------
function ancientbossSineBeamAttack.update(dt, stateData)
  ancientbossSineBeamAttack.bob(dt, stateData)

  if stateData.windupTimer > 0 then
    stateData.windupTimer = stateData.windupTimer - dt
    return false
  end

  if stateData.timer > 0 then
    ancientbossSineBeamAttack.setBeamLightsActive(true)
    stateData.timer = stateData.timer - dt

    local angleFactor = (stateData.timer % stateData.rotateInterval) / stateData.rotateInterval
    local angle = stateData.angleRange * math.sin(angleFactor * math.pi * 2) + stateData.initialAngle

    ancientbossSineBeamAttack.rotateBeams(angle, true)

    local powerMultiplier = root.evalFunction("monsterLevelPowerMultiplier", monster.level())
    ancientbossSineBeamAttack.spawnProjectiles(angle, ancientbossSineBeamAttack.damagePerSecond * powerMultiplier * dt)

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

function ancientbossSineBeamAttack.leavingState(stateData)
end

function ancientbossSineBeamAttack.rotateBeams(angle, instant)
  --Beam 1
  animator.rotateGroup("beam1", angle, instant)
  ancientbossSineBeamAttack.setBeamLightPosition("beam1", angle)

  --Beam 2
  animator.rotateGroup("beam2", angle + math.pi * 0.5, instant)
  ancientbossSineBeamAttack.setBeamLightPosition("beam2", angle + math.pi * 0.5)

  --Beam 3
  animator.rotateGroup("beam3", angle + math.pi, instant)
  ancientbossSineBeamAttack.setBeamLightPosition("beam3", angle + math.pi)

  --Beam 4
  animator.rotateGroup("beam4", angle + math.pi * 1.5, instant)
  ancientbossSineBeamAttack.setBeamLightPosition("beam4", angle + math.pi * 1.5)
end

function ancientbossSineBeamAttack.spawnProjectiles(angle, power)
  for x = 0, 3 do
    local newAngle = angle + math.pi * x * 0.5
    local aimVector = {-math.cos(newAngle), math.sin(newAngle)}
    world.spawnProjectile("crystalbeamdamage", mcontroller.position(), entity.id(), aimVector, true, {power = power, damageRepeatGroup = "crystalbossbeam"})
  end
end

function ancientbossSineBeamAttack.setBeamLightsActive(active)
  animator.setLightActive("beam1", active)
  animator.setLightActive("beam1-2", active)
  animator.setLightActive("beam2", active)
  animator.setLightActive("beam2-2", active)
  animator.setLightActive("beam3", active)
  animator.setLightActive("beam3-2", active)
  animator.setLightActive("beam4", active)
  animator.setLightActive("beam4-2", active)
end

function ancientbossSineBeamAttack.setBeamLightPosition(light, angle)
  animator.setLightPosition(light, vec2.rotate({0, 32}, angle))
  animator.setLightPosition(light.."-2", vec2.rotate({0, 20}, angle))
end

function ancientbossSineBeamAttack.bob(dt, stateData)
  local bobFactor = (stateData.bobInterval - (stateData.timer % stateData.bobInterval)) / stateData.bobInterval
  local bobOffset = math.sin(bobFactor * math.pi * 2) * stateData.bobHeight
  local targetPosition = {self.spawnPosition[1], self.spawnPosition[2] + bobOffset}
  local toTarget = world.distance(targetPosition, mcontroller.position())

  mcontroller.controlApproachVelocity(vec2.mul(toTarget, 1/dt), 30)
end
