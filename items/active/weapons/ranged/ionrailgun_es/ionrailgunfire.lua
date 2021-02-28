require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"

ChargeFire = WeaponAbility:new()

function ChargeFire:init()
  self.weapon:setStance(self.stances.idle)

  self.cooldownTimer = 0
  self.chargeTimer = 0

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
  activated = false
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
  local chargeTime = self.chargeTimer
  if animator.animationState("beamfire") == "off" then
    animator.resetTransformationGroup("laserbeam")
    animator.setGlobalTag("beamDirectives", "")
    activated = false
  end
end

function ChargeFire:charge()
  self.weapon:setStance(self.stances.charge)

  animator.setAnimationState("firing", "charge")
  collidePoint = nil

  self.chargeTimer = self.chargeTime

  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    self.chargeTimer = math.max(self.chargeTimer - self.dt, 0)
    
    if self.chargeTimer == 0 and status.overConsumeResource("energy", self.energyUsage * self.fireTime) then
      self:setState(self.fire)
    end

    coroutine.yield()
  end
  animator.setAnimationState("firing", "idle")
end

function ChargeFire:fire()
  if world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    animator.setAnimationState("firing", "idle")
    self.cooldownTimer = self.cooldownTime or 0
    self:setState(self.cooldown, self.cooldownTimer)
    return
  end
  self:drawBeam()

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
  baseDamage = (self.baseDamage * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1)))

  local progress = 0
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
        power = baseDamage,
        piercing = true,
        damageType = "damage",
        damageKind = "ionplasma",
        actionOnReap = {{action = "config", file = "/projectiles/explosions/iongrenadeexplosion/iongrenadeexplosion2.config"}}
      }
    )
  end
  util.wait(duration, function()
    local damageArea = { vec2.add({0, 0}, self.weapon.muzzleOffset), vec2.add({self.beamLength, 0}, self.weapon.muzzleOffset) }
    self.weapon:setDamage({baseDamage = baseDamage, damageSourceKind = "ionplasma", knockback = 0, damageRepeatTimeout = 1.0}, damageArea)
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / duration))
  end)
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
  collidePoint = world.lineCollision(self:firePosition(), beamEnd)
  if collidePoint and activated == false then
    beamEnd = collidePoint
    activated = true
  end
  local beamLength = world.magnitude(self:firePosition(), beamEnd)
  laserBeamOffsetX = beamLength / 2
  laserBeamOffset = {laserBeamOffsetX, 0}
  animator.translateTransformationGroup("laserbeam", laserBeamOffset)
  animator.setGlobalTag("beamDirectives", "scalenearest;"..beamLength..";1")
  animator.setAnimationState("beamfire", "fire")
end

function ChargeFire:uninit()

end