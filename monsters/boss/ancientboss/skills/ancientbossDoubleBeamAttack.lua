ancientbossDoubleBeamAttack = {}

--------------------------------------------------------------------------------
function ancientbossDoubleBeamAttack.enter()
  if not hasTarget() then return nil end

  return {
    windupTimer = 0.6,
    timer = config.getParameter("ancientbossDoubleBeamAttack.skillTime", 8),
    rotateInterval = config.getParameter("ancientbossDoubleBeamAttack.rotateInterval", 8),
    angleRange = math.pi * 0.2,
    initialAngle = math.pi / 4,
    angleAdjustment = -math.pi * 0.5, --Because beams point down at 0 angle
    winddownTimer = 0.6,
    bobInterval = 0.5,
    bobHeight = 0.1
  }
end

--------------------------------------------------------------------------------
function ancientbossDoubleBeamAttack.enteringState(stateData)
  animator.setAnimationState("eye", "windup")
  animator.setAnimationState("beamglow", "on")

  ancientbossDoubleBeamAttack.damagePerSecond = config.getParameter("ancientbossDoubleBeamAttack.damagePerSecond")

  ancientbossDoubleBeamAttack.rotateBeams(stateData.angleAdjustment + stateData.initialAngle, true)
end

--------------------------------------------------------------------------------
function ancientbossDoubleBeamAttack.update(dt, stateData)
  ancientbossDoubleBeamAttack.bob(dt, stateData)

  if stateData.windupTimer > 0 then
    stateData.windupTimer = stateData.windupTimer - dt
    return false
  end

  if stateData.timer > 0 then
    ancientbossDoubleBeamAttack.setBeamLightsActive(true)

    local angleFactor = math.max(0, (stateData.rotateInterval - stateData.timer)) / stateData.rotateInterval
    local angle = ancientbossDoubleBeamAttack.angleFactorFromTime(stateData.timer, stateData.rotateInterval) * stateData.angleRange + stateData.initialAngle

    ancientbossDoubleBeamAttack.rotateBeams(stateData.angleAdjustment + angle, true)

    local powerMultiplier = root.evalFunction("monsterLevelPowerMultiplier", monster.level())
    ancientbossDoubleBeamAttack.spawnProjectiles(angle, ancientbossDoubleBeamAttack.damagePerSecond * powerMultiplier * dt)

    stateData.timer = stateData.timer - dt
    if stateData.timer < 0 then
      animator.setAnimationState("firstBeams", "winddown")
      animator.setAnimationState("secondBeams", "winddown")
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

function ancientbossDoubleBeamAttack.angleFactorFromTime(timer, interval)
  local modTimer = interval - (timer % interval)
  return math.sin(modTimer / interval * math.pi * 2)
end

function ancientbossDoubleBeamAttack.leavingState(stateData)
  animator.setAnimationState("firstBeams", "idle")
  animator.setAnimationState("secondBeams", "idle")
  animator.setAnimationState("beamglow", "off")

  ancientbossDoubleBeamAttack.setBeamLightsActive(false)
end

function ancientbossDoubleBeamAttack.rotateBeams(angle, instant)
  animator.rotateGroup("beam1", angle, instant)
  animator.rotateGroup("beam2", angle + math.pi, instant)
  animator.rotateGroup("beam3", -angle, instant)
  animator.rotateGroup("beam4", -angle + math.pi, instant)
end

function ancientbossDoubleBeamAttack.spawnProjectiles(angle, power)
  --Beam 1 
  local newAngle = angle
  local aimVector = {math.cos(newAngle), math.sin(newAngle)}
  world.spawnProjectile("crystalbeamdamage", mcontroller.position(), entity.id(), aimVector, true, {power = power, damageRepeatGroup = "crystalbossbeam"})
  ancientbossDoubleBeamAttack.setBeamLightPosition("beam1", newAngle)

  --Beam 2
  newAngle = angle + math.pi
  aimVector = {math.cos(newAngle), math.sin(newAngle)}
  world.spawnProjectile("crystalbeamdamage", mcontroller.position(), entity.id(), aimVector, true, {power = power, damageRepeatGroup = "crystalbossbeam"})
  ancientbossDoubleBeamAttack.setBeamLightPosition("beam2", newAngle)
  
  --Beam 3
  newAngle = -angle
  aimVector = {math.cos(newAngle), math.sin(newAngle)}
  world.spawnProjectile("crystalbeamdamage", mcontroller.position(), entity.id(), aimVector, true, {power = power, damageRepeatGroup = "crystalbossbeam"})
  ancientbossDoubleBeamAttack.setBeamLightPosition("beam3", newAngle)
  
  --Beam 4
  newAngle = -angle + math.pi
  aimVector = {math.cos(newAngle), math.sin(newAngle)}
  world.spawnProjectile("crystalbeamdamage", mcontroller.position(), entity.id(), aimVector, true, {power = power, damageRepeatGroup = "crystalbossbeam"})
  ancientbossDoubleBeamAttack.setBeamLightPosition("beam4", newAngle)
end

function ancientbossDoubleBeamAttack.setBeamLightsActive(active)
  animator.setLightActive("beam1", active)
  animator.setLightActive("beam1-2", active)
  animator.setLightActive("beam2", active)
  animator.setLightActive("beam2-2", active)
  animator.setLightActive("beam3", active)
  animator.setLightActive("beam3-2", active)
  animator.setLightActive("beam4", active)
  animator.setLightActive("beam4-2", active)
end

function ancientbossDoubleBeamAttack.setBeamLightPosition(light, angle)
  animator.setLightPosition(light, vec2.rotate({32, 0}, angle))
  animator.setLightPosition(light.."-2", vec2.rotate({20, 0}, angle))
end

function ancientbossDoubleBeamAttack.bob(dt, stateData)
  local bobFactor = (stateData.bobInterval - (stateData.timer % stateData.bobInterval)) / stateData.bobInterval
  local bobOffset = math.sin(bobFactor * math.pi * 2) * stateData.bobHeight
  local targetPosition = {self.spawnPosition[1], self.spawnPosition[2] + bobOffset}
  local toTarget = world.distance(targetPosition, mcontroller.position())

  mcontroller.controlApproachVelocity(vec2.mul(toTarget, 1/dt), 30)
end
