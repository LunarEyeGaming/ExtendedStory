require "/scripts/status.lua"

function init()
<<<<<<< HEAD
  currentHealthAmount = status.resourcePercentage("health")
  tickTimer = config.getParameter("tickTimer", 1)
end

function update(dt)
  tickTimer = tickTimer - dt
  oldHealthAmount = currentHealthAmount
  currentHealthAmount = status.resourcePercentage("health")
  if currentHealthAmount < oldHealthAmount then
=======
  tickTimer = config.getParameter("tickTimer", 1)
  self.listener = damageListener("damageTaken", function()
>>>>>>> bdc64ba7133a751c26b47322227b721e705bbd54
    if tickTimer <= 0 then
	  tickTimer = 1
	  attemptDamage()
	end
<<<<<<< HEAD
  end
=======
  end)
end

function update(dt)
  tickTimer = tickTimer - dt
  self.listener:update()
>>>>>>> bdc64ba7133a751c26b47322227b721e705bbd54
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
    world.spawnProjectile("ancientexplosion", world.entityPosition(monster), entity.id(), {0, 0}, false, {power = 500, statusEffects = {"gammarays"}})
  end
end