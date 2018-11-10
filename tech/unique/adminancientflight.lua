require "/scripts/vec2.lua"

function init()
  initCommonParameters()
end

function initCommonParameters()
  self.angularVelocity = 0
  self.angle = 0
  self.transformFadeTimer = 0
  altFireCooldownTimer = 0
  sphereEnergy = 10000

  self.energyCost = config.getParameter("energyCost")
  self.ballRadius = config.getParameter("ballRadius")
  self.ballFrames = config.getParameter("ballFrames")
  self.ballSpeed = config.getParameter("ballSpeed")
  self.transformFadeTime = config.getParameter("transformFadeTime", 0.3)
  self.transformedMovementParameters = config.getParameter("transformedMovementParameters")
  self.transformedMovementParameters.runSpeed = self.ballSpeed
  self.transformedMovementParameters.walkSpeed = self.ballSpeed
  self.basePoly = mcontroller.baseParameters().standingPoly
  self.collisionSet = {"Null", "Block", "Dynamic", "Slippery"}

  self.forceDeactivateTime = config.getParameter("forceDeactivateTime", 3.0)
  self.forceShakeMagnitude = config.getParameter("forceShakeMagnitude", 0.125)
end

function uninit()
  storePosition()
  deactivate()
end

function update(args)
  restoreStoredPosition()

  if not self.specialLast and args.moves["special1"] then
    attemptActivation()
  end
  self.specialLast = args.moves["special1"]

  if not args.moves["special1"] then
    self.forceTimer = nil
  end

  if self.active then
    local aimPosition = tech.aimPosition()
    mcontroller.controlParameters(self.transformedMovementParameters)
    status.setResourcePercentage("energyRegenBlock", 1.0)
	altFireLast = args.moves["altFire"]
	--Movement
	local direction = {0, 0}
    if args.moves["right"] then direction[1] = direction[1] + 1 end
    if args.moves["left"] then direction[1] = direction[1] - 1 end
    if args.moves["up"] then direction[2] = direction[2] + 1 end
    if args.moves["down"] then direction[2] = direction[2] - 1 end
	
	directions = {
	  "down",
	  "up",
	  "right",
	  "left"
	}
	
	for _, v in pairs(directions) do
	  if args.moves[v] then
	    if sphereEnergy >= 2500 then
		  animator.setAnimationState(v, "active")
		else
		  animator.setAnimationState(v, "activeWarning")
		end
	  else
	    animator.setAnimationState(v, "inactive")
	  end
	end
	
	velocity = vec2.mul(vec2.norm(direction), 50)
	if not args.moves["run"] then
	  mcontroller.setVelocity(velocity)
	end
	
	mcontroller.controlApproachVelocity(velocity, 200.0)
	local direction = {0, 0}
	
	local velocity = mcontroller.velocity()
	
	if velocity ~= 0 and not (args.moves["up"] or args.moves["down"] or args.moves["left"] or args.moves["right"]) then
      mcontroller.controlApproachVelocity({0, 0}, 100)
	  if not args.moves["run"] then
	    mcontroller.setVelocity({0, 0})
	  end
	end
	if not args.moves["altFire"] and not args.moves["primaryFire"] then
	  if sphereEnergy <= 2500 then
	    animator.setAnimationState("ballState", "warning")
      else
		animator.setAnimationState("ballState", "on")
	  end
	end
	
	--Primary Ability
	
	if args.moves["primaryFire"] then
	  world.spawnProjectile("ancientexplosion", mcontroller.position(), entity.id(), {0, 0}, true, {power = 10, knockback = 30})
	  world.spawnProjectile("ancientflightdrill", mcontroller.position(), entity.id(), {0, 0}, true, {power = 10, knockback = 0})
	  world.spawnProjectile("ancientflightgravity", mcontroller.position(), entity.id(), {0, 0}, true, {power = 10, knockback = 0})
	  animator.setAnimationState("ballState", "fire")
	end
	
	--Alt Ability
	
	if args.moves["altFire"] and altFireCooldownTimer == 0 and not args.moves["primaryFire"] then
	  --world.spawnProjectile("chaingunlaserbeam", mcontroller.position(), entity.id(), {math.cos(rotation), -math.sin(rotation)}, true, {power = 10, knockback = 30, timeToLive = 0.001})
	  --world.spawnProjectile("chaingunlaserbeam", mcontroller.position(), entity.id(), {-math.cos(rotation), math.sin(rotation)}, true, {power = 10, knockback = 30, timeToLive = 0.001})
	  --mcontroller.controlRotation(0.3)
	  world.spawnProjectile("chaingunlaserbeam", mcontroller.position(), entity.id(), aimVectorAlt, true, {power = 50, knockback = 0, timeToLive = 0.001})
	  altFireCooldownTimer = 100
	  cooldownTimer()
	  animator.setAnimationState("ballState", "fire2")
	end
	
	--Bash Ability
	
	if (mcontroller.xVelocity() >= 30 or mcontroller.yVelocity() >= 30 or mcontroller.xVelocity() <= -30 or mcontroller.yVelocity() <= -30) and args.moves["run"] then
	  world.spawnProjectile("ancientspherebash", mcontroller.position(), entity.id(), {0, 0}, true)
	  animator.setParticleEmitterActive("ancientspherebash", true)
	else
	  animator.setParticleEmitterActive("ancientspherebash", false)
	end
	
	--No recharge ability is necessary
	
	--Boosts
	--[[  
	elseif args.moves["right" and "jump"] then
	  mcontroller.controlApproachXVelocity(80.0, 60.0)
	  animator.setAnimationState("ballState", "right")
	  
	elseif args.moves["left" and "jump"] then
	  mcontroller.controlApproachXVelocity(-80.0, 60.0)
	  animator.setAnimationState("ballState", "left")
	  
	elseif args.moves["up" and "jump"] then
	  mcontroller.controlApproachYVelocity(80.0, 60.0)
	  animator.setAnimationState("ballState", "up")
	  
	elseif args.moves["down" and "jump"] then
	  mcontroller.controlApproachYVelocity(-80.0, 60.0)
	  animator.setAnimationState("ballState", "down")
	  
	--Diagonals
	  
	elseif args.moves["right" and "up"] then
	  mcontroller.controlApproachVelocity({50.0, 50.0}, 40.0)
	  animator.setAnimationState("ballState", "upright")
	  
	elseif args.moves["right" and "down"] then
	  mcontroller.controlApproachVelocity({50.0, -50.0}, 40.0)
	  animator.setAnimationState("ballState", "downright")
	  
	elseif args.moves["left" and "down"] then
	  mcontroller.controlApproachVelocity({-50.0, -50.0}, 40.0)
	  animator.setAnimationState("ballState", "downleft")
	  
	elseif args.moves["left" and "up"] then
	  mcontroller.controlApproachVelocity({-50.0, 50.0}, 40.0)
	  animator.setAnimationState("ballState", "upleft")
	  
	--Boosted diagonals
	  
	elseif args.moves["right" and "up" and "jump"] then
	  mcontroller.controlApproachVelocity({80.0, 80.0}, 60.0)
	  animator.setAnimationState("ballState", "upright")
	  
	elseif args.moves["right" and "down" and "jump"] then
	  mcontroller.controlApproachVelocity({80.0, -80.0}, 60.0)
	  animator.setAnimationState("ballState", "downright")
	  
	elseif args.moves["left" and "down" and "jump"] then
	  mcontroller.controlApproachVelocity({-80.0, -80.0}, 60.0)
	  animator.setAnimationState("ballState", "downleft")
	  
	elseif args.moves["left" and "up" and "jump"] then
	  mcontroller.controlApproachVelocity({-80.0, 80.0}, 60.0)
	  animator.setAnimationState("ballState", "upleft")
	]]  

	
	rotation = mcontroller.rotation()
	aimVectorAlt = world.distance(aimPosition, mcontroller.position())

    updateAngularVelocity(args.dt)
    updateRotationFrame(args.dt)

    checkForceDeactivate(args.dt)
  end

  updateTransformFade(args.dt)

  self.lastPosition = mcontroller.position()
  if sphereEnergy <= 0 then
    deactivate()
  end
end

function cooldownTimer()
  while altFireCooldownTimer > 0 do
    altFireCooldownTimer = altFireCooldownTimer - 1
  end
end

function attemptActivation()
  if not self.active
      and not tech.parentLounging()
      and not status.statPositive("activeMovementAbilities")
      and status.overConsumeResource("energy", self.energyCost) then

    local pos = transformPosition()
    if pos then
      mcontroller.setPosition(pos)
      activate()
    end
  elseif self.active then
    local pos = restorePosition()
    if pos then
      mcontroller.setPosition(pos)
      deactivate()
    elseif not self.forceTimer then
      animator.playSound("forceDeactivate", -1)
      self.forceTimer = 0
    end
  end
end

function checkForceDeactivate(dt)
  animator.resetTransformationGroup("ball")

  if self.forceTimer then
    self.forceTimer = self.forceTimer + dt
    mcontroller.controlModifiers({
      movementSuppressed = true
    })

    local shake = vec2.mul(vec2.withAngle((math.random() * math.pi * 2), self.forceShakeMagnitude), self.forceTimer / self.forceDeactivateTime)
    animator.translateTransformationGroup("ball", shake)
    if self.forceTimer >= self.forceDeactivateTime then
      deactivate()
      self.forceTimer = nil
    else
      attemptActivation()
    end
    return true
  else
    animator.stopAllSounds("forceDeactivate")
    return false
  end
end

function storePosition()
  if self.active then
    storage.restorePosition = restorePosition()

    -- try to restore position. if techs are being switched, this will work and the storage will
    -- be cleared anyway. if the client's disconnecting, this won't work but the storage will remain to
    -- restore the position later in update()
    if storage.restorePosition then
      storage.lastActivePosition = mcontroller.position()
      mcontroller.setPosition(storage.restorePosition)
    end
  end
end

function restoreStoredPosition()
  if storage.restorePosition then
    -- restore position if the player was logged out (in the same planet/universe) with the tech active
    if vec2.mag(vec2.sub(mcontroller.position(), storage.lastActivePosition)) < 1 then
      mcontroller.setPosition(storage.restorePosition)
    end
    storage.lastActivePosition = nil
    storage.restorePosition = nil
  end
end

function updateAngularVelocity(dt)
  if mcontroller.groundMovement() then
    -- If we are on the ground, assume we are rolling without slipping to
    -- determine the angular velocity
    local positionDiff = world.distance(self.lastPosition or mcontroller.position(), mcontroller.position())
    self.angularVelocity = -vec2.mag(positionDiff) / dt / self.ballRadius

    if positionDiff[1] > 0 then
      self.angularVelocity = -self.angularVelocity
    end
  end
end

function updateRotationFrame(dt)
  self.angle = math.fmod(math.pi * 2 + self.angle + self.angularVelocity * dt, math.pi * 2)

  -- Rotation frames for the ball are given as one *half* rotation so two
  -- full cycles of each of the ball frames completes a total rotation.
  local rotationFrame = math.floor(self.angle / math.pi * self.ballFrames) % self.ballFrames
  animator.setGlobalTag("rotationFrame", rotationFrame)
end

function updateTransformFade(dt)
  if self.transformFadeTimer > 0 then
    self.transformFadeTimer = math.max(0, self.transformFadeTimer - dt)
    animator.setGlobalTag("ballDirectives", string.format("?fade=FFFFFFFF;%.1f", math.min(1.0, self.transformFadeTimer / (self.transformFadeTime - 0.15))))
  elseif self.transformFadeTimer < 0 then
    self.transformFadeTimer = math.min(0, self.transformFadeTimer + dt)
    tech.setParentDirectives(string.format("?fade=FFFFFFFF;%.1f", math.min(1.0, -self.transformFadeTimer / (self.transformFadeTime - 0.15))))
  else
    animator.setGlobalTag("ballDirectives", "")
    tech.setParentDirectives()
  end
end

function positionOffset()
  return minY(self.transformedMovementParameters.collisionPoly) - minY(self.basePoly)
end

function transformPosition(pos)
  pos = pos or mcontroller.position()
  local groundPos = world.resolvePolyCollision(self.transformedMovementParameters.collisionPoly, {pos[1], pos[2] - positionOffset()}, 1, self.collisionSet)
  if groundPos then
    return groundPos
  else
    return world.resolvePolyCollision(self.transformedMovementParameters.collisionPoly, pos, 1, self.collisionSet)
  end
end

function restorePosition(pos)
  pos = pos or mcontroller.position()
  local groundPos = world.resolvePolyCollision(self.basePoly, {pos[1], pos[2] + positionOffset()}, 1, self.collisionSet)
  if groundPos then
    return groundPos
  else
    return world.resolvePolyCollision(self.basePoly, pos, 1, self.collisionSet)
  end
end

function activate()
  if not self.active then
    animator.burstParticleEmitter("activateParticles")
    animator.playSound("activate")
    animator.setAnimationState("ballState", "activate")
    animator.setAnimationState("transform", "activate")
    self.angularVelocity = 0
    self.angle = 0
    self.transformFadeTimer = self.transformFadeTime
  end
  tech.setParentHidden(true)
  tech.setParentOffset({0, positionOffset()})
  tech.setToolUsageSuppressed(true)
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  self.active = true
end

function deactivate()
  if self.active then
    animator.burstParticleEmitter("deactivateParticles")
    animator.playSound("deactivate")
    animator.setAnimationState("ballState", "deactivate")
    self.transformFadeTimer = -self.transformFadeTime
  else
    animator.setAnimationState("ballState", "off")
  end
  animator.stopAllSounds("forceDeactivate")
  animator.setGlobalTag("ballDirectives", "")
  tech.setParentHidden(false)
  tech.setParentOffset({0, 0})
  tech.setToolUsageSuppressed(false)
  status.clearPersistentEffects("movementAbility")
  self.angle = 0
  mcontroller.setRotation(0.0)
  self.active = false
  if sphereEnergy <= 0 then
    animator.playSound("shutdown")
  end
  if sphereEnergy <= 2500 then
	sphereEnergy = 10000
  end
  animator.setAnimationState("up", "inactive")
  animator.setAnimationState("right", "inactive")
  animator.setAnimationState("down", "inactive")
  animator.setAnimationState("left", "inactive")
  animator.setParticleEmitterActive("ancientspherebash", false)
  animator.setParticleEmitterActive("ancientsphererecharge", false)
end

function minY(poly)
  local lowest = 0
  for _,point in pairs(poly) do
    if point[2] < lowest then
      lowest = point[2]
    end
  end
  return lowest
end
