require "/scripts/pathutil.lua"

-- param center
-- param areaWidth
-- param segmentWidth
-- param projectileCount
-- param power
-- param projectileCount
-- param spawnHeight
-- output projectiles
function spawnFloorProjectiles(args, board)
  local power = args.power * root.evalFunction("monsterLevelPowerMultiplier", monster.level())

  local segmentCount = math.floor(args.areaWidth / args.segmentWidth)
  local segments = {}
  for i = 1, args.projectileCount do
    table.insert(segments, true)
  end
  for i = 1, segmentCount - args.projectileCount do
    table.insert(segments, false)
  end
  shuffle(segments)

  local start = vec2.add(args.center, {-args.areaWidth / 2, 0})
  local groundLevel = world.collisionBlocksAlongLine(args.center, vec2.add(args.center, {0, -50}))[1][2] + 1.0
  local projectiles = {}
  for i,spawnProjectile in ipairs(segments) do
    if spawnProjectile then
      local spawnPosition = vec2.add(start, {i * args.segmentWidth - (args.segmentWidth / 2), 0})
      spawnPosition[2] = groundLevel + args.spawnHeight
      local params = {
        power = power,
        timeToLive = args.timeToLive
      }
      local projectileId = world.spawnProjectile(args.projectileType, spawnPosition, entity.id(), {0, 0}, false, params)
      table.insert(projectiles, projectileId)
    end
  end

  return true, {projectiles = projectiles}
end


-- param center
-- param areaWidth
-- param projectileType
-- param pillarCount
-- param pillarHeight
-- output pillars
function spawnAncientPillars(args, board)
  if args.center == nil or args.areaWidth == nil or args.pillarCount == nil then return false end

  local groundBlock = world.collisionBlocksAlongLine(args.center, vec2.add(args.center, {0, -50}))[1]
  local projectileSpawnLevel = groundBlock[2] + 1.0 - (args.pillarHeight / 2)
  local start = {args.center[1] - args.areaWidth / 2, projectileSpawnLevel}
  local spacing = args.areaWidth / (args.pillarCount + 1)

  local ids = {}
  for i = 1, args.pillarCount do
    local position = vec2.add(start, {spacing * i, 0})
    local projectileId = world.spawnProjectile("ancientpillar", position, entity.id(), {0,0}, false)
    table.insert(ids, projectileId)
  end

  return true, {pillars = ids}
end
