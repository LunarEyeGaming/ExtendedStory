require "/scripts/vec2.lua"

function orbit(targetPosition, targetDistance, targetSpeed)
  -- find closest position at the edge of the orbit
  local toCenterVector = vec2.sub(mcontroller.position(), targetPosition)
  local edgePosition = vec2.add(targetPosition, vec2.mul(vec2.norm(toCenterVector), targetDistance))

  -- get normalized direction to that position
  local toEdgeVector = vec2.sub(edgePosition, mcontroller.position())
  local toEdgeDirection = vec2.norm(toEdgeVector)
  
  -- mix in the direction of the orbit depending on how close we are
  local orbitDirection = vec2.norm(vec2.rotate(toCenterVector, math.pi / (targetSpeed > 0 and -2 or 2)))
  local edgeMixFactor = math.min(1, math.max(0, (vec2.mag(toEdgeVector) / targetDistance)))
  local targetDirection = vec2.add(vec2.mul(toEdgeDirection, edgeMixFactor), vec2.mul(orbitDirection, 1 - edgeMixFactor))

  -- move zig
  mcontroller.approachVelocity(vec2.mul(targetDirection, math.abs(targetSpeed)), 5000)

   local currentDirection = vec2.norm(mcontroller.velocity())
   sb.logInfo("orbit edgeMixFactor %.2f speed %.2f / %.2f distance %.2f / %.2f currentDirection [%.2f, %.2f] edgeDirection [%.2f, %.2f] orbitDirection [%.2f, %.2f]",
       edgeMixFactor,
       vec2.mag(mcontroller.velocity()),
       math.abs(targetSpeed),
       vec2.mag(toCenterVector),
       targetDistance,
       currentDirection[1],
       currentDirection[2],
       toEdgeDirection[1],
       toEdgeDirection[2],
       orbitDirection[1],
       orbitDirection[2])
end
