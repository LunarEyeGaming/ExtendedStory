require "/scripts/vec2.lua"

function init()
  self.rotStages = config.getParameter("rotStages")
end

function update(dt)
end

function destroy()
  local material = world.material(mcontroller.position(), "foreground")
  if material then
    nextMaterial = self.rotStages[material]
  end
  if nextMaterial then
    world.damageTiles({mcontroller.position()}, "foreground", mcontroller.position(), "blockish", 9999, 0)
    if nextMaterial ~= "air" then
      --world.placeMaterial(mcontroller.position(), "foreground", nextMaterial)
      local parameters = {nextMaterial = nextMaterial}
      --local position = {math.floor(mcontroller.position()[1]), math.floor(mcontroller.position()[2])}
      world.spawnProjectile("worldrot2_es", mcontroller.position(), projectile.sourceEntity(), {1, 0}, false, parameters)
    end
  end
end