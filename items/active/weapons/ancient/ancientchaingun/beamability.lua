require "/items/active/weapons/ranged/beamfire.lua"
require "/scripts/vec2.lua"

DblHelixBeamFire = BeamFire:new()

function DblHelixBeamFire:init()
  self.fireTime = self.startFireTime
  BeamFire.init(self)
  self.damageConfig.baseDamage = self.baseDps * self.endFireTime

  self.progressTimer = 0
  self:updateMeter()
end

function DblHelixBeamFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  self.impactSoundTimer = math.max(self.impactSoundTimer - self.dt, 0)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy") then

    self.transitionTimer = 0
    self:setState(self.fire)
  end
end

function DblHelixBeamFire:fire()
  self.weapon:setStance(self.stances.fire)

  animator.playSound("fireStart")
  animator.playSound("fireLoop", -1)

  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    self.progressTimer = math.min(self.windupTime, self.progressTimer + self.dt)
    self.transitionTimer = math.min(self.transitionTimer + self.dt, self.beamTransitionTime)
    local progress = self.progressTimer / self.windupTime
    if not status.overConsumeResource("energy", (self.energyUsage or 0) * self.dt * progress) then
      break
    end
    self.fireTime = interp.linear(progress, self.startFireTime, self.endFireTime)
    self:updateMeter()
    local beamLength = self:animateBeam(true)

    self.weapon:setDamage(self.damageConfig, self:makeDamagePoly(beamLength, beamLength / self.beamLength * progress), self.fireTime)

    coroutine.yield()
  end

  self:reset()
  animator.playSound("fireEnd")

  self.cooldownTimer = self.fireTime
  self:setState(self.winddown)
end

--[[function DblHelixBeamFire:cooldown()
  self.weapon:setStance(self.stances.cooldown)

  util.wait(self.stances.cooldown.duration, function()
    if self.transitionTimer > 0 then
      self.transitionTimer = math.max(0, self.transitionTimer - self.dt)

      if self.transitionTimer == 0 then
        activeItem.setScriptedAnimationParameter("chains", {})
      else
        local beamStart = self:firePosition()
        local beamLength = math.min(self.beamLength, world.magnitude(beamStart, activeItem.ownerAimPosition()))
        local beamEnd = vec2.add(beamStart, vec2.mul(vec2.norm(self:aimVector(0)), beamLength))
        local collidePoint = world.lineCollision(beamStart, beamEnd)
        if collidePoint then
          beamEnd = collidePoint
          beamLength = world.magnitude(beamStart, beamEnd)
        end

        self:drawBeam(beamEnd, collidePoint, beamLength / self.beamLength)
      end
    end
  end)
end]]

function DblHelixBeamFire:winddown()
  self.weapon:setStance(self.stances.cooldown)
  while self.progressTimer > 0 do
    self.progressTimer = math.max(0, self.progressTimer - self.dt)
    --local progress = self.progressTimer / self.windupTime
    --animator.setSoundPitch("whir", interp.linear(progress, self.whirMinPitch, self.whirMaxPitch))
    self:updateMeter()
    if self.transitionTimer > 0 then
      self.transitionTimer = math.max(0, self.transitionTimer - self.dt)
      if self.transitionTimer == 0 then
        activeItem.setScriptedAnimationParameter("chains", {})
      else
        self:animateBeam(false)
      end
    end

    if self.fireMode == (self.activatingFireMode or self.abilitySlot)
      and not status.resourceLocked("energy")
      and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

      self:setState(self.fire)
    end

    coroutine.yield()
  end
  --activeItem.setScriptedAnimationParameter("chains", {})
  
  --animator.setAnimationState("body", "idle")
  --animator.stopAllSounds("whir")
end

function DblHelixBeamFire:animateBeam(includeImpact)
  local beamStart = self:firePosition()
  local beamLength = math.min(self.beamLength, world.magnitude(beamStart, activeItem.ownerAimPosition()))
  local beamEnd = vec2.add(beamStart, vec2.mul(vec2.norm(self:aimVector(0)), beamLength))

  local collidePoint = world.lineCollision(beamStart, beamEnd)
  if collidePoint then
    beamEnd = collidePoint
    beamLength = world.magnitude(beamStart, beamEnd)

    if includeImpact then
      animator.setParticleEmitterActive("beamCollision", true)
      animator.resetTransformationGroup("beamEnd")
      animator.translateTransformationGroup("beamEnd", {beamLength, 0})

      if self.impactSoundTimer == 0 then
        animator.setSoundPosition("beamImpact", {beamLength, 0})
        animator.playSound("beamImpact")
        self.impactSoundTimer = self.fireTime
      end
    end
  else
    animator.setParticleEmitterActive("beamCollision", false)
  end

  self:drawBeam(beamEnd, collidePoint, beamLength / self.beamLength * self.progressTimer / self.windupTime)
  
  return beamLength
end

function DblHelixBeamFire:drawBeam(endPos, didCollide, amplitudeSizeFactor)
  local newChain = copy(self.chain)
  newChain.startOffset = self.weapon.muzzleOffset
  newChain.endPosition = endPos

  if newChain.waveform and newChain.waveform.amplitude then
    newChain.waveform.amplitude = newChain.waveform.amplitude * amplitudeSizeFactor
  end

  if didCollide then
    newChain.endSegmentImage = nil
  end

  local currentFrame = self:beamFrame()
  if newChain.startSegmentImage then
    newChain.startSegmentImage = newChain.startSegmentImage:gsub("<beamFrame>", currentFrame)
  end
  newChain.segmentImage = newChain.segmentImage:gsub("<beamFrame>", currentFrame)
  if newChain.endSegmentImage then
    newChain.endSegmentImage = newChain.endSegmentImage:gsub("<beamFrame>", currentFrame)
  end
  
  local newChain2 = copy(newChain)
  if newChain2.waveform and newChain2.waveform.amplitude then
    newChain2.waveform.amplitude = -newChain2.waveform.amplitude
  end

  activeItem.setScriptedAnimationParameter("chains", {newChain, newChain2})
end

function DblHelixBeamFire:makeDamagePoly(length, amplitudeSizeFactor)
  if not self.chain.waveform then
    return {self.weapon.muzzleOffset, {self.weapon.muzzleOffset[1] + length, self.weapon.muzzleOffset[2]}}
  end
  local amplitude = self.chain.waveform.amplitude * amplitudeSizeFactor
  local poly = {}
  for x = 0, length, self.damageConfig.polyXSpread do
    local xAnim = x - os.clock() * (self.chain.waveform.movement or 0)
    local y1 = self:waveSegmentHeight(length, self.chain.waveform.frequency, amplitude, x, xAnim)
    local y2 = -y1
    table.insert(poly, vec2.add(self.weapon.muzzleOffset, {x, y1}))
    table.insert(poly, 1, vec2.add(self.weapon.muzzleOffset, {x, y2}))
  end
  return poly
end

function DblHelixBeamFire:beamFrame()
  return math.max(1, math.min(self.beamFrames, math.floor(self.beamFrames * math.min(self.progressTimer / self.windupTime, self.transitionTimer / self.beamTransitionTime) + 1.25)))
end

function DblHelixBeamFire:updateMeter()
  animator.setGlobalTag("meterProgress", math.floor(self.progressTimer / self.windupTime * self.meterFrames))
end

function DblHelixBeamFire:waveSegmentHeight(taperLength, period, amplitude, x1, x2)
  return (amplitude * math.sin(math.pi * x1 / taperLength)) * math.sin(math.pi * x2 / period)
end
