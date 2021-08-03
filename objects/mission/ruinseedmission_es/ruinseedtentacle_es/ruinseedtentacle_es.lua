require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"
require "/scripts/poly.lua"

function init()
  self.rotationOffset = util.toRadians(config.getParameter("rotationOffset"))
  self.rotVelocity = config.getParameter("rotateRate", 1) * 2 * math.pi
  
  self.sinkVelocity = config.getParameter("sinkVelocity")

  self.windupTime = config.getParameter("windupTime")
  self.sinkDelay = config.getParameter("sinkDelay")
  self.sinkTime = config.getParameter("sinkTime")

  self.floorDebrisAngle = util.toRadians(config.getParameter("floorDebrisAngle"))
  self.damageAngle = util.toRadians(config.getParameter("damageAngle"))
  
  self.damageSource = config.getParameter("damageConfig")
  self.damageSource.damage = self.damageSource.damage * root.evalFunction("monsterLevelPowerMultiplier", world.threatLevel())
  self.damageSource.knockback = vec2.mul(self.damageSource.knockback, {object.direction(), 1})
  self.damageSource.sourceEntityId = entity.id()
  
  self.partAngles = config.getParameter("partAngles")
  for partName, partAngle in pairs(self.partAngles) do
    self.partAngles[partName] = util.toRadians(partAngle)
  end

  self.state = FSM:new()
  self.state:set(idle)

  message.setHandler("attack", function()
    self.state:set(attack)
  end)
end

function updateTransformations(angle, offset)
  animator.resetTransformationGroup("tentacle")
  animator.rotateTransformationGroup("tentacle", self.rotationOffset + angle)
  if offset ~= nil then
    animator.translateTransformationGroup("tentacle", offset)
  end

  for partName, partAngle in pairs(self.partAngles) do
    if math.abs(angle) >= partAngle then
      animator.setAnimationState(partName, "visible")
    else
      animator.setAnimationState(partName, "invisible")
    end
  end

  if math.abs(angle) > self.floorDebrisAngle then
    animator.setParticleEmitterActive("floordebris", true)
  else
    animator.setParticleEmitterActive("floordebris", false)
  end
end

function updateDamageSource(angle, offset)
  if math.abs(angle) > self.damageAngle then
    local damageSource
    if offset ~= nil then
      damageSource = copy(self.damageSource)
      damageSource.poly = poly.translate(damageSource.poly, offset)
    else
      damageSource = self.damageSource
    end
    object.setDamageSources({damageSource})
  else
    object.setDamageSources(nil)
  end
end

-- TODO: Function for calculating the offset regions of the emitters based on terrain formation.
-- Segment argument

function update(dt)
  self.state:update()
end

function idle()
  while true do
    coroutine.yield()
  end
end

function attack()
  animator.setParticleEmitterActive("windup", true)
  animator.playSound("windupstart")
  animator.playSound("winduploop", -1)

  util.wait(self.windupTime)

  animator.stopAllSounds("winduploop")
  animator.playSound("movestart")
  animator.playSound("moveloop", -1)

  local angle = 0
  util.wait(self.sinkDelay, function(dt)
    angle = angle + self.rotVelocity * dt
    updateTransformations(angle)
    updateDamageSource(angle)
  end)

  local offset = {0, 0}
  util.wait(self.sinkTime, function(dt)
    angle = angle + self.rotVelocity * dt
    offset = vec2.add(offset, vec2.mul(self.sinkVelocity, dt))
    updateTransformations(angle, offset)
    updateDamageSource(angle, offset)
  end)

  updateTransformations(0, offset)
  updateDamageSource(0)

  animator.setParticleEmitterActive("windup", false)
  animator.setParticleEmitterActive("floordebris", false)
  animator.stopAllSounds("moveloop")
  util.wait(0.5)

  animator.resetTransformationGroup("tentacle")

  self.state:set(idle)
end