require "/scripts/status.lua"
require "/scripts/vec2.lua"

function init()
  local nearby = world.entityQuery(mcontroller.position(), 30, {includedTypes = {"monster", "npc"}, order = "nearest"})
  grabOffset = config.getParameter("grabOffset", {0, 0})
  grabDirection = config.getParameter("grabDirection", 1)
  mcontroller.controlFace(grabDirection)
  target = nearby[1]
  initialDuration = effect.duration()
  
  animator.setAnimationRate(0)
  if status.isResource("stunned") then
    status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
  end
end

function update(dt)
  currentDuration = effect.duration()
  if currentDuration < initialDuration and currentDuration > 0 then
    if not target or not world.entityExists(target) then
      effect.expire()
      return
    end
    effect.modifyDuration(initialDuration - currentDuration)
  end

  local pos = world.entityPosition(target)
  mcontroller.setPosition(vec2.add(pos, grabOffset))
  mcontroller.setVelocity({0, 0})
  mcontroller.controlFace(grabDirection)
  mcontroller.controlModifiers({
      facingSuppressed = true,
      movementSuppressed = true
    })
end