ancientbossLaserAttack = {}

--------------------------------------------------------------------------------
function ancientbossLaserAttack.enter()
  if not hasTarget() then return nil end
  return {
    windupTimer = 0.6,
    timer = config.getParameter("ancientbossLaserAttack.skillTime", 12),
    rotateInterval = config.getParameter("ancientbossLaserAttack.rotateInterval", 12),
    angleRange = 1.5,
    initialAngle = math.pi / 4,
    winddownTimer = 0.6
  }
end

--------------------------------------------------------------------------------
function ancientbossLaserAttack.enteringState(stateData)
  animator.setAnimationState("firstBeams", "windup")
  animator.setAnimationState("secondBeams", "windup")
  animator.setAnimationState("eye", "windup")
  animator.setAnimationState("beamglow", "on")

  ancientbossLaserAttack.damagePerSecond = config.getParameter("ancientbossLaserAttack.damagePerSecond")

  ancientbossLaserAttack.rotateBeams(math.pi/4, true)
  
  monster.setActiveSkillName("ancientbossLaserAttack")
end

--------------------------------------------------------------------------------
function ancientbossLaserAttack.update(dt, stateData)

  if stateData.windupTimer > 0 then
    stateData.windupTimer = stateData.windupTimer - dt
    return false
  end

  if stateData.timer > 0 then
    ancientbossLaserAttack.setBeamLightsActive(true)
    stateData.timer = stateData.timer - dt

    local angleFactor = (stateData.timer % stateData.rotateInterval) / stateData.rotateInterval
    local angle = stateData.angleRange * math.sin(angleFactor * math.pi * 2) + stateData.initialAngle

    ancientbossLaserAttack.rotateBeams(angle, true)

    local powerMultiplier = root.evalFunction("monsterLevelPowerMultiplier", monster.level())
    ancientbossLaserAttack.spawnProjectiles(angle, ancientbossLaserAttack.damagePerSecond * powerMultiplier * dt)

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

function ancientbossLaserAttack.leavingState(stateData)
  animator.setAnimationState("firstBeams", "idle")
  animator.setAnimationState("secondBeams", "idle")
  animator.setAnimationState("beamglow", "off")

  ancientbossLaserAttack.setBeamLightsActive(false)
end

function ancientbossLaserAttack.rotateBeams(angle, instant)
  --Beam 1
  animator.rotateGroup("beam1", angle, instant)
  ancientbossLaserAttack.setBeamLightPosition("beam1", angle)

  --Beam 2
  animator.rotateGroup("beam2", angle + math.pi * 0.5, instant)
  ancientbossLaserAttack.setBeamLightPosition("beam2", angle + math.pi * 0.5)

  --Beam 3
  animator.rotateGroup("beam3", angle + math.pi, instant)
  ancientbossLaserAttack.setBeamLightPosition("beam3", angle + math.pi)

  --Beam 4
  animator.rotateGroup("beam4", angle + math.pi * 1.5, instant)
  ancientbossLaserAttack.setBeamLightPosition("beam4", angle + math.pi * 1.5)
end

function ancientbossLaserAttack.spawnProjectiles(angle, power)
  for x = 0, 3 do
    local newAngle = angle + math.pi * x * 0.5
    local aimVector = {math.cos(newAngle), math.sin(newAngle)}
    world.spawnProjectile("crystalbeamdamage", mcontroller.position(), entity.id(), aimVector, true, {power = power, damageRepeatGroup = "crystalbossbeam"})
  end
end

function ancientbossLaserAttack.setBeamLightsActive(active)
  animator.setLightActive("beam1", active)
  animator.setLightActive("beam1-2", active)
  animator.setLightActive("beam2", active)
  animator.setLightActive("beam2-2", active)
  animator.setLightActive("beam3", active)
  animator.setLightActive("beam3-2", active)
  animator.setLightActive("beam4", active)
  animator.setLightActive("beam4-2", active)
end

function ancientbossLaserAttack.setBeamLightPosition(light, angle)
  animator.setLightPosition(light, vec2.rotate({0, 32}, angle))
  animator.setLightPosition(light.."-2", vec2.rotate({0, 20}, angle))
end