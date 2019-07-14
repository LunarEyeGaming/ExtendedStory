function init()
  monster.setDeathParticleBurst("deathPoof")

  self.masterId = config.getParameter("masterId")
  self.inverted = config.getParameter("inverted", false)

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end
  if self.masterId then
    world.sendEntityMessage(self.masterId, "deactivate")
  end
  self.activated = false
  self.deactivated = true

  message.setHandler("despawn", despawn)
  if not self.inverted then
    status.setResourcePercentage("health", 0.015)
  end
end

function shouldDie()
  return not status.resourcePositive("health")
end

function update(dt)
  animator.setGlobalTag("healthStage", math.ceil(status.resourcePercentage("health") * 4))
  if self.inverted then
    if status.resourcePercentage("health") <= 0.02 then
      if not self.activated then
        if self.masterId then
	      world.sendEntityMessage(self.masterId, "activate")
	    else
	      world.spawnProjectile("invisibleprojectile", mcontroller.position())
	    end
        self.activated = true
        self.deactivated = false
	  end
    elseif not self.deactivated then
	  if self.masterId then
	    world.sendEntityMessage(self.masterId, "deactivate")
	  else
	    world.spawnProjectile("invisibleprojectile", mcontroller.position())
	  end
      self.deactivated = true
    else
      self.activated = false
    end
  else
    if status.resourcePercentage("health") == 1.0 then
      if not self.activated then
        if self.masterId then
	      world.sendEntityMessage(self.masterId, "activate")
	    else
	      world.spawnProjectile("invisibleprojectile", mcontroller.position())
	    end
        self.activated = true
        self.deactivated = false
	  end
    elseif not self.deactivated then
	  if self.masterId then
	    world.sendEntityMessage(self.masterId, "deactivate")
	  else
	    world.spawnProjectile("invisibleprojectile", mcontroller.position())
	  end
      self.deactivated = true
    else
      self.activated = false
    end
  end
  if status.resourcePercentage("health") <= 0.01 then
    status.setResourcePercentage("health", 0.015)
  end
  if self.masterId and not world.entityExists(self.masterId) then
    despawn()
  end
end

function despawn()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end