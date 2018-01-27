
cyberbossPhaseAttack = {}

function cyberbossPhaseAttack.enterWith(args)
  if not args or not args.enteringPhase then return nil end

  return {
    timer = config.getParameter("cyberbossPhaseAttack.skillTime", 1),
    rotateInterval = config.getParameter("cyberbossPhaseAttack.rotateInterval", 0.2),
    rotateAngle = config.getParameter("cyberbossPhaseAttack.rotateAngle", 0.05),
    bleedAmount = config.getParameter("cyberbossPhaseAttack.bleedAmount", 100)
  }
end

function cyberbossPhaseAttack.enteringState(stateData)
  animator.setAnimationState("cyberbossdamage", "stage"..currentPhase())
  animator.setAnimationState("cyberboss", "idle")

  animator.playSound("shatter")
  animator.playSound("hurt")

  --Spawn crystal shards
  for i = 1, 10 do
    local randAngle = math.random() * math.pi * 2
    local spawnPosition = vec2.add(mcontroller.position(), vec2.rotate({8, 0}, randAngle))
    local aimVector = {math.cos(randAngle), math.sin(randAngle)}
    local projectile = "invisibleprojectile"
    world.spawnProjectile(projectile, spawnPosition, entity.id(), aimVector, false, {
      speed = 10 + math.random() * 30,
      power = 0, 
      timeToLive = 3 + math.random() * 3
    })
  end
end

function cyberbossPhaseAttack.update(dt, stateData)
  stateData.timer = stateData.timer - dt

  local duration = config.getParameter("cyberbossPhaseAttack.skillTime", 1) - stateData.timer
  local angle = cyberbossPhaseAttack.angleFactorFromTime(stateData.timer, stateData.rotateInterval) * stateData.rotateAngle - stateData.rotateAngle / 2
  animator.rotateGroup("all", angle, true)

  if stateData.timer <= 0 then
    return true
  end
end

--basic triangle wave
function cyberbossPhaseAttack.angleFactorFromTime(timer, interval)
  local modTime = timer % interval
  if modTime < interval / 2 then
    return modTime / (interval / 2)
  else
    return (interval - modTime) / (interval / 2) 
  end
end

function cyberbossPhaseAttack.leavingState(stateData)
  animator.rotateGroup("all", 0, true)
end
