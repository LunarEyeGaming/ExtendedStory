require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  self.queryDistance = config.getParameter("detectionRadius", 200)
  self.entityLimit = config.getParameter("entityLimit", 1)
  self.sourceEntity = projectile.sourceEntity()
  entityType = config.getParameter("monsterType")
  self.queryParameters = {
    withoutEntityId = self.sourceEntity,
    includedTypes = {"creature"},
    order = "nearest"
  }

  local ttlVariance = config.getParameter("timeToLiveVariance")
  if ttlVariance then
    projectile.setTimeToLive(projectile.timeToLive() + sb.nrand(ttlVariance))
  end
end

function update(dt)
  local pos = mcontroller.position()
  local entities = world.entityQuery(pos, self.queryDistance, self.queryParameters)
  if entityType == nil then
    sb.logWarn("[Extended Story Debug] Projectile is missing parameter 'monsterType'")
    projectile.die()
  else
    if detectionLimit(entities) == true then
      projectile.die()
    end
  end
end

function detectionLimit(entities)
  validEntities = 0
  for _, entity in pairs(entities) do
    if world.monsterType(entity) == entityType then
      validEntities = validEntities + 1
    end
  end
  if validEntities >= self.entityLimit then
    return true
  else
    return false
  end
end

function destroy()
  if validEntities < self.entityLimit then
    projectile.processAction(projectile.getParameter("destroyAction"))
  end
end