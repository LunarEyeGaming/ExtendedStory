require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"

function init()
  self.partStartingDistances = config.getParameter("partStartingDistances")
  self.burrowDistance = config.getParameter("burrowDistance")
  self.burrowTime = config.getParameter("burrowTime")
  self.segmentResetDistance = config.getParameter("segmentResetDistance")
  self.ceilingDebrisDistance = config.getParameter("ceilingDebrisDistance")

  self.state = FSM:new()
  self.state:set(idle)

  message.setHandler("burrow", function()
    self.state:set(burrow)
  end)
end

function update(dt)
  self.state:update()
end

function idle()
  while true do
    coroutine.yield()
  end
end

function burrow()
  animator.playSound("movestart")
  animator.playSound("moveloop", -1)
  animator.burstParticleEmitter("floordebris")
  animator.setParticleEmitterActive("floordebris", true)

  local timer = 0
  util.wait(self.burrowTime, function(dt)
    timer = math.min(timer + dt, self.burrowTime)
    local distance = interp.sin(timer / self.burrowTime, 0, self.burrowDistance)
    setBurrowDistance(distance)
  end)

  animator.setParticleEmitterActive("floordebris", false)
  animator.setParticleEmitterActive("ceilingdebris", false)

  animator.stopAllSounds("moveloop")

  self.state:set(idle)
end

function setBurrowDistance(distance)
  for partName, partStartingDistance in pairs(self.partStartingDistances) do
    local partDistance = distance + partStartingDistance
    animator.resetTransformationGroup(partName)
    animator.translateTransformationGroup(partName, {0, partDistance < 0 and partDistance or partDistance % self.segmentResetDistance})
  end

  if distance > self.segmentResetDistance then
    animator.setAnimationState("segment1", "body")
  end

  if distance > self.ceilingDebrisDistance then
    animator.setParticleEmitterActive("ceilingdebris", true)
  end
end