function init()
  self.targetRadius = config.getParameter("targetRadius")
  self.projectileType = config.getParameter("firedProjectile")
  self.projectileConfig = config.getParameter("firedProjectileConfig")
  self.projectileConfig.power = self.projectileConfig.power or projectile.power()
  self.queryDelta = 10
  self.queryStep = self.queryDelta
end

function update(dt)
  self.queryStep = math.max(0, self.queryStep - 1)
  if self.queryStep == 0 then
    local near = world.entityQuery(mcontroller.position(), self.targetRadius, { includedTypes = {"monster", "npc"} })
    for _,entityId in pairs(near) do
      if entity.isValidTarget(entityId) then
        if not targetId then
          targetId = entityId
        end
        projectile.die()
      end
    end
    self.queryStep = self.queryDelta
  end
end

function destroy()
  local selfPosition = mcontroller.position()
  if projectile.sourceEntity() and world.entityExists(projectile.sourceEntity()) and targetId then
    world.spawnProjectile(self.projectileType, selfPosition, projectile.sourceEntity(), world.distance(world.entityPosition(targetId), selfPosition), false, self.projectileConfig)
    local foundTargetAction = config.getParameter("foundTargetAction")
    if next(foundTargetAction) ~= nil then
      projectile.processAction(foundTargetAction)
    end
  end
end
