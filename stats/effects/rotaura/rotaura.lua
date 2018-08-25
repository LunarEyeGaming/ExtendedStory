require "/scripts/status.lua"

function init()
  self.listener = damageListener("damageTaken", function()
    world.spawnProjectile("rotaura", mcontroller.position(), entity.id())
  end)
end

function update(dt)
  self.listener:update()
end
