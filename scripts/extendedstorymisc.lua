

function detectStatusEffect(statusEffect)
  --Returns whether or not a specified status effect is active for an entity
  --Table for status.activeUniqueStatusEffectSummary() is listed as {1: {1: statuseffectname, 2: <remaining duration to max duration ratio>}, 2: {1: statuseffectname, 2: <remaining duration to max duration ratio>}, 3:{1: statuseffectname, 2: <remaining duration to max duration ratio>}}
  --Also, it is completely necessary to make statusEffectExists true or false. A lua error will be thrown if the return function is called in the for loop
  statusEffectExists = false
  statusEffects = status.activeUniqueStatusEffectSummary()
  if statusEffect == nil then
    sb.logWarn("Value 'statusEffect' is not defined")
  else
    for _, effect in pairs(statusEffects) do
      if effect[1] == statusEffect then
	    statusEffectExists = true
		break
	  end
    end
	return statusEffectExists
  end
end

function selectPositionFromBorder(rect)
  --Selects a position along the border of the given rectangle
  local modes = {"left", "right", "down", "up"}
  local modeIndex = math.random(1, 4)
  local mode = modes[modeIndex]
  if mode == "left" then
    position = {rect[1], math.random(rect[2], rect[4])}
  elseif mode == "right" then
    position = {rect[3], math.random(rect[2], rect[4])}
  elseif mode == "down" then
    position = {math.random(rect[1], rect[3]), rect[2]}
  else
    position = {math.random(rect[1], rect[3]), rect[4]}
  end
  return position
end

function spawnProjectileAlongBorder(rect, args)
  --Spawns a single projectile at a random position that is in the outline of the rectangle.
  --args: projectileName, [EntityId sourceEntityId], [Vec2F direction], [bool trackSourceEntity], [Json parameters]
  position = selectPositionFromBorder(rect)
  while world.pointCollision(position) do
    position = selectPositionFromBorder(rect)
  end
  return world.spawnProjectile(args[1], position, args[2], args[3], args[4], args[5])
end