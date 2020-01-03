require "/scripts/vec2.lua"
require "/scripts/util.lua"

-- Goal: Spawn projectiles that form an arc. This arc can be growing or shrinking, and the angle can be specified through specific modes. Duration of the change in size is timeToLive.
-- Script fields:
-- String spawnMode: can be "position" or "direction"
-- String angleMode: can be "random" or "lerp"
-- float minAngle: The lower bound in random mode for the angle. This is the starting angle in any interpolation mode(e.g. lerp). Angle is in DEGREES.
-- float maxAngle: The upper bound in random mode for the angle. This is the end angle in any interpolation mode (e.g. lerp). Angle is in DEGREES.
-- float minRadius: The starting radius in blocks.
-- float maxRadius: The end radius in blocks.
-- String projectileName(projectileType in input)
-- Json projectileParameters
-- float projectileSpawnInterval
-- int projectileCount


function init()
  self.spawnMode = config.getParameter("spawnMode")
  self.angleMode = config.getParameter("angleMode")

  self.minAngle = util.toRadians(config.getParameter("minAngle"))
  self.maxAngle = util.toRadians(config.getParameter("maxAngle"))

  self.minRadius = config.getParameter("minRadius")
  self.maxRadius = config.getParameter("maxRadius")
  
  self.projectileName = config.getParameter("projectileType")
  self.projectileParameters = config.getParameter("projectileParameters", {})
  self.projectileSpawnInterval = config.getParameter("projectileSpawnInterval")
  self.projectileCount = config.getParameter("projectileCount", 1)
  projectileSpawnTimer = self.projectileSpawnInterval
  
  self.duration = projectile.timeToLive()
end

function update(dt)
  durationRatio = (self.duration - projectile.timeToLive()) / self.duration
  projectilePosition = mcontroller.position()
  projectileSpawnTimer = math.max(0, projectileSpawnTimer - dt)

  if projectileSpawnTimer == 0 then
    projectileSpawnTimer = self.projectileSpawnInterval
    for i = 1, self.projectileCount do
      spawnProjectile()
    end
  end
end

function spawnProjectile()
  if self.angleMode == "random" then
    angle = math.random() * (self.maxAngle - self.minAngle) + self.minAngle
  elseif self.angleMode == "lerp" then
    angle = util.lerp(durationRatio, self.minAngle, self.maxAngle)
  end

  if self.spawnMode == "direction" then
    aimVector = vec2.rotate({1, 0}, angle)
  else
    aimVector = {0, 0}
  end

  if self.spawnMode == "position" then
    radius = util.lerp(durationRatio, self.minRadius, self.maxRadius)
    offset = vec2.rotate({radius, 0}, angle)
    position = vec2.add(projectilePosition, offset)
  else
    position = projectilePosition
  end
  
  world.spawnProjectile(self.projectileName, position, projectile.sourceEntity(), aimVector, false, self.projectileParameters)
end

function nilParameter()
  return self.angleMode == nil
    or self.minAngle == nil
    or self.maxAngle == nil
    or self.minRadius == nil
    or self.maxRadius == nil
    or self.projectileName == nil
end