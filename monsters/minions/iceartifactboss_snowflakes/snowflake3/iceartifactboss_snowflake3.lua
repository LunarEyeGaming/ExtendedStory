function init()
  monster.setDeathParticleBurst("deathPoof")
  self.monsterDetect = "iceartifactboss_snowflake2"

  self.masterId = config.getParameter("masterId")
  self.minionIndex = config.getParameter("minionIndex")
  self.defaultConcurrentCooldown = 3
  self.concurrentCooldown = self.defaultConcurrentCooldown
  self.projectileDamage = 40
  if config.getParameter("uniqueId") then
    monster.setUniqueId(config.getParameter("uniqueId"))
  end
  offsetRange = {20, 20, -20, -20}

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
	  self.concurrentCooldown = math.max(0, self.concurrentCooldown - dt)
      rangedAttack.aim({0,0}, world.distance(self.targetPosition, mcontroller.position()))
      rangedAttack.fireContinuous()
	  if self.concurrentCooldown == 0 then
	    projDamage = self.projectileDamage * monster.level()
		for i = 1, 3 do
		  offset = {math.random(math.min(offsetRange[1], offsetRange[3]), math.max(offsetRange[1], offsetRange[3])), math.random(math.min(offsetRange[2], offsetRange[4]), math.max(offsetRange[2], offsetRange[4]))}
	      world.spawnProjectile("hypothermiaglobe", {mcontroller.position()[1] + offset[1], mcontroller.position()[2] + offset[2]}, entity.id(), {0, 0}, false, {power = projDamage})
		end
		self.concurrentCooldown = self.defaultConcurrentCooldown
	  end
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