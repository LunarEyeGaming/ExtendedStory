destroyerScatterAttack = {}

function destroyerScatterAttack.enter()
  if self.targetPosition == nil then return nil end

  destroyerScatterAttack.reappeared = false
  animator.burstParticleEmitter("teleport")
  animator.playSound("teleportOut")
  return { 
    timer = config.getParameter("destroyerScatterAttack.skillTime")
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

    if self.targetPosition ~= nil then
      flyTo({
        self.targetPosition[1],
        self.spawnPosition[2]
      })
    else
      mcontroller.controlFly({ 0, 1 })
    end

    if stateData.timer < 0.3 and not destroyerScatterAttack.reappeared then
      destroyerScatterAttack.reappeared = true
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
