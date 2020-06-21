require "/scripts/util.lua"
require "/scripts/interp.lua"

-- Base gun fire ability
ChainGunFire = WeaponAbility:new()

function ChainGunFire:init()
  self.weapon:setStance(self.stances.idle)

  counter = 0
  self.fireFrame = 1
  self.fireTime = self.startFireTime
  self.isFiring = false

  self.cooldownTimer = self.fireTime
  self.spinTimer = self.fireTime
  self.progressTimer = self.windupTime

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

-- TODO: Implement animation for barrel and body

function ChainGunFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end
  
  --[[if self.progressTimer < self.windupTime then
    local progress = 1 - self.progressTimer / self.windupTime
    if not self.isFiring then
      animator.playSound("whir", -1)
      animator.setAnimationState("body", "fire")
    end
    animator.setSoundPitch("whir", interp.linear(progress, self.whirMinPitch, self.whirMaxPitch))
    self.isFiring = true
  else
    animator.stopAllSounds("whir")
    animator.setAnimationState("body", "idle")
    self.isFiring = false
  end]]
  if self.weapon.currentAbility == nil then
    world.debugPoint(mcontroller.position(), "blue")
  end

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and not status.resourceLocked("energy")
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

    self:setState(self.windup)
  end
end

function ChainGunFire:windup()
  animator.playSound("whir", -1)
  animator.setAnimationState("body", "fire")
  
  self:setState(self.firing)
end

function ChainGunFire:firing()
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    self:updateSpin()
    self.progressTimer = math.max(0, self.progressTimer - self.dt)
    local progress = 1 - self.progressTimer / self.windupTime
    self.fireTime = interp.linear(progress, self.startFireTime, self.endFireTime)
    animator.setSoundPitch("whir", interp.linear(progress, self.whirMinPitch, self.whirMaxPitch))
    
    if self.cooldownTimer == 0
      and status.overConsumeResource("energy", self:energyPerShot())
      and not status.resourceLocked("energy")
      and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

      self:fire()
    end
    
    coroutine.yield()
  end

  self:setState(self.winddown)
end

function ChainGunFire:winddown()
  while self.progressTimer < self.windupTime do
    self:updateSpin()
    self.progressTimer = math.min(self.windupTime, self.progressTimer + self.dt)
    local progress = 1 - self.progressTimer / self.windupTime
    self.fireTime = interp.linear(progress, self.startFireTime, self.endFireTime)
    animator.setSoundPitch("whir", interp.linear(progress, self.whirMinPitch, self.whirMaxPitch))

    if self.fireMode == (self.activatingFireMode or self.abilitySlot)
      and not status.resourceLocked("energy")
      and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

      self:setState(self.firing)
    end

    coroutine.yield()
  end
  
  animator.setAnimationState("body", "idle")
  animator.stopAllSounds("whir")
end

function ChainGunFire:fire()
  self.weapon:setStance(self.stances.fire)

  self:fireProjectile()
  self:muzzleFlash()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self.cooldownTimer = self.fireTime
  self:cooldown()
end

function ChainGunFire:cooldown()
  local progress = 0
  util.wait(self.stances.cooldown.duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
  
  self.weapon:setStance(self.stances.idle)
end

function ChainGunFire:updateSpin()
  self.spinTimer = math.max(0, self.spinTimer - self.dt)
  if self.spinTimer == 0 then
    self.spinTimer = self.fireTime
  end
  self.spinFrame = math.floor((1 - self.spinTimer / self.fireTime) * self.spinFrameCount) % self.spinFrameCount
  animator.setGlobalTag("barrelFrame", self.spinFrame)
end

function ChainGunFire:muzzleFlash()
  animator.setPartTag("muzzleFlash", "variant", math.random(1, self.muzzleFlashVariants or 3))
  animator.setAnimationState("firing", "fire")
  animator.setAnimationState("magazine", "reload")
  animator.burstParticleEmitter("muzzleFlash")
  animator.playSound("fire")

  animator.setLightActive("muzzleFlash", true)
end

function ChainGunFire:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
  params.power = self:damagePerShot()
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)

  if not projectileType then
    projectileType = self.projectileType
  end
  if type(projectileType) == "table" then
    projectileType = projectileType[math.random(#projectileType)]
  end

  local projectileId = 0
  for i = 1, (projectileCount or self.projectileCount) do
    if params.timeToLive then
      params.timeToLive = util.randomInRange(params.timeToLive)
    end

    projectileId = world.spawnProjectile(
        projectileType,
        firePosition or self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(inaccuracy or self.inaccuracy),
        false,
        params
      )
  end
  return projectileId
end

function ChainGunFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function ChainGunFire:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function ChainGunFire:energyPerShot()
  return self.energyUsage * self.endFireTime * (self.energyUsageMultiplier or 1.0)
end

function ChainGunFire:damagePerShot()
  return (self.baseDamage or (self.baseDps * self.endFireTime)) * (self.baseDamageMultiplier or 1.0) * config.getParameter("damageLevelMultiplier") / self.projectileCount
end

function ChainGunFire:uninit()
  self:setState(self.winddown)
end
