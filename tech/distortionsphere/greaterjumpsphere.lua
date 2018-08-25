require "/scripts/vec2.lua"
require "/scripts/rect.lua"
require "/scripts/poly.lua"
require "/scripts/status.lua"

function init()
  initCommonParameters()

  self.ignorePlatforms = config.getParameter("ignorePlatforms")
  self.damageDisableTime = config.getParameter("damageDisableTime")
  self.damageDisableTimer = 0

  self.headingAngle = nil

  self.normalCollisionSet = {"Block", "Dynamic"}
  if self.ignorePlatforms then
    self.platformCollisionSet = self.normalCollisionSet
  else
    self.platformCollisionSet = {"Block", "Dynamic", "Platform"}
  end

  self.damageListener = damageListener("damageTaken", function(notifications)
    for _, notification in pairs(notifications) do
      if notification.healthLost > 0 and notification.sourceEntityId ~= entity.id() then
        damaged()
        return
      end
    end
  end)
  self.mode = "none"
  self.blinkTimer = 0
  self.dashDirection = 0
  self.dashCooldownTimer = 0
  self.rechargeEffectTimer = 0

  self.blinkOutTime = config.getParameter("blinkOutTime")
  self.blinkInTime = config.getParameter("blinkInTime")
  self.dashCooldown = config.getParameter("dashCooldown")
  self.rechargeDirectives = config.getParameter("rechargeDirectives", "?fade=CCCCFFFF=0.25")
  self.rechargeEffectTime = config.getParameter("rechargeEffectTime", 0.1)
end

function initCommonParameters()
  spikeMode = false
  self.angularVelocity = 0
  self.angle = 0
  self.transformFadeTimer = 0

  self.energyCost = config.getParameter("energyCost")
  self.ballRadius = config.getParameter("ballRadius")
  self.ballFrames = config.getParameter("ballFrames")
  self.ballSpeed = config.getParameter("ballSpeed")
  self.ballSpikeSpeed = config.getParameter("ballSpikeSpeed")
  self.transformFadeTime = config.getParameter("transformFadeTime", 0.3)
  self.transformedMovementParameters = config.getParameter("transformedMovementParameters")
  self.transformedMovementParameters2 = config.getParameter("transformedMovementParameters2")
  self.transformedMovementParameters.runSpeed = self.ballSpeed
  self.transformedMovementParameters.walkSpeed = self.ballSpeed
  self.transformedMovementParameters2.runSpeed = self.ballSpikeSpeed
  self.transformedMovementParameters2.walkSpeed = self.ballSpikeSpeed
  self.basePoly = mcontroller.baseParameters().standingPoly
  self.collisionSet = {"Null", "Block", "Dynamic", "Slippery"}

  self.forceDeactivateTime = config.getParameter("forceDeactivateTime", 3.0)
  self.forceShakeMagnitude = config.getParameter("forceShakeMagnitude", 0.125)
  self.fireCooldown = config.getParameter("fireCooldown", 1.5)
  self.fireCooldownTimer = 0
  self.fireCooldown2 = config.getParameter("altFireCooldown", 1.5)
  self.fireCooldownTimer2 = 0
  self.projectileType = config.getParameter("projectileType", "invisibleprojectile")
  self.projectileParameters = config.getParameter("projectileParameters", {})
  self.projectileType2 = config.getParameter("altProjectileType", "invisibleprojectile")
  self.projectileParameters2 = config.getParameter("altProjectileParameters", {})
end

function uninit()
  storePosition()
  deactivate()
end

function update(args)
  if self.dashCooldownTimer > 0 then
    self.dashCooldownTimer = math.max(0, self.dashCooldownTimer - args.dt)
    if self.dashCooldownTimer == 0 then
	  rechargeEffectActive = true
      self.rechargeEffectTimer = self.rechargeEffectTime
      animator.setGlobalTag("ballDirectives", self.rechargeDirectives)
      animator.playSound("recharge")
    end
  end
  if self.fireCooldownTimer > 0 then
    self.fireCooldownTimer = math.max(0, self.fireCooldownTimer - args.dt)
	if self.fireCooldownTimer == 0 then
    end
  end
  if self.fireCooldownTimer2 > 0 then
    self.fireCooldownTimer2 = math.max(0, self.fireCooldownTimer2 - args.dt)
	if self.fireCooldownTimer2 == 0 then
    end
  end
  
  if self.mode == "start" then
    mcontroller.setVelocity({0, 0})
    self.mode = "out"
    self.blinkTimer = 0
    animator.playSound("activateBlink")
  elseif self.mode == "out" then
    animator.setAnimationState("ballState", "out")
    mcontroller.setVelocity({0, 0})
    self.blinkTimer = self.blinkTimer + args.dt

    if self.blinkTimer > self.blinkOutTime then
      mcontroller.setPosition(self.targetPosition)
      self.targetPosition = nil
      self.mode = "in"
      self.blinkTimer = 0
    end
  elseif self.mode == "in" then
    tech.setParentDirectives()
    animator.setAnimationState("ballState", "in")
    mcontroller.setVelocity({0, 0})
    self.blinkTimer = self.blinkTimer + args.dt

    if self.blinkTimer > self.blinkInTime then
      self.mode = "none"
      self.dashCooldownTimer = self.dashCooldown
    end
  end

  if self.rechargeEffectTimer > 0 then
    self.rechargeEffectTimer = math.max(0, self.rechargeEffectTimer - args.dt)
    if self.rechargeEffectTimer == 0 then
      rechargeEffectActive = false
    end
  end

  self.damageDisableTimer = math.max(0, self.damageDisableTimer - args.dt)

  self.damageListener:update()
  restoreStoredPosition()

  if not self.specialLast and args.moves["special1"] then
    attemptActivation()
  end
  self.specialLast = args.moves["special1"]

  if not args.moves["special1"] then
    self.forceTimer = nil
  end
  aimVectorAlt = world.distance(tech.aimPosition(), mcontroller.position())
  if self.active then
    --Fire Ability
    if args.moves["primaryFire"] and self.fireCooldownTimer == 0 and args.moves["run"] then
	  animator.playSound("fire")
	  animator.burstParticleEmitter("fire")
	  world.spawnProjectile(self.projectileType, mcontroller.position(), entity.id(), aimVectorAlt, false, self.projectileParameters)
	  self.fireCooldownTimer = self.fireCooldown
	end
	if args.moves["primaryFire"] and self.fireCooldownTimer2 == 0 and not args.moves["run"] then
	  animator.playSound("fire")
	  animator.burstParticleEmitter("fire")
	  world.spawnProjectile(self.projectileType2, mcontroller.position(), entity.id(), aimVectorAlt, false, self.projectileParameters2)
	  self.fireCooldownTimer2 = self.fireCooldown2
	end
	--Switch Modes
    if not self.primaryLast and not args.moves["run"] and args.moves["altFire"] then
	  animator.playSound("switchModes")
      switchModes()
    end
    self.primaryLast = args.moves["altFire"]
	--Cursor Blink
    if args.moves["altFire"] and args.moves["run"] then
      attemptCursorBlink()
    end
    if spikeMode == true then
	  wallStick(args)
	  mcontroller.controlParameters(self.transformedMovementParameters2)
	else
	  mcontroller.controlParameters(self.transformedMovementParameters)
	end
    status.setResourcePercentage("energyRegenBlock", 1.0)

    updateAngularVelocity(args.dt)
    updateRotationFrame(args.dt)

    checkForceDeactivate(args.dt)
  end

  updateTransformFade(args.dt)

  self.lastPosition = mcontroller.position()
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

function switchModes()
  if spikeMode == false then
    spikeMode = true
	animator.setGlobalTag("mode", "spike")
  else
    spikeMode = false
	animator.setGlobalTag("mode", "normal")
  end
end

function attemptCursorBlink()
  if self.mode == "none"
    and self.dashCooldownTimer == 0 then

    self.targetPosition = findTargetPosition()
    if self.targetPosition then self.mode = "start" end
  end
end

function findTargetPosition()
  blinkPos = tech.aimPosition()
  currentPos = mcontroller.position()
  collidePoint = world.lineCollision(currentPos, blinkPos)
  if collidePoint and (world.isTileProtected(currentPos) or world.type() == "unknown") then
    blinkPos = collidePoint
  end

  return blinkPos
end

function wallStick(args)
  if self.active then
    local groundDirection
    if self.damageDisableTimer == 0 then
      groundDirection = findGroundDirection()
    end

    if groundDirection then
      if not self.headingAngle then
        self.headingAngle = (math.atan(groundDirection[2], groundDirection[1]) + math.pi / 2) % (math.pi * 2)
      end

      local moveX = 0
      if args.moves["right"] then moveX = moveX + 1 end
      if args.moves["left"] then moveX = moveX - 1 end
      if moveX ~= 0 then
        -- find any collisions in the moving direction, and adjust heading angle *up* until there is no collision
        -- this makes the heading direction follow concave corners
        local adjustment = 0
        for a = 0, math.pi, math.pi / 4 do
          local testPos = vec2.add(mcontroller.position(), vec2.rotate({moveX * 0.25, 0}, self.headingAngle + (moveX * a)))
          adjustment = moveX * a
          if not world.polyCollision(poly.translate(poly.scale(mcontroller.collisionPoly(), 1.0), testPos), nil, self.normalCollisionSet) then
            break
          end
        end
        self.headingAngle = self.headingAngle + adjustment

        -- find empty space in the moving direction and adjust heading angle *down* until it collides
        -- adjust to the angle *before* the collision occurs
        -- this makes the heading direction follow convex corners
        adjustment = 0
        for a = 0, -math.pi, -math.pi / 4 do
          local testPos = vec2.add(mcontroller.position(), vec2.rotate({moveX * 0.25, 0}, self.headingAngle + (moveX * a)))
          if world.polyCollision(poly.translate(poly.scale(mcontroller.collisionPoly(), 1.0), testPos), nil, self.normalCollisionSet) then
            break
          end
          adjustment = moveX * a
        end
        self.headingAngle = self.headingAngle + adjustment

        -- apply a gravitation like force in the ground direction, while moving in the controlled direction
        -- Note: this ground force causes weird collision when moving up slopes, result is you move faster up slopes
        local groundAngle = self.headingAngle - (math.pi / 2)
        mcontroller.controlApproachVelocity(vec2.withAngle(groundAngle, self.ballSpikeSpeed), 300)

        local moveDirection = vec2.rotate({moveX, 0}, self.headingAngle)
        mcontroller.controlApproachVelocityAlongAngle(math.atan(moveDirection[2], moveDirection[1]), self.ballSpikeSpeed, 2000)

        self.angularVelocity = -moveX * self.ballSpikeSpeed
      else
        mcontroller.controlApproachVelocity({0,0}, 2000)
        self.angularVelocity = 0
      end

      mcontroller.controlDown()
      updateAngularVelocity(args.dt)

      self.transformedMovementParameters2.gravityEnabled = false
    else
      updateAngularVelocity(args.dt)
      self.transformedMovementParameters2.gravityEnabled = true
    end
  else
    self.headingAngle = nil
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
    if rechargeEffectActive == false then
      animator.setGlobalTag("ballDirectives", "")
	end
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
  self.active = false
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

function damaged()
  if self.active then
    self.damageDisableTimer = self.damageDisableTime
  end
end

function findGroundDirection()
  for i = 0, 3 do
    local angle = (i * math.pi / 2) - math.pi / 2
    local collisionSet = i == 1 and self.platformCollisionSet or self.normalCollisionSet
    local testPos = vec2.add(mcontroller.position(), vec2.withAngle(angle, 0.25))
    if world.polyCollision(poly.translate(mcontroller.collisionPoly(), testPos), nil, collisionSet) then
      return vec2.withAngle(angle, 1.0)
    end
  end
end
