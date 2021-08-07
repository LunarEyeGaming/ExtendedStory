require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"

ChargeFire = WeaponAbility:new()

function ChargeFire:init()
  self.weapon:setStance(self.stances.idle)
  self.leveledBaseDamage = self.baseDamage * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1))
  self.explosionDamage = self.leveledBaseDamage * self.explosionDamageMultiplier * activeItem.ownerPowerMultiplier()
  
  self.damageConfig.baseDamage = self.baseDamage
  self.damageArea = {
    vec2.add({0, 0}, self.weapon.muzzleOffset),
    vec2.add({self.beamLength, 0}, self.weapon.muzzleOffset)
  }
  
  self.energyCost = self.energyUsage * self.fireTime

  self.cooldownTimer = 0
  self.chargeTimer = self.chargeTime

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function ChargeFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and self.cooldownTimer == 0
    and not self.weapon.currentAbility
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
    and not status.resourceLocked("energy") then

    self:setState(self.charge)
  end
end

function ChargeFire:charge()
  self.weapon:setStance(self.stances.charge)

  animator.setAnimationState("firing", "charge")

  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    self.chargeTimer = math.max(self.chargeTimer - self.dt, 0)
    
    if self.chargeTimer == 0 and status.overConsumeResource("energy", self.energyCost) then
      self:setState(self.fire)
    end

    coroutine.yield()
  end

  animator.setAnimationState("firing", "idle")
  self.chargeTimer = self.chargeTime
end

function ChargeFire:fire()
  if world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    animator.setAnimationState("firing", "idle")
    self.cooldownTimer = self.cooldownTime or 0
    self:setState(self.cooldown, self.cooldownTimer)
    return
  end
  local collidePoint = self:drawBeam()

  if collidePoint then
    projectilePos = collidePoint
  else
    projectilePos = beamEnd
  end
  if not world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    world.spawnProjectile(
      "orbitalup",
      projectilePos,
      activeItem.ownerEntityId(),
      self:aimVector(0, 0),
      false,
      {
        timeToLive = 0,
        power = self.explosionDamage,
        damageKind = "ionplasma",
        actionOnReap = {{action = "config", file = "/projectiles/explosions/iongrenadeexplosion/iongrenadeexplosion2.config"}}
      }
    )
  end

  self.weapon:setStance(self.stances.fire)

  animator.setAnimationState("firing", "fire")
  animator.playSound("fire")

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self.cooldownTimer = self.cooldownTime or 0

  self:setState(self.cooldown, self.cooldownTimer)
end

function ChargeFire:cooldown(duration)
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()
  
  local progress = 0
  local from = self.stances.cooldown.weaponOffset or {0, 0}
  local to = self.stances.idle.weaponOffset or {0, 0}
  util.wait(duration, function()
    self.weapon:setDamage(self.damageConfig, self.damageArea)
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / duration))
  end)

  animator.resetTransformationGroup("laserbeam")
  animator.setGlobalTag("beamDirectives", "")

  self.chargeTimer = self.chargeTime
end

function ChargeFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function ChargeFire:aimVector(angleAdjust, inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + angleAdjust + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function ChargeFire:drawBeam()
  beamEnd = vec2.add(self:firePosition(), vec2.mul(self:aimVector(0, 0), self.beamLength))
  local collidePoint = world.lineCollision(self:firePosition(), beamEnd)
  if collidePoint then
    beamEnd = collidePoint
  end
  local beamLength = world.magnitude(self:firePosition(), beamEnd)
  laserBeamOffsetX = beamLength / 2
  laserBeamOffset = {laserBeamOffsetX, 0}
  animator.translateTransformationGroup("laserbeam", laserBeamOffset)
  animator.setGlobalTag("beamDirectives", "scalenearest;"..beamLength..";1")
  animator.setAnimationState("beamfire", "fire")
  return collidePoint
end

function ChargeFire:uninit()

end