require "/scripts/util.lua"
require "/scripts/status.lua"
require "/scripts/poly.lua"
require "/scripts/rect.lua"
require "/items/active/weapons/weapon.lua"

LightningSlam = WeaponAbility:new()

function LightningSlam:init()
  self.cooldownTimer = self.cooldownTime
end

function LightningSlam:aimVector(inaccuracy)
  local aimAngle = vec2.angle(activeItem.ownerAimPosition())
  sb.logInfo("%s", aimAngle)
  local aimVector = vec2.rotate({1, 0}, aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function LightningSlam:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if not self.weapon.currentAbility
     and self.cooldownTimer == 0
     and self.fireMode == "alt"
     and mcontroller.onGround()
     and not status.statPositive("activeMovementAbilities")
     and status.overConsumeResource("energy", self.energyUsage) then

    self:setState(self.windup)
  end
end

function LightningSlam:windup()
  self.weapon:setStance(self.stances.windup)

  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

  util.wait(self.stances.windup.duration, function(dt)
      mcontroller.controlCrouch()
    end)

  self:setState(self.flip)
end

function LightningSlam:flip()
  self.weapon:setStance(self.stances.flip)
  self.weapon:updateAim()

  animator.setAnimationState("swoosh", "flip")
  animator.playSound(self.fireSound or "flipSlash")
  animator.setParticleEmitterActive("flip", true)

  self.flipTime = self.rotations * self.rotationTime
  self.flipTimer = 0

  self.jumpTimer = self.jumpDuration

  while self.flipTimer < self.flipTime do
    self.flipTimer = self.flipTimer + self.dt

    mcontroller.controlParameters(self.flipMovementParameters)

    if self.jumpTimer > 0 then
      self.jumpTimer = self.jumpTimer - self.dt
      mcontroller.setVelocity(vec2.mul(vec2.norm(self:aimVector(self.jumpInaccuracy or 0)), self.jumpSpeed))
    end

    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)

    mcontroller.setRotation(-math.pi * 2 * self.weapon.aimDirection * (self.flipTimer / self.rotationTime))

    coroutine.yield()
  end
  animator.setAnimationState("swoosh", "idle")
  mcontroller.setRotation(0)
  animator.setParticleEmitterActive("flip", false)
  self:setState(self.slam)
end

function LightningSlam:slam()
  self.weapon:setStance(self.stances.slamwindup)
  
  self.slamFreezeTimer = 0
  
  while self.slamFreezeTimer < self.slamFreezeTime do
    self.slamFreezeTimer = self.slamFreezeTimer + self.dt
    mcontroller.controlApproachVelocity({0, 0}, 1000)
	
	coroutine.yield()
  end
  
  animator.setParticleEmitterActive("slam", true)
  animator.playSound("slamCharge")
  animator.playSound("slamming", -1)
  animator.setAnimationState("swoosh", "slam")
  
  self.weapon:setStance(self.stances.slamfinish)
  mcontroller.controlApproachVelocity({0, -self.slamSpeed}, 1000)
  
  while not mcontroller.onGround() do
    status.addEphemeralEffect("nofalldamage")

    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)
    
    coroutine.yield()
  end
  status.removeEphemeralEffect("nofalldamage")
  animator.setParticleEmitterActive("slam", false)
  animator.setAnimationState("swoosh", "idle")
  animator.stopAllSounds("slamming")
  self:spawnProjectiles()

  status.clearPersistentEffects("weaponMovementAbility")
  self.cooldownTimer = self.cooldownTime
end


function LightningSlam:spawnProjectiles()
  local params = copy(self.projectileParameters)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.power = params.power * config.getParameter("damageLevelMultiplier")
  position = world.lineCollision(mcontroller.position(), {mcontroller.position()[1], mcontroller.position()[2] - 50}) or mcontroller.position()
  local impact, impactHeight = self:impactPosition()

  if impact then
    world.spawnProjectile("lightningboltexplosion", position, activeItem.ownerEntityId(), {0, 0}, false, params)
    self.weapon.weaponOffset = {0, impactHeight + self.impactWeaponOffset}
    local directions = {1}
    if self.bothDirections then directions[2] = -1 end
    local positions = self:shockwaveProjectilePositions(impact, self.maxDistance, directions)
    if #positions > 0 then
      animator.playSound(self.weapon.elementalType.."impact")
      local params = copy(self.projectileParameters)
      params.powerMultiplier = activeItem.ownerPowerMultiplier()
      params.power = params.power * config.getParameter("damageLevelMultiplier")
      params.actionOnReap = {
        {
          action = "projectile",
          inheritDamageFactor = 1,
          type = self.projectileType
        }
      }
      for i,position in pairs(positions) do
        local xDistance = world.distance(position, impact)[1]
        local dir = util.toDirection(xDistance)
        params.timeToLive = (math.floor(math.abs(xDistance))) * 0.025
        world.spawnProjectile("shockwavespawner", position, activeItem.ownerEntityId(), {dir,0}, false, params)
      end
    end
  end
end

function LightningSlam:impactPosition()
  local dir = mcontroller.facingDirection()
  local startLine = vec2.add(mcontroller.position(), vec2.mul(self.impactLine[1], {dir, 1}))
  local endLine = vec2.add(mcontroller.position(), vec2.mul(self.impactLine[2], {dir, 1}))

  local blocks = world.collisionBlocksAlongLine(startLine, endLine, {"Null", "Block"})
  if #blocks > 0 then
    return vec2.add(blocks[1], {0.5, 0.5}), endLine[2] - blocks[1][2] + 1
  end
end

function LightningSlam:shockwaveProjectilePositions(impactPosition, maxDistance, directions)
  local positions = {}

  for _,direction in pairs(directions) do
    direction = direction * mcontroller.facingDirection()
    local position = copy(impactPosition)
    for i = 0, maxDistance do
      local continue = false
      for _,yDir in ipairs({0, -1, 1}) do
        local wavePosition = {position[1] + direction * i, position[2] + 0.5 + yDir + self.shockwaveHeight}
        local groundPosition = {position[1] + direction * i, position[2] + yDir}
        local bounds = rect.translate(self.shockWaveBounds, wavePosition)

        if world.pointTileCollision(groundPosition, {"Null", "Block", "Dynamic", "Slippery"}) and not world.rectTileCollision(bounds, {"Null", "Block", "Dynamic", "Slippery"}) then
          table.insert(positions, wavePosition)
          position[2] = position[2] + yDir
          continue = true
          break
        end
      end
      if not continue then break end
    end
  end

  return positions
end


function LightningSlam:uninit()
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setAnimationState("swoosh", "idle")
  mcontroller.setRotation(0)
  animator.setParticleEmitterActive("flip", false)
  status.removeEphemeralEffect("nofalldamage")
  animator.setParticleEmitterActive("slam", false)
  animator.stopAllSounds("slamming")
end
