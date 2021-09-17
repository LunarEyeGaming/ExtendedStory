require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"
require "/items/active/weapons/ranged/gunfire.lua"

ChainGunBurst = GunFire:new()

function ChainGunBurst:new(abilityConfig)
  local primary = config.getParameter("primaryAbility")
  return GunFire.new(self, sb.jsonMerge(primary, abilityConfig))
end

function ChainGunBurst:init()
  self.cooldownTimer = self.fireTime
  self.spinTimer = self.fireTime
end

function ChainGunBurst:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end

  if self.fireMode == "alt"
    and not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy")
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    
    self:setState(self.burst)
  end
end

function ChainGunBurst:burst()
  self.weapon:setStance(self.stances.fire)

  local shots = self.burstCount
  while shots > 0 and status.overConsumeResource("energy", self:energyPerShot()) do
    self:fireProjectile()
    self:muzzleFlash()
    shots = shots - 1

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.armRotation))

    util.wait(self.burstTime, function(dt)
      self:updateSpin(dt)
    end)
  end

  self.cooldownTimer = (self.fireTime - self.burstTime) * self.burstCount
end

function ChainGunBurst:updateSpin(dt)
  self.spinTimer = math.max(0, self.spinTimer - dt)
  if self.spinTimer == 0 then
    self.spinTimer = self.burstTime
  end
  self.spinFrame = math.floor((1 - self.spinTimer / self.burstTime) * self.spinFrameCount) % self.spinFrameCount
  animator.setGlobalTag("barrelFrame", self.spinFrame)
end

function ChainGunBurst:muzzleFlash()
  animator.setPartTag("muzzleFlash", "variant", math.random(1, self.muzzleFlashVariants or 3))
  animator.setAnimationState("firing", "fire")
  animator.setAnimationState("magazine", "reload")
  animator.burstParticleEmitter("altMuzzleFlash", true)
  animator.playSound("altFire")

  animator.setLightActive("muzzleFlash", true)
end
