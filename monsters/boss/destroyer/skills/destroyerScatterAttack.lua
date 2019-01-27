destroyerScatterAttack = {}

function destroyerScatterAttack.enter()
  if self.targetPosition == nil then return nil end

  destroyerScatterAttack.reappeared = false
  animator.burstParticleEmitter("teleport")
  animator.playSound("teleportOut")
  return { 
    timer = config.getParameter("destroyerScatterAttack.skillTime"),
	offsetRange = config.getParameter("destroyerScatterAttack.offsetRange")
  }
end

function destroyerScatterAttack.enteringState(stateData)
  monster.setActiveSkillName("destroyerScatterAttack")
end

function destroyerScatterAttack.update(dt, stateData)
  mcontroller.controlFace(1)
  status.addEphemeralEffect("invulnerable")

  if stateData.timer > config.getParameter("destroyerScatterAttack.skillTime") - 0.55 then
    mcontroller.controlFly({ 0, 0 })
  elseif stateData.timer > 0 then
    if animator.animationState("movement") ~= "invisible" then
      animator.setAnimationState("movement", "invisible")
    end

    if stateData.timer < 0.3 and not destroyerScatterAttack.reappeared then
      destroyerScatterAttack.reappeared = true
	  mcontroller.setPosition({self.targetPosition[1] + math.random(stateData.offsetRange[3], stateData.offsetRange[1]), self.targetPosition[2] + math.random(stateData.offsetRange[4], stateData.offsetRange[2])})
      animator.burstParticleEmitter("teleport")
      animator.playSound("teleportIn")
    end
  else
    return true
  end

  stateData.timer = stateData.timer - dt
  return false
end

function destroyerScatterAttack.leavingState(stateData)
  status.removeEphemeralEffect("invulnerable")
  mcontroller.setVelocity({ 0, 0 })
  mcontroller.controlFly({ 0, 0 })
  animator.setAnimationState("movement", "visible")
end
