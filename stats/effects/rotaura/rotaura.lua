require "/scripts/status.lua"

function init()
  currentHealthAmount = status.resourcePercentage("health")
end

function update(dt)
  oldHealthAmount = currentHealthAmount
  currentHealthAmount = status.resourcePercentage("health")
  if currentHealthAmount < oldHealthAmount then
    world.spawnProjectile("rotaura", mcontroller.position(), entity.id())
  end
end
