require "/scripts/vec2.lua"

function init()
  self.nextMaterial = config.getParameter("nextMaterial")
end

function update(dt)
end

function destroy()
  if self.nextMaterial then
    world.placeMaterial(mcontroller.position(), "foreground", self.nextMaterial)
  end
end