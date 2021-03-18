require "/scripts/util.lua"
require "/scripts/interp.lua"

TeslaStream = WeaponAbility:new()

function TeslaStream:init()
  self.weapon:setStance(self.stances.idle)
  self.chargeTimer = self.chargeTime or 0
  self.fireTimer = self.fireTime or 0
  self.damageConfig.baseDamage = self.baseDps * self.fireTime

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
    if self.firingMode == "beam" or self.firingMode == "beam2" then
      self.weapon:setDamage()
      activeItem.setScriptedAnimationParameter("lightning", {})
      animator.stopAllSounds("fireLoop")
    end
  end
  self.arcCooldownTimer = self.arcCooldownTime
  self.impactSoundTimer = self.impactSoundTime
end

function TeslaStream:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
    and not status.resourceLocked("energy") then
    
    self:setState(self.fire)
  end
  self.arcCooldownTimer = math.max(0, self.arcCooldownTimer - dt)
  self.impactSoundTimer = math.max(self.impactSoundTimer - self.dt, 0)
end

function TeslaStream:fire()
  self.weapon:setStance(self.stances.fire)

  animator.playSound("fireStart")
  animator.playSound("fireLoop", -1)

  local wasColliding = false
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) and status.overConsumeResource("energy", (self.energyUsage or 0) * self.dt) do
    local beamStart = self:firePosition()
    local beamLength = math.min(self.beamLength, world.magnitude(beamStart, activeItem.ownerAimPosition()))
    local beamEnd = vec2.add(beamStart, vec2.mul(vec2.norm(self:aimVector(0)), beamLength))

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
        self.impactSoundTimer = self.impactSoundTime
      end
    else
      animator.setParticleEmitterActive("beamCollision", false)
    end
    
    local entities = world.entityQuery(beamEnd, self.connectRadius, {includedTypes = {"monster", "npc"}})
  
    if self.arcCooldownTimer == 0 then
      local power = (self.damageConfig.baseDamage * (self.arcCooldownTime / self.fireTime) / self.maxConnections) * math.min(self.maxConnections, #entities) * self.arcDamageFactor
      for i, monster in ipairs(entities) do
        if entity.isValidTarget(monster) then
          local entityPos = world.entityPosition(monster)
          local entCollidePoint = world.lineCollision(beamEnd, entityPos)
          if i <= self.maxConnections and not entCollidePoint then
            world.spawnProjectile("lightningguncurrent", entityPos, entity.id(), {0, 0}, false, {power = power, timeToLive = 0})
          end
        end
      end
      self.arcCooldownTimer = self.arcCooldownTime
    end

    self.weapon:setDamage(self.damageConfig, {self.weapon.muzzleOffset, {self.weapon.muzzleOffset[1] + beamLength, self.weapon.muzzleOffset[2]}}, self.fireTime)

    self:drawBolt(beamEnd, entities)

    coroutine.yield()
  end

  self:reset()
  animator.playSound("fireEnd")

  self.cooldownTimer = self.fireTime
  self:setState(self.winddown)
end

function TeslaStream:winddown()
  usingItem = false
  self.weapon:setStance(self.stances.winddown)
  self.weapon:updateAim()
  self.chargeTimer = self.chargeTime or 0

  local progress = 0
  local newChain = copy(self.lightningConfig)
  local timeLeft = self.stances.winddown.duration
  newChain.worldStartPosition = self:firePosition()
  newChain.worldEndPosition = activeItem.ownerAimPosition()
  util.wait(self.stances.winddown.duration, function()
    local from = self.stances.winddown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.winddown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.winddown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.winddown.duration))

    timeLeft = timeLeft - self.dt
    local colorFactor = 1 - (timeLeft / self.stances.winddown.duration)
    local lightningColor = {
      util.lerp(colorFactor, self.lightningStartColor[1], self.lightningEndColor[1]),
      util.lerp(colorFactor, self.lightningStartColor[2], self.lightningEndColor[2]),
      util.lerp(colorFactor, self.lightningStartColor[3], self.lightningEndColor[3]),
      util.lerp(colorFactor, self.lightningStartColor[4], self.lightningEndColor[4])
    }
    
    local beamStart = self:firePosition()
    local beamLength = math.min(self.beamLength, world.magnitude(beamStart, activeItem.ownerAimPosition()))
    local beamEnd = vec2.add(beamStart, vec2.mul(vec2.norm(self:aimVector(0)), beamLength))
    local collidePoint = world.lineCollision(beamStart, beamEnd)
    if collidePoint then
      beamEnd = collidePoint
    end
    newChain.color = lightningColor
    newChain.worldStartPosition = beamStart
    newChain.worldEndPosition = beamEnd
    activeItem.setScriptedAnimationParameter("lightning", {newChain, newChain})
    activeItem.setScriptedAnimationParameter("lightningSeed", math.floor((os.time() + (os.clock() % 1)) * 1000))
  end)
end

function TeslaStream:drawBolt(endPos, monsters)
  local newChain = copy(self.lightningConfig)
  newChain.worldStartPosition = self:firePosition()
  newChain.worldEndPosition = endPos
  self.lightning = {}
  for i, monster in ipairs(monsters) do
    if entity.isValidTarget(monster) then
      local entityPos = world.entityPosition(monster)
      local entCollidePoint = world.lineCollision(endPos, entityPos)
      if i <= self.maxConnections and not entCollidePoint then
        bolt = copy(self.miniLightningConfig)
        bolt.worldStartPosition = endPos
        bolt.worldEndPosition = world.entityPosition(monster)
        table.insert(self.lightning, bolt)
      end
    end
  end
  table.insert(self.lightning, newChain)
  table.insert(self.lightning, newChain)

  activeItem.setScriptedAnimationParameter("lightning", self.lightning)
  activeItem.setScriptedAnimationParameter("lightningSeed", math.floor((os.time() + (os.clock() % 1)) * 1000))
end

function TeslaStream:drawBeam(endPos, didCollide)
  local newChain = copy(self.chain)
  newChain.startOffset = self.weapon.muzzleOffset
  newChain.endPosition = endPos

  if didCollide then
    newChain.endSegmentImage = nil
  end

  activeItem.setScriptedAnimationParameter("chains", {newChain})
end

function TeslaStream:reset()
  self.weapon:setDamage()
  activeItem.setScriptedAnimationParameter("lightning", {})
  animator.setParticleEmitterActive("beamCollision", false)
  animator.stopAllSounds("fireStart")
  animator.stopAllSounds("fireLoop")
end

function TeslaStream:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function TeslaStream:aimVector(angleAdjust)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + angleAdjust + sb.nrand(self.inaccuracy, 0))
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  return aimVector
end

function TeslaStream:uninit()
  self:reset()
end
