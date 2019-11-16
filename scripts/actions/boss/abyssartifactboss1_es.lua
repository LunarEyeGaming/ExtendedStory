require "/scripts/pathutil.lua"

-- Function: spawnPositionedGapProjectiles: Functionally similar to Kluex Avatar's ice attack, but it is vertical and inputs the designated points as projectile parameters instead of their respective spawn positions.
-- param center
-- param spawnCenter
-- param areaHeight
-- param segmentHeight
-- param projectileCount
-- param power
-- param travelXOffset
-- param aimVector
-- output projectiles
function spawnPositionedGapProjectiles(args, board)
  local power = args.power * root.evalFunction("monsterLevelPowerMultiplier", monster.level())

  local segmentCount = math.floor(args.areaHeight / args.segmentHeight)
  local segments = {}
  for i = 1, args.projectileCount do
    table.insert(segments, true)
  end
  for i = 1, segmentCount - args.projectileCount do
    table.insert(segments, false)
  end
  shuffle(segments)

  local travelCenterOffset = world.distance(args.center, args.spawnCenter)
  sb.logInfo("[Extended Story Debug] travelCenterOffset: %s", travelCenterOffset)
  local projectiles = {}
  for i,spawnProjectile in ipairs(segments) do
    if spawnProjectile then
      local travelOffset = vec2.add({travelCenterOffset[1], travelCenterOffset[2] - args.areaHeight / 2}, {0, i * args.segmentHeight - (args.segmentHeight / 2)})
      travelOffset[1] = travelOffset[1] + args.travelXOffset
      local params = {
        power = power,
        timeToLive = args.timeToLive,
        targetOffset = travelOffset
      }
      local projectileId = world.spawnProjectile(args.projectileType, args.spawnCenter, entity.id(), args.aimVector, false, params)
      table.insert(projectiles, projectileId)
    end
  end

  return true, {projectiles = projectiles}
end
