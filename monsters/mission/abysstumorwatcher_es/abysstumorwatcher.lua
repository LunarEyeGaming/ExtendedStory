
function init()
  monster.setDeathParticleBurst("deathPoof")
  self.targetRadius = config.getParameter("targetRadius")
  self.targetTypes = config.getParameter("targetTypes")
  self.disappearRadius = config.getParameter("disappearRadius")

  self.target = nil
  self.visible = true
  
  if config.getParameter("uniqueId") then
    monster.setUniqueId(config.getParameter("uniqueId"))
  end

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end

  message.setHandler("despawn", despawn)
  
  message.setHandler("teleport", function(_, _, position)
    animator.setAnimationState("body", "invisible")
    self.visible = false
    mcontroller.setPosition(position)
  end)
  
  monster.setDamageBar(config.getParameter("damageBar", "None"))
end

function shouldDie()
  return not status.resourcePositive("health")
end

function update(dt)
  if self.target and world.entityExists(self.target) then
    local targetPosition = world.entityPosition(self.target)
    local currentPosition = mcontroller.position()
    local shouldDisappear = world.magnitude(targetPosition, currentPosition) < self.disappearRadius
    if self.visible then
      updateEye(targetPosition)
      if shouldDisappear then
        self.visible = false
        animator.setAnimationState("body", "disappear")
      end
    elseif not shouldDisappear then
      self.visible = true
      animator.setAnimationState("body", "appear")
    end
  else
    local entities = queryEntities(self.targetRadius, self.targetTypes)
    if #entities > 0 then
      self.target = entities[1]
    end
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

function updateEye(lookPosition)
  animator.resetTransformationGroup("body")
  local rotationAngle = vec2.angle(world.distance(lookPosition, mcontroller.position()))
  animator.rotateTransformationGroup("body", rotationAngle)
end