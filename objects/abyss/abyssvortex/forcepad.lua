require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.open = true
  self.rotationPeriod = config.getParameter("rotationPeriod")
  self.scaleTime = config.getParameter("openTime")
  self.projectileOffset = config.getParameter("projectileOffset")
  self.forceRegionTimeThreshold = config.getParameter("activateThreshold")

  self.initialScale = 0.0
  self.finalScale = 1.0

  self.scaleTimer = self.scaleTime
  self.rotationTimer = 0.0

  local projectilePosition = vec2.add(entity.position(), self.projectileOffset)
  projectile = world.spawnProjectile("abyssvortextrap", projectilePosition, entity.id(), {1, 0}, false, {speed = 0, damageTeam = {type = "indiscriminate"}})
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
end

function onInputNodeChange(args)
  updateActive()
end

function onNodeConnectionChange(args)
  updateActive()
end

function updateActive()
  local active = not object.isInputNodeConnected(0) or object.getInputNodeLevel(0)
  local projectilePosition = vec2.add(entity.position(), self.projectileOffset)
  self.open = active
  animator.setAnimationState("padState", active and "opened" or "closed")
  if active then
    projectile = world.spawnProjectile("abyssvortextrap", projectilePosition, entity.id(), {1, 0}, false, {speed = 0, damageTeam = {type = "indiscriminate"}})
  elseif projectile then
    world.sendEntityMessage(projectile, "kill")
    projectile = nil
  end
end