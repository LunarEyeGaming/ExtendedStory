require "/scripts/util.lua"
require "/scripts/rect.lua"

-- param position
-- param flightTime
-- param projectileCount
-- param projectileType
-- param projectileConfig
-- param projectileOffset
-- param projectileBaseDamage
-- param aimVector
-- output projectiles
function moveFire(args, board)
  local power = args.projectileBaseDamage * root.evalFunction("monsterLevelPowerMultiplier", monster.level())

  local posDistance = world.distance(mcontroller.position(), args.position)
  local velocity = vec2.mul(posDistance, 1 / args.flightTime)
  local projectileInterval = args.flightTime / args.projectileCount
  
  while mcontroller.position() ~= args.position do
    util.wait(projectileInterval, function()
      mcontroller.setVelocity(velocity)
    end)
    local pParams = copy(args.projectileConfig)
    local spawnPosition = vec2.add(mcontroller.position(), projectileOffset)
    local projectileId = world.spawnProjectile(args.projectileType, spawnPosition, entity.id(), args.aimVector, false, pParams)
    table.insert(projectiles, projectileId)
  end

  return true, {projectiles = projectiles}
end

-- param position
-- param offsetBounds
-- param center
-- output position
function clampPosition(args, board)
  if args.position == nil or args.offsetBounds == nil or args.center == nil then return false end
  local bounds = rect.translate(args.offsetBounds, args.center)
  
  return true, {position = {util.clamp(args.position[1], bounds[1], bounds[3]), util.clamp(args.position[2], bounds[2], bounds[4])}}
end