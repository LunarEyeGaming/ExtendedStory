require "/scripts/pathutil.lua"
require "/scripts/vec2.lua"
require "/scripts/util.lua"

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

-- param float fireInterval
-- param float fireSpeed
-- param string projTypeMarker
-- param string projTypePointer
-- param position sweepStartPos
-- param position sweepEndPos

function plasmaSweepTelegraph(args, board)
  local Y_OFFSET = 1
  local CURRENT_POS = mcontroller.position()
  local DIR = world.distance(args.sweepEndPos, args.sweepStartPos)[1] > 0 and 1 or -1
  local X_INC = args.fireInterval * args.fireSpeed * DIR
  local X_SWEEP_END_POS = args.sweepEndPos[1]
  local Y_POS = world.lineCollision(CURRENT_POS, vec2.add(CURRENT_POS, {0, -100}))[2] + Y_OFFSET


  local xPos = args.sweepStartPos[1]  
  while (DIR == 1 and xPos <= X_SWEEP_END_POS) or (DIR == -1 and xPos >= X_SWEEP_END_POS) do
    world.spawnProjectile(args.projTypeMarker, {xPos, Y_POS}, entity.id(), {0, 0})
    --local aimDir = world.distance({xPos, Y_POS}, CURRENT_POS)
    --world.spawnProjectile(args.projTypePointer, CURRENT_POS, entity.id(), aimDir)
    xPos = xPos + X_INC
    util.run(args.fireInterval, function() end)
  end
  
  return true
end

-- param center
-- param areaWidth
-- param segmentWidth
-- param projectileCount
-- param power
-- param projectileCount
-- param aimVector
-- param spawnInterval
-- output projectiles
function spawnGapProjectiles(args, board)
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
  --local groundLevel = world.collisionBlocksAlongLine(args.center, vec2.add(args.center, {0, -50}))[1][2] + 1.0
  local projectiles = {}
  for i, spawnProjectile in ipairs(segments) do
    if spawnProjectile then
      local spawnPosition = vec2.add(start, {i * args.segmentWidth - (args.segmentWidth / 2), 0})
      local params = {
        power = power,
        timeToLive = args.timeToLive
      }
      local projectileId = world.spawnProjectile(args.projectileType, spawnPosition, entity.id(), args.aimVector, false, params)
      table.insert(projectiles, projectileId)
      util.run(args.spawnInterval, function() end)
    end
  end

  return true, {projectiles = projectiles}
end

-- param position position1
-- param position position2
-- param int numRows
-- param int numCols
-- (not implemented) param float interval
-- output list entities
-- Precondition: position2[1] - position1[1] > 0, position2[2] - position1[2] > 0

function spawnShieldCores(args, board)
  if args.position1 == nil or args.position2 == nil or args.numRows == nil or args.numCols == nil then return false end
  local DIST = world.distance(args.position2, args.position1)
  local X_INC = DIST[1] / (args.numCols - 1)
  local Y_INC = DIST[2] / (args.numRows - 1)
  local shieldCoreIds = {}

  for yOffset = 0, DIST[2], Y_INC do
    for xOffset = 0, DIST[1], X_INC do
      shieldCoreId = world.spawnMonster("ancientfragment", vec2.add(args.position1, {xOffset, yOffset}), {level = monster.level()})
      table.insert(shieldCoreIds, shieldCoreId)
      --sb.logInfo("[Extended Story Debug] pos = %s", vec2.add(args.position1, {xOffset, yOffset}))
    end
  end
  
  return true, {entities = shieldCoreIds}
end