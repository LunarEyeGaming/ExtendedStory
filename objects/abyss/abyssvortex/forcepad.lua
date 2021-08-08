function init()
  projectile = world.spawnProjectile("abyssvortextrap", entity.position(), entity.id(), {1, 0}, false, {speed = 0, damageTeam = {type = "indiscriminate"}})
  updateActive()
end

function onInputNodeChange(args)
  updateActive()
end

function onNodeConnectionChange(args)
  updateActive()
end

function updateActive()
  local active = not object.isInputNodeConnected(0) or object.getInputNodeLevel(0)
  physics.setForceEnabled("jumpForce", active)
  animator.setAnimationState("padState", active and "open" or "close")
  if active then
    projectile = world.spawnProjectile("abyssvortextrap", entity.position(), entity.id(), {1, 0}, false, {speed = 0, damageTeam = {type = "indiscriminate"}})
  elseif projectile then
    world.sendEntityMessage(projectile, "kill")
  end
end