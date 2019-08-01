require "/scripts/util.lua"
require "/scripts/interp.lua"

HealthRelicAbility = WeaponAbility:new()

function HealthRelicAbility:init()
  self.weapon:setStance(self.stances.idle)
  self.chargeTimer = self.chargeTime or 0
  noInitialCooldown = self.noInitialCooldown or false
  if noInitialCooldown then
    self.cooldownTimer = 0
  else
    self.cooldownTimer = self.cooldownTime or 0
  end
  self.impactSoundTimer = 0
  if self.damageConfig then
    self.damageConfig.baseDamage = (self.baseDps or 0) * (self.fireTime or 0)
  end

  activeItem.setCursor("/cursors/reticle0.cursor")

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
    animator.setAnimationState("hold", "idle")
    animator.setAnimationState("charge", "inactive")
    animator.setParticleEmitterActive("spellCharge", false)
  end
end

function HealthRelicAbility:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  if not self.weapon.currentAbility then
    self.cooldownTimer = math.max(0, self.cooldownTimer - dt)
  end

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy") then
      self:setState(self.charge)
  end
end

function HealthRelicAbility:charge()
  self.weapon:setStance(self.stances.precharge)
  animator.setAnimationState("hold", "disappear")
  animator.playSound("precharge")
  util.wait(self.stances.precharge.duration)
  self.weapon:setStance(self.stances.charge)
  animator.setAnimationState("charge", "windup")
  animator.playSound("charge")
  animator.setParticleEmitterActive("spellCharge", true)
  activeItem.setCursor("/cursors/charge2.cursor")
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    self.chargeTimer = math.max(0, self.chargeTimer - self.dt)
    if self.chargeTimer == 0 and status.overConsumeResource("energy", self.energyCost) then
      animator.stopAllSounds("charge")
      self:setState(self.fire)
    end

    coroutine.yield()
  end
  animator.stopAllSounds("charge")
  self:setState(self.winddown)
end

function HealthRelicAbility:fire()
  if world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    self:setState(self.winddown)
    return
  end
  self:fireProjectiles()
  animator.playSound("fire")
  self:setState(self.winddown)
end

function HealthRelicAbility:winddown()
  activeItem.setCursor("/cursors/reticle0.cursor")
  self.weapon:setStance(self.stances.discharge)
  self.weapon:updateAim()
  animator.setAnimationState("charge", "discharge")
  animator.playSound("discharge")
  animator.setParticleEmitterActive("spellCharge", false)
  self.chargeTimer = self.chargeTime or 0
  self.cooldownTimer = self.cooldownTime

  local progress = 0
  util.wait(self.stances.discharge.duration)
end

function HealthRelicAbility:fireProjectiles()
  local params = copy(self.projectileParameters or {})
  for i = 1, (self.projectileCount or 1) do
    repeat
      projectileOffset = {math.random(self.projectileOffsetRegion[1], self.projectileOffsetRegion[3]), math.random(self.projectileOffsetRegion[2], self.projectileOffsetRegion[4])}
      projectilePosition = vec2.add(projectileOffset, mcontroller.position())
    until not world.pointTileCollision(projectilePosition)
    projectileId = world.spawnProjectile(
        self.projectileType,
        projectilePosition,
        nil,
        {0, 0},
        false,
        params
      )
  end
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
  self.weapon:setStance(self.stances.idle)
  animator.setAnimationState("hold", "idle")
  animator.setAnimationState("charge", "inactive")
  animator.setParticleEmitterActive("spellCharge", false)
end
