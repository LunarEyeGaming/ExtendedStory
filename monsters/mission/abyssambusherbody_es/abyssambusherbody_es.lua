function init()
  self.tetheredMonster = config.getParameter("tetheredMonster")
  self.tetheredOffset = config.getParameter("tetheredOffset")
  self.tetheredParameters = copy(config.getParameter("tetheredParameters"))
  self.tetheredParameters.behaviorConfig = {masterId = entity.id()}
  self.tetheredParameters.level = monster.level()

  monster.setDeathParticleBurst("deathPoof")
  if config.getParameter("uniqueId") then
    monster.setUniqueId(config.getParameter("uniqueId"))
  end

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end
  

  storage.tetheredId = world.spawnMonster(self.tetheredMonster, vec2.add(mcontroller.position(), self.tetheredOffset), self.tetheredParameters)

  message.setHandler("despawn", despawn)
end

function shouldDie()
  return not status.resourcePositive("health")
end

function update(dt)
  if not world.entityExists(storage.tetheredId) then
    status.setResourcePercentage("health", 0)
  end
end

function despawn()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end