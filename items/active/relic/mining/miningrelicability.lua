require "/scripts/util.lua"
require "/scripts/interp.lua"

MiningRelicAbility = WeaponAbility:new()

function MiningRelicAbility:init()
  self.weapon:setStance(self.stances.idle)

  self.burnOutTimer = config.getParameter("burnOutTimer", 0)
  self.burnedOutTimer = config.getParameter("burnedOutTimer", 0)
  self.chargeTimer = self.chargeTime or 0
  self.fireTimer = self.fireTime or 0
  self.impactSoundTimer = 0
  if self.damageConfig then
    self.damageConfig.baseDamage = (self.baseDps or 0) * (self.fireTime or 0)
  end

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
	if self.firingMode == "beam" then
      self.weapon:setDamage()
      activeItem.setScriptedAnimationParameter("chains", {})
      animator.setParticleEmitterActive("beamCollision", false)
      animator.stopAllSounds("fireLoop")
	end
  end
  usingItem = false
end

function MiningRelicAbility:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  burnOutProgress = self.burnOutTimer / self.burnOutTime
  if self.burnedOutTimer == 0 then
    animator.setGlobalTag("burnOutLevel", math.floor(burnOutProgress * self.burnOutStages))
	animator.setParticleEmitterActive("burnedOut", false)
  else
    animator.setGlobalTag("burnOutLevel", math.floor((self.burnedOutTimer / self.burnOutCooldown) * self.burnOutStages))
	animator.setParticleEmitterActive("burnedOut", true)
  end
  if not usingItem then
    self.burnOutTimer = math.max(0, self.burnOutTimer - self.dt * self.burnOutRecharge)
  end
  activeItem.setInstanceValue("burnOutTimer", self.burnOutTimer)
  self.burnedOutTimer = math.max(0, self.burnedOutTimer - self.dt)
  activeItem.setInstanceValue("burnedOutTimer", self.burnedOutTimer)
  if self.firingMode == "beam" then
    self.impactSoundTimer = math.max(self.impactSoundTimer - self.dt, 0)
  end

  self.fireTimer = math.max(0, self.fireTimer - self.dt)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and self.burnedOutTimer == 0
    and not self.weapon.currentAbility
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then
	
    self:setState(self.charge)
  end
end

function MiningRelicAbility:charge()
  self.weapon:setStance(self.stances.charge)
  usingItem = true
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    self.chargeTimer = math.max(0, self.chargeTimer - self.dt)
	if self.chargeTimer == 0 then
	  if self.firingMode == "drill" then
	    self:setState(self.drillFire)
	  elseif self.firingMode == "proj" then
	    self:setState(self.projFire)
	  elseif self.firingMode == "beam" then
	    self:setState(self.beamFire)
	  else
	    sb.logWarn("Firing mode '%s' is invalid", self.firingMode)
	  end
	end

    coroutine.yield()
  end
  self:setState(self.winddown)
end

function MiningRelicAbility:drillFire()
  self.weapon:setStance(self.stances.fire)

  self.tileDamageTimer = 0
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    self.burnOutTimer = math.min(self.burnOutTime, self.burnOutTimer + self.dt)
	if self.burnOutTimer == self.burnOutTime then
	  self.burnedOutTimer = self.burnOutCooldown
      animator.playSound("burnout")
	  break
	end
    self.weapon:updateAim()

    local damageArea = partDamageArea("drillenergy")
    self.weapon:setDamage(self.damageConfig, damageArea, self.damageTimeout)

    self.tileDamageTimer = math.max(0, self.tileDamageTimer - self.dt)
    if self.tileDamageTimer == 0 then
      self.tileDamageTimer = self.tileDamageRate
      self:drillDamageTiles()
    end

    coroutine.yield()
  end

  self:setState(self.winddown)
end

function MiningRelicAbility:projFire()
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    if world.lineTileCollision(mcontroller.position(), self:firePosition()) then
      self:setState(self.winddown)
      return
    end
	if self.burnOutTimer == self.burnOutTime then
	  self.burnedOutTimer = self.burnOutCooldown
      animator.playSound("burnout")
	  break
	end
	if self.fireTimer == 0 then
      self:fireProjectiles()
      animator.playSound("fire")
	  self.fireTimer = self.fireTime or 0
      self.weapon:setStance(self.stances.fire)
      self.burnOutTimer = math.min(self.burnOutTime, self.burnOutTimer + self.fireTime)
    end
    if self.stances.fire.duration then
      util.wait(self.stances.fire.duration)
    end
	coroutine.yield()
  end
  self:setState(self.winddown)
end

function MiningRelicAbility:beamFire()
  animator.playSound("fireStart")
  animator.playSound("fireLoop", -1)

  local wasColliding = false
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    self.burnOutTimer = math.min(self.burnOutTime, self.burnOutTimer + self.dt)
	if self.burnOutTimer == self.burnOutTime then
	  self.burnedOutTimer = self.burnOutCooldown
      animator.playSound("burnout")
	  break
	end
    local beamStart = self:firePosition()
    local beamEnd = vec2.add(beamStart, vec2.mul(vec2.norm(self:aimVector(0)), self.beamLength))
    local beamLength = self.beamLength

    local collidePoint = world.lineCollision(beamStart, beamEnd)
    if collidePoint then
      beamEnd = collidePoint

      beamLength = world.magnitude(beamStart, beamEnd)

      animator.setParticleEmitterActive("beamCollision", true)
      animator.resetTransformationGroup("beamEnd")
      animator.translateTransformationGroup("beamEnd", {beamLength, 0})

      if self.impactSoundTimer == 0 then
        animator.setSoundPosition("beamImpact", {beamLength, 0})
        animator.playSound("beamImpact")
	    world.damageTileArea(collidePoint, self.tileDamageRadius, "foreground", self:firePosition(), "blockish", self.tileDamage, 99)
	    world.damageTileArea(collidePoint, self.tileDamageRadius, "background", self:firePosition(), "blockish", self.tileDamage, 99)
        self.impactSoundTimer = self.fireTime
      end
    else
      animator.setParticleEmitterActive("beamCollision", false)
    end

    self.weapon:setDamage(self.damageConfig, {self.weapon.muzzleOffset, {self.weapon.muzzleOffset[1] + beamLength, self.weapon.muzzleOffset[2]}}, self.fireTime)

    self:drawBeam(beamEnd, collidePoint)

    coroutine.yield()
  end

  self:reset()
  animator.playSound("fireEnd")

  self.cooldownTimer = self.fireTime
  self:setState(self.winddown)
end

function MiningRelicAbility:winddown()
  usingItem = false
  self.weapon:setStance(self.stances.winddown)
  self.weapon:updateAim()
  self.chargeTimer = self.chargeTime or 0

  local progress = 0
  util.wait(self.stances.winddown.duration, function()
    local from = self.stances.winddown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.winddown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.winddown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.winddown.duration))
  end)
end

function MiningRelicAbility:fireProjectiles()
  local params = copy(self.projectileParameters)
  params.power = self.baseDamage * config.getParameter("damageLevelMultiplier")
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  projectileId = world.spawnProjectile(
      self.projectileType,
      self:firePosition(),
      activeItem.ownerEntityId(),
      self:aimVector(0),
      false,
      params
    )
end

function MiningRelicAbility:drillDamageTiles()
  local pos = mcontroller.position()
  local tipPosition = vec2.add(pos, activeItem.handPosition(animator.partPoint("drillenergy", "drillTip")))
  for i = 1, 3 do
    local sourcePosition = vec2.add(pos, activeItem.handPosition(animator.partPoint("drillenergy", "drillSource" .. i)))
    local drillTiles = world.collisionBlocksAlongLine(sourcePosition, tipPosition, nil, self.damageTileDepth)
    if #drillTiles > 0 then
      world.damageTiles(drillTiles, "foreground", sourcePosition, "blockish", self.tileDamage, 99)
      world.damageTiles(drillTiles, "background", sourcePosition, "blockish", self.tileDamage, 99)
    end
  end
end

function MiningRelicAbility:drawBeam(endPos, didCollide)
  local newChain = copy(self.chain)
  newChain.startOffset = self.weapon.muzzleOffset
  newChain.endPosition = endPos

  if didCollide then
    newChain.endSegmentImage = nil
  end

  activeItem.setScriptedAnimationParameter("chains", {newChain})
end

function MiningRelicAbility:reset()
  if self.firingMode == "beam" then
    self.weapon:setDamage()
    activeItem.setScriptedAnimationParameter("chains", {})
    animator.setParticleEmitterActive("beamCollision", false)
    animator.stopAllSounds("fireStart")
    animator.stopAllSounds("fireLoop")
  end
end

function MiningRelicAbility:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function MiningRelicAbility:aimVector(angleAdjust)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + angleAdjust + sb.nrand(self.inaccuracy, 0))
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  return aimVector
end

function MiningRelicAbility:uninit()

end
