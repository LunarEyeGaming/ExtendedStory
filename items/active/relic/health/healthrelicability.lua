require "/scripts/util.lua"
require "/scripts/interp.lua"

HealthRelicAbility = WeaponAbility:new()

function HealthRelicAbility:init()
  self.weapon:setStance(self.stances.idle)
  self.chargeTimer = self.chargeTime or 0
  self.cooldownTimer = self.cooldownTime or 0
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
      self.weapon:setStance(self.stances.idle)
	end
  end
end

function HealthRelicAbility:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  burnOutProgress = self.burnOutTimer / self.burnOutTime
  activeItem.setInstanceValue("self.burnOutTimer", self.burnOutTimer)
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

function HealthRelicAbility:charge()
  self.weapon:setStance(self.stances.precharge)
  util.wait(self.stances.precharge.duration)
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

function HealthRelicAbility:drillFire()
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

function HealthRelicAbility:projFire()
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    if world.lineTileCollision(mcontroller.position(), self:firePosition()) then
      self:setState(self.winddown)
      return
    end
	if self.fireTimer == 0 then
      self:fireProjectiles()
      animator.playSound("fire")
	  self.fireTimer = self.fireTime or 0
      self.weapon:setStance(self.stances.fire)
    end
    if self.stances.fire.duration then
      util.wait(self.stances.fire.duration)
    end
	coroutine.yield()
  end
  self:setState(self.winddown)
end

function HealthRelicAbility:beamFire()
  animator.playSound("fireStart")
  animator.playSound("fireLoop", -1)

  local wasColliding = false
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
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

  self:BeamFire_reset()
  animator.playSound("fireEnd")

  self.cooldownTimer = self.fireTime
  self:setState(self.winddown)
end

function HealthRelicAbility:winddown()
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

function HealthRelicAbility:fireProjectiles()
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

function HealthRelicAbility:drawBeam(endPos, didCollide)
  local newChain = copy(self.chain)
  newChain.startOffset = self.weapon.muzzleOffset
  newChain.endPosition = endPos

  if didCollide then
    newChain.endSegmentImage = nil
  end

  activeItem.setScriptedAnimationParameter("chains", {newChain})
end

function HealthRelicAbility:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function HealthRelicAbility:aimVector(angleAdjust)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + angleAdjust + sb.nrand(self.inaccuracy, 0))
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  return aimVector
end

function HealthRelicAbility:uninit()
end
