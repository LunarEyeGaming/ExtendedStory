function init()
  monster.setDeathParticleBurst("deathPoof")
  animator.setAnimationState("movement", "closed")

  self.masterId = config.getParameter("masterId")
  self.minionIndex = config.getParameter("minionIndex")
  self.minionTimer = 0

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end

  message.setHandler("despawn", despawn)

  rangedAttack.loadConfig()
end

function shouldDie()
  return not status.resourcePositive("health")
end

function update(dt)

  util.trackTarget(30.0, 10.0)

  if self.targetPosition ~= nil then
    rangedAttack.aim({0,0}, world.distance(self.targetPosition, mcontroller.position()))
    rangedAttack.fireContinuous()
  else
    rangedAttack.stopFiring()
  end

end

function despawn()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end