require "/scripts/util.lua"
require "/scripts/interp.lua"

ShadowEyesAbility = WeaponAbility:new()

function ShadowEyesAbility:init()
  ---- Necessary Parameters ----
  -- chargeTime
  -- energyCost
  -- baseDamage
  -- projectileType
  -- projectileParameters
  -- maxCastRange (initial cast)
  -- maxMovementRange (when controlling the projectile)
  -- soundPitchStart
  -- soundPitchEnd
  -- soundVolumeStart
  -- soundVolumeEnd

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
  
  self.chargeTimer = self.chargeTime

  self.cursorMode = "inactive" -- Condition: self.cursorMode must be "inactive" or have an item in self.cursorPaths with "valid" and "invalid" appended to the respective entries
  -- Example: If self.cursorMode is "charging", there must be two items in self.cursorPaths with names "chargingvalid" and "charginginvalid" respectively

  self.cursorPaths = {}
  self.cursorPaths["inactive"] = "/cursors/reticle0.cursor"
  self.cursorPaths["chargingvalid"] = "/cursors/charge2.cursor"
  self.cursorPaths["charginginvalid"] = "/cursors/chargeidle.cursor"
  self.cursorPaths["chargedvalid"] = "/cursors/chargeready.cursor"
  self.cursorPaths["chargedinvalid"] = "/cursors/chargeinvalid.cursor"

  self.weapon:setStance(self.stances.idle)
  activeItem.setCursor(self.cursorPaths["inactive"])
end

function ShadowEyesAbility:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  
  self:updateProjectile()
  self:updateCursor()

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and not status.resourceLocked("energy")
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

	self:setState(self.charge)
  end
end

function ShadowEyesAbility:charge()
  self.weapon:setStance(self.stances.charge)
  self.cursorMode = "charging"
  animator.playSound("charging", -1)

  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    local chargeTimeRatio = (self.chargeTime - self.chargeTimer) / self.chargeTime
    local soundPitch = interp.linear(chargeTimeRatio, self.soundPitchStart, self.soundPitchEnd)
    local soundVolume = interp.linear(chargeTimeRatio, self.soundVolumeStart, self.soundVolumeEnd)
    if self:targetValid(activeItem.ownerAimPosition()) then
      animator.setAnimationState("gun", "charging")
      animator.setSoundPitch("charging", soundPitch, 0)
      animator.setSoundVolume("charging", soundVolume, 0)
      self.chargeTimer = math.max(0, self.chargeTimer - self.dt)
    else
      animator.setSoundVolume("charging", 0, 0)
      animator.setAnimationState("gun", "inactive")
    end
	if self.chargeTimer == 0 
      and status.overConsumeResource("energy", self.energyCost) then
	  self:setState(self.castSpell)
	end

    coroutine.yield()
  end

  animator.setAnimationState("gun", "inactive")
  self:setState(self.winddown)
end

function ShadowEyesAbility:castSpell()
  storage.projectile = self:castProjectile()
  animator.setAnimationState("gun", "windup")
  animator.stopAllSounds("charging")
  animator.playSound("charged")
  animator.playSound("chargedloop", -1)
  self.cursorMode = "charged"

  while self.fireMode == (self.activatingFireMode or self.abilitySlot) and storage.projectile and world.entityExists(storage.projectile) do
    self:updateProjectile()
    
    coroutine.yield()
  end
  
  self:detonate()
  animator.setAnimationState("gun", "winddown")
  
  self:setState(self.winddown)
end

function ShadowEyesAbility:castProjectile()
  local aimPosition = activeItem.ownerAimPosition()
  local pParams = copy(self.projectileParameters)
  pParams.power = self.baseDamage * config.getParameter("damageLevelMultiplier")
  pParams.powerMultiplier = activeItem.ownerPowerMultiplier()

  local projectileId = world.spawnProjectile(
      self.projectileType,
      aimPosition,
      activeItem.ownerEntityId(),
      pOffset,
      false,
      pParams
    )
  if projectileId then
    world.sendEntityMessage(projectileId, "updateProjectile", aimPosition)
    return projectileId
  end
end

function ShadowEyesAbility:updateProjectile()
  local aimPosition = activeItem.ownerAimPosition()
  if storage.projectile
    and world.entityExists(storage.projectile)
    and self:targetValidMovement(aimPosition) then
    projectileResponse = world.sendEntityMessage(storage.projectile, "updateProjectile", aimPosition)
    if projectileResponse:finished() then
      storage.projectile = projectileResponse:result()
    end
  end
end

function ShadowEyesAbility:detonate()
  if storage.projectile and world.entityExists(storage.projectile) then
    world.sendEntityMessage(storage.projectile, "kill")
  end
end

function ShadowEyesAbility:winddown()
  self.weapon:setStance(self.stances.winddown)
  self.chargeTimer = self.chargeTime
  self.cursorMode = "inactive"
  
  animator.stopAllSounds("chargedloop")

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

function ShadowEyesAbility:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function ShadowEyesAbility:targetValid(aimPos)
  local firePos = self:firePosition()
  return world.magnitude(firePos, aimPos) <= self.maxCastRange
      and not world.lineTileCollision(firePos, aimPos)
end

function ShadowEyesAbility:targetValidMovement(aimPos)
  local firePos = self:firePosition()
  return world.magnitude(firePos, aimPos) <= self.maxMovementRange
end

function ShadowEyesAbility:updateCursor()
  aimPosition = activeItem.ownerAimPosition()
  if self.cursorMode == "inactive" then
    activeItem.setCursor(self.cursorPaths["inactive"])
  elseif self.cursorMode == "charging" then
    activeItem.setCursor(self:targetValid(aimPosition) and self.cursorPaths["chargingvalid"] or self.cursorPaths["charginginvalid"])
  else
    activeItem.setCursor(self:targetValidMovement(aimPosition) and self.cursorPaths[self.cursorMode.."valid"] or self.cursorPaths[self.cursorMode.."invalid"])
  end
end

function ShadowEyesAbility:reset()
  self.weapon:setStance(self.stances.idle)
  self:detonate()
  animator.stopAllSounds("charging")
  animator.stopAllSounds("charged")
  animator.stopAllSounds("chargedloop")
end

function ShadowEyesAbility:uninit()
  self:reset()
end
