require "/scripts/vec2.lua"

function init()
  storage.timer = storage.timer or 0
  
  if storage.active == nil then
    updateActive()
  end
  object.setSoundEffectEnabled(storage.active)

  self.fireTime = config.getParameter("fireTime", 1)
  self.fireTimeVariance = config.getParameter("fireTimeVariance", 0)
  self.projectile = config.getParameter("projectile")
  self.projectileConfig = config.getParameter("projectileConfig", {})
  self.projectilePosition = config.getParameter("projectilePosition", {0, 0})
  self.projectileDirection = config.getParameter("projectileDirection", {1, 0})
  self.inaccuracy = config.getParameter("inaccuracy", 0)

  self.projectilePosition = object.toAbsolutePosition(self.projectilePosition)
end

function update(dt)
  players = broadcastAreaQuery({ includedTypes = {"player"} })
  playersInWorld = world.players()
  if storage.active then
    if players then
	  world.spawnProjectile("spheredeactivater", entity.position(), entity.id(), {1, 0}, false, {damageTeam = {type = "indiscriminate"}})
	end
  end
end

function translateBroadcastArea()
  local broadcastArea = config.getParameter("broadcastArea", {-8, -8, 8, 8})
  local pos = entity.position()
  return {
      broadcastArea[1] + pos[1],
      broadcastArea[2] + pos[2],
      broadcastArea[3] + pos[1],
      broadcastArea[4] + pos[2]
    }
end

function broadcastAreaQuery(options)
  local area = translateBroadcastArea()
  return world.entityQuery({area[1], area[2]}, {area[3], area[4]}, options)
end

function onNodeConnectionChange(args)
  updateActive()
end

function onInputNodeChange(args)
  updateActive()
end

function updateActive()
  local active = (not object.isInputNodeConnected(0)) or object.getInputNodeLevel(0)
  if active ~= storage.active then
    storage.active = active
    if active then
      storage.timer = 0
      animator.setAnimationState("trapState", "on")
    else
      animator.setAnimationState("trapState", "off")
    end
  end
end
