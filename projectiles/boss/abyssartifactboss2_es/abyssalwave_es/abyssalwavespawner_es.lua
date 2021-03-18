require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.targetOffsetRange = config.getParameter("targetOffsetRange")
  self.spawnOffsetRange = config.getParameter("spawnOffsetRange")
  self.shardVariants = config.getParameter("shardVariants")
  self.shardCount = config.getParameter("shardCount")
  
  for i = 1, self.shardCount do
    local targetOffset = {
      util.randomIntInRange({self.targetOffsetRange[1], self.targetOffsetRange[3]}), 
      util.randomIntInRange({self.targetOffsetRange[2], self.targetOffsetRange[4]})
    }
    local spawnOffset = {
      util.randomIntInRange({self.spawnOffsetRange[1], self.spawnOffsetRange[3]}), 
      util.randomIntInRange({self.spawnOffsetRange[2], self.spawnOffsetRange[4]})
    }
    local targetPosition = vec2.add(mcontroller.position(), targetOffset)
    local spawnPosition = vec2.add(mcontroller.position(), spawnOffset)
  
    local timeToLive = projectile.timeToLive()
    local parameters = {targetPosition = targetPosition, timeToLive = timeToLive, travelTime = timeToLive, animationCycle = timeToLive}
    local variant = math.random(1, self.shardVariants)
    world.spawnProjectile("abyssalwaveshard"..variant.."_es", spawnPosition, projectile.sourceEntity(), {1, 0}, true, parameters)
    world.spawnProjectile("abyssalwaveshard"..variant.."fullbright_es", spawnPosition, projectile.sourceEntity(), {1, 0}, true, parameters)
  end
end

function update(dt)
end