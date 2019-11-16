require "/scripts/status.lua"

function init()
  currentHealthAmount = status.resourcePercentage("health")
  tickTimer = config.getParameter("tickTimer", 1)
end

function update(dt)
  tickTimer = tickTimer - dt
  oldHealthAmount = currentHealthAmount
  currentHealthAmount = status.resourcePercentage("health")
  if currentHealthAmount < oldHealthAmount then
    if tickTimer <= 0 then
	  tickTimer = 1
	  attemptDamage()
	end
  end
end

function attemptDamage()
  chance = math.random(1, 3)
  if chance == 3 then
    attackMonsters()
  end
end

function attackMonsters()
  self.position = mcontroller.position()
  affectedMonsters = world.entityQuery(self.position, 30, {includedTypes = {"monster", "npc"}})
  for _, monster in pairs(affectedMonsters) do
    world.spawnProjectile("ancientexplosion", world.entityPosition(monster), entity.id(), {0, 0}, false, {power = 50, statusEffects = {"gammarays"}})
  end
end