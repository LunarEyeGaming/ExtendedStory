require "/scripts/pathutil.lua"

-- Function: controlPupilBrightness: sets the global tag "eyeStage" to a given number based on how close the entity is to its target.
-- param targetEntity
-- param targetDistances
function controlPupilBrightness(args, board)
  if not args.targetEntity then return false end
  if not args.targetDistances then return false end
  local targetPosition = world.entityPosition(args.targetEntity)
  local targetDistance = world.magnitude(mcontroller.position(), targetPosition)
  
  if world.lineTileCollision(mcontroller.position(), targetPosition) then
    animator.setGlobalTag("eyeStage", "1")
    return true
  end

  for i, distance in ipairs(args.targetDistances) do
    if not distance then return false end
    if targetDistance > distance then
      animator.setGlobalTag("eyeStage", ""..(i - 1))
      return true
    end
  end
  animator.setGlobalTag("eyeStage", #args.targetDistances)

  return true
end

--Function: lightTooBright: returns whether or not the light level is greater than a certain value.
--param position
--param threshold
function lightTooBright(args, board)
  return world.lightLevel(args.position) > args.threshold
end