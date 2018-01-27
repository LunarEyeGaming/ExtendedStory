ancientbossTeleportAttack = {}

function ancientbossTeleportAttack.enter()
  if self.targetPosition == nil then return nil end

  ancientbossTeleportAttack.reappeared = false
  animator.burstParticleEmitter("teleport")
  animator.playSound("teleportOut")
  return { 
    timer = config.getParameter("ancientbossTeleportAttack.skillTime")
  }
end

function ancientbossTeleportAttack.enteringState(stateData)
  monster.setActiveSkillName("ancientbossTeleportAttack")
end

function ancientbossTeleportAttack.update(dt, stateData)
  mcontroller.controlFace(1)
  status.addEphemeralEffect("invulnerable")

  if stateData.timer > config.getParameter("ancientbossTeleportAttack.skillTime") - 0.55 then
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

    if stateData.timer < 0.3 and not ancientbossTeleportAttack.reappeared then
      ancientbossTeleportAttack.reappeared = true
      animator.burstParticleEmitter("teleport")
      animator.playSound("teleportIn")
    end
  else
    return true
  end

  stateData.timer = stateData.timer - dt
  return false
end

function ancientbossTeleportAttack.leavingState(stateData)
  status.removeEphemeralEffect("invulnerable")
  mcontroller.setVelocity({ 0, 0 })
  mcontroller.controlFly({ 0, 0 })
  animator.setAnimationState("movement", "visible")
end
