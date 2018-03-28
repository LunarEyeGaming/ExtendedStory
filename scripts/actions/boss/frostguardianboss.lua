require "/scripts/pathutil.lua"


-- param center
-- param areaHeight
-- param projectileType
-- param blockCount
-- param blockWidth
-- output pillars
function spawnFrostBlocks(args, board)
  if args.center == nil or args.areaWidth == nil or args.pillarCount == nil then return false end

  local groundBlock = world.collisionBlocksAlongLine(args.center, vec2.add(args.center, {0, -50}))[1]
  local projectileSpawnLevel = groundBlock[2] + 1.0 - (args.pillarHeight / 2)
  local start = {args.center[1] - args.areaWidth / 2, projectileSpawnLevel}
  local spacing = args.areaWidth / (args.pillarCount + 1)
  local projectileType = args.projectileType

  local ids = {}
  for i = 1, args.pillarCount do
    local position = vec2.add(start, {spacing * i, 0})
    local projectileId = world.spawnProjectile(projectileType, position, entity.id(), {0,0}, false)
    table.insert(ids, projectileId)
  end

  return true, {pillars = ids}
end
