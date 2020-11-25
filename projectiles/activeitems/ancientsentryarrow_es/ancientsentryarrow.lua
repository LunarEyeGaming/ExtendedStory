require "/scripts/util.lua"

function init()
  self.fireRadius = config.getParameter("fireRadius")
  self.fireTime = config.getParameter("fireTime")
  self.orbiterCount = config.getParameter("orbiterCount")
  self.projectile = config.getParameter("orbiterProjectile")
  self.projectileConfig = config.getParameter("orbiterProjectileConfig")
  self.projectileConfig.power = self.projectileConfig.power or projectile.power()
  self.projectileConfig.masterId = entity.id()

  self.orbiters = {}
  for i = 1, self.orbiterCount do
    local orbiterParams = copy(self.projectileConfig)
    orbiterParams.startAngle = 2 * math.pi * i / self.orbiterCount
    local orbiter = world.spawnProjectile(self.projectile, mcontroller.position(), projectile.sourceEntity(), {0, 0}, false, orbiterParams)
    table.insert(self.orbiters, orbiter)
  end
  self.fireTimer = self.fireTime
  message.setHandler("kill", projectile.die)
end

function update(dt)
  if #self.orbiters == 0 then
    projectile.die()
  end

  self.fireTimer = math.max(0, self.fireTimer - dt)
  local near = world.entityQuery(mcontroller.position(), self.fireRadius, { includedTypes = {"monster", "npc"}, order = "nearest" })
  
  for i, ent in ipairs(near) do
    if not entity.isValidTarget(ent) then
      table.remove(near, i)
    end
  end
  
  if #near > 0 and #self.orbiters > 0 and self.fireTimer == 0 then
    local orbiterNum = math.random(1, #self.orbiters)
    local orbiter = table.remove(self.orbiters, orbiterNum)
    if world.entityExists(orbiter) and not world.lineTileCollision(mcontroller.position(), world.entityPosition(near[1])) then
      world.sendEntityMessage(orbiter, "kill", near[1])
    end
    self.fireTimer = self.fireTime
  end
end

function destroy()
  for _, orbiter in pairs(self.orbiters) do
    world.sendEntityMessage(orbiter, "kill")
  end
end
