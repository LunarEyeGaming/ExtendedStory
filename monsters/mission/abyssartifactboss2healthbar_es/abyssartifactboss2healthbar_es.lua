require "/scripts/status.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"

function init()
  script.setUpdateDelta(config.getParameter("initialScriptDelta", 5))
  monster.setDeathParticleBurst("deathPoof")

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end
  if config.getParameter("uniqueId") then
    monster.setUniqueId(config.getParameter("uniqueId"))
  end

  message.setHandler("despawn", despawn)
  
  monster.setDamageBar("special")
  
  self.uid1 = "bosseye"
  self.uid2 = "grabber"
  
  self.entity1 = world.loadUniqueEntity(self.uid1)
  self.entity2 = world.loadUniqueEntity(self.uid2)
end

function shouldDie()
  return status.resourcePercentage("health") == 0
end

function update(dt)
  if self.entity1 == 0 or self.entity2 == 0 then
    if self.entity1 == 0 then
      sb.logInfo("Entity 1 is nil")
      self.entity1 = world.loadUniqueEntity(self.uid1)
    else
      sb.logInfo("Entity 2 is nil")
      sb.logInfo("%s", self.entity2)
      self.entity2 = world.loadUniqueEntity(self.uid2)
    end
    return
  end
  local health1 = world.entityHealth(self.entity1) or {0, 1}
  local health2 = world.entityHealth(self.entity2) or {0, 1}
  
  local healthPercentage = (health1[1] / health1[2] + health2[1] / health2[2]) / 2
  status.setResourcePercentage("health", healthPercentage)
end

function despawn()
  hasDespawned = true
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end