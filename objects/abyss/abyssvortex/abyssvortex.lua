require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.open = true
  self.rotationPeriod = config.getParameter("rotationPeriod")
  self.scaleTime = config.getParameter("openTime")
  self.damageSources = copy(config.getParameter("damageSources"))
  self.forceRegionTimeThreshold = config.getParameter("activateThreshold")

  self.initialScale = 0.0
  self.finalScale = 1.0

  self.scaleTimer = self.scaleTime
  self.rotationTimer = 0.0

  updateActive()
end

function update(dt)
  animator.resetTransformationGroup("vortex")
  self.scaleTimer = (self.open and math.min(self.scaleTime, self.scaleTimer + dt)) or math.max(0, self.scaleTimer - dt)
  self.rotationTimer = self.rotationTimer + dt
  local scaleRatio = self.scaleTimer / self.scaleTime
  local scale = util.lerp(scaleRatio, self.initialScale, self.finalScale)
  animator.rotateTransformationGroup("vortex", (2 * math.pi * self.rotationTimer) / self.rotationPeriod)
  animator.scaleTransformationGroup("vortex", {scale, scale})
  physics.setForceEnabled("jumpForce", self.scaleTimer >= self.forceRegionTimeThreshold)

  if self.scaleTimer >= self.forceRegionTimeThreshold then
    object.setDamageSources(self.damageSources)
    animator.setParticleEmitterActive("wind", true)
  else
    object.setDamageSources()
    animator.setParticleEmitterActive("wind", false)
  end
end

function onInputNodeChange(args)
  updateActive()
end

function onNodeConnectionChange(args)
  updateActive()
end

function updateActive()
  local active = not object.isInputNodeConnected(0) or object.getInputNodeLevel(0)
  self.open = active
  animator.setAnimationState("padState", active and "opened" or "closed")
end