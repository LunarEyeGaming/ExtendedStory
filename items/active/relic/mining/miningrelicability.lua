require "/scripts/util.lua"
require "/scripts/interp.lua"

MiningRelicAbility = WeaponAbility:new()

function MiningRelicAbility:init()
  self.weapon:setStance(self.stances.idle)

  burnOutTimer = config.getParameter("burnOutTimer", 0)
  burnedOutTimer = config.getParameter("burnedOutTimer", 0)
  chargeTimer = self.chargeTime

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
  usingItem = false
end

function MiningRelicAbility:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  burnOutProgress = burnOutTimer / self.burnOutTime
  if burnedOutTimer == 0 then
    animator.setGlobalTag("burnOutLevel", math.floor(burnOutProgress * self.burnOutStages))
	animator.setParticleEmitterActive("burnedOut", false)
  else
    animator.setGlobalTag("burnOutLevel", math.floor((burnedOutTimer / self.burnOutCooldown) * self.burnOutStages))
	animator.setParticleEmitterActive("burnedOut", true)
  end
  if not usingItem then
    burnOutTimer = math.max(0, burnOutTimer - self.dt * self.burnOutRecharge)
  end
  activeItem.setInstanceValue("burnOutTimer", burnOutTimer)
  burnedOutTimer = math.max(0, burnedOutTimer - self.dt)
  activeItem.setInstanceValue("burnedOutTimer", burnedOutTimer)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and burnedOutTimer == 0
    and not self.weapon.currentAbility
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then
	
    self:setState(self.charge)
  end
end

function MiningRelicAbility:charge()
  self.weapon:setStance(self.stances.charge)
  usingItem = true
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    chargeTimer = math.max(0, chargeTimer - self.dt)
	if chargeTimer == 0 then
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
  sb.logInfo("%s", burnOutTimer)
  sb.logInfo("%s", self.burnOutTime)
  sb.logInfo("%s", burnoutTimer == self.burnOutTime)
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    burnOutTimer = math.min(self.burnOutTime, burnOutTimer + self.dt)
	if burnOutTimer == self.burnOutTime then
	  burnedOutTimer = self.burnOutCooldown
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
  if world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    self:setState(self.winddown)
    return
  end

  self.weapon:setStance(self.stances.fire)

  animator.playSound("fire")

  self:fireProjectiles()
  self.currentStack = 0
  self:reload()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self:setState(self.winddown)
end

function MiningRelicAbility:beamFire()
  if world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    self:setState(self.winddown)
    return
  end

  self.weapon:setStance(self.stances.fire)

  animator.playSound("fire")

  self:fireProjectiles()
  self.currentStack = 0
  self:reload()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self:setState(self.winddown)
end

function MiningRelicAbility:winddown()
  usingItem = false
  self.weapon:setStance(self.stances.winddown)
  self.weapon:updateAim()
  chargeTimer = self.chargeTime

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

  local totalSpread = self.spread * (self.currentStack - 1)
  local currentAngle = totalSpread * -0.5
  for i = 1, self.currentStack do
    projectileId = world.spawnProjectile(
        self.projectileType,
        self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(currentAngle),
        false,
        params
      )
    currentAngle = currentAngle + self.spread
  end
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
