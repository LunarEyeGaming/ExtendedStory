function init()
  monster.setDeathParticleBurst("deathPoof")
  self.targetRadius = config.getParameter("targetRadius")
  self.targetTypes = config.getParameter("targetTypes")
  self.disappearRadius = config.getParameter("disappearRadius")
  self.target = nil
  
  if config.getParameter("uniqueId") then
    monster.setUniqueId(config.getParameter("uniqueId"))
  end

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end

  message.setHandler("despawn", despawn)
end

function shouldDie()
  return not status.resourcePositive("health")
end

function update(dt)
  animator.resetTransformationGroup("body")
  local entities = queryEntities(self.targetRadius, self.targetTypes)
  if #entities > 0 then
    if not self.target or not world.entityExists(self.target) then
      self.target = entities[1]
    end
    local rotationAngle = vec2.angle(world.distance(world.entityPosition(self.target), mcontroller.position()))
    animator.rotateTransformationGroup("body", rotationAngle)
  end
  if self.target then
    if world.magnitude(world.entityPosition(self.target), mcontroller.position()) < self.disappearRadius then
      status.setResourcePercentage("health", 0.0)
    end
    if status.resourcePositive("health") then
      animator.setAnimationState("body", "idle")
    end
  else
    animator.setAnimationState("body", "invisible")
  end
end

function despawn()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end

function queryEntities(radius, types)
  local queried = world.entityQuery(mcontroller.position(), radius, {withoutEntityId = entity.id(), includedTypes = types, order = "nearest"})

  local results = {}
  for _, ent in pairs(queried) do
    if entity.isValidTarget(ent) then
      table.insert(results, ent)
    end
  end
  
  return results
end