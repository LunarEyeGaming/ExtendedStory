function init()
  monster.setDeathParticleBurst("deathPoof")

  self.masterId = config.getParameter("masterId")
  self.minionIndex = config.getParameter("minionIndex")
  self.defaultConcurrentCooldown = 1.5
  self.concurrentCooldown = self.defaultConcurrentCooldown
  self.active = false
  self.movementMode = "align"
  if config.getParameter("uniqueId") then
    monster.setUniqueId(config.getParameter("uniqueId"))
  end
  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end

  message.setHandler("despawn", despawn)
  message.setHandler("activate", function()
    animator.setAnimationState("movement", "activate")
    self.active = true
  end)
  message.setHandler("deactivate", function()
    animator.setAnimationState("movement", "deactivate")
    self.active = false
  end)
end

function shouldDie()
  return not status.resourcePositive("health")
end

function update(dt)
  if self.active then
    util.trackTarget(200.0, 30.0)

    if self.targetPosition ~= nil then
	  mcontroller.controlParameters({gravityEnabled = false})
	  monster.setDamageOnTouch(true)
      local toPosition = vec2.norm(world.distance(self.targetPosition, mcontroller.position()))
	  if self.movementMode == "align" and mcontroller.position()[2] >= self.targetPosition[2] - 1 and mcontroller.position()[2] <= self.targetPosition[2] + 1 then
	    self.movementMode = "charge"
		toCollidePosition = {toPosition[1], 0}
		mcontroller.setVelocity({0, 0})
	  elseif self.movementMode == "charge" and world.lineTileCollision(mcontroller.position(), {4 * toCollidePosition[1] + mcontroller.position()[1], mcontroller.position()[2]}) then
	    self.movementMode = "fall"
		animator.playSound("collide")
	  elseif self.movementMode == "fall" and mcontroller.onGround() then
	    self.movementMode = "align"
		animator.playSound("collide")
	  end
	  if self.movementMode == "align" then
	    toAlignPosition = {0, toPosition[2]}
        mcontroller.controlFly(toAlignPosition)
	  elseif self.movementMode == "charge" then
	    mcontroller.controlFly(toCollidePosition)
	  elseif self.movementMode == "fall" then
	    mcontroller.controlParameters({gravityEnabled = true})
	  end
    else
	  mcontroller.controlParameters({gravityEnabled = true})
    end
  else
    status.addEphemeralEffect("invulnerable")
	mcontroller.controlParameters({gravityEnabled = true})
	  monster.setDamageOnTouch(false)
  end

end

function despawn()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end