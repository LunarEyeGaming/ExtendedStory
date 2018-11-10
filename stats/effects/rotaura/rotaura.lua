require "/scripts/status.lua"

function init()
<<<<<<< HEAD
  currentHealthAmount = status.resourcePercentage("health")
end

function update(dt)
  oldHealthAmount = currentHealthAmount
  currentHealthAmount = status.resourcePercentage("health")
  if currentHealthAmount < oldHealthAmount then
    world.spawnProjectile("rotaura", mcontroller.position(), entity.id())
  end
=======
  self.listener = damageListener("damageTaken", function()
    world.spawnProjectile("rotaura", mcontroller.position(), entity.id())
  end)
end

function update(dt)
  self.listener:update()
>>>>>>> bdc64ba7133a751c26b47322227b721e705bbd54
end
