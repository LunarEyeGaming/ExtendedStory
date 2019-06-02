function init()
  monster.setDeathParticleBurst("deathPoof")
  self.monsterDetect = "iceartifactboss_snowflake4"

  self.masterId = config.getParameter("masterId")
  self.minionIndex = config.getParameter("minionIndex")
  self.defaultConcurrentCooldown = 0.15
  self.concurrentCooldown = self.defaultConcurrentCooldown
  self.projectileDamage = 40

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
  if not entityCheck() then
    util.trackTarget(80.0, 30.0)

    if self.targetPosition ~= nil then
      local toPosition = vec2.norm(world.distance(self.targetPosition, mcontroller.position()))
      mcontroller.controlFly(toPosition)
      rangedAttack.aim({0,0}, world.distance(self.targetPosition, mcontroller.position()))
      rangedAttack.fireContinuous()
    else
      rangedAttack.stopFiring()
    end
  else
    status.addEphemeralEffect("invulnerable")
  end

end

function entityCheck()
  if self.monsterDetect == "" then
    return false
  else
    validEntities = 0
    localEntities = world.entityQuery(mcontroller.position(), 200)
	for _, entity in pairs(localEntities) do
	  if world.monsterType(entity) == self.monsterDetect then
	    validEntities = validEntities + 1
	  end
	end
	return validEntities > 0
  end
end

function despawn()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end