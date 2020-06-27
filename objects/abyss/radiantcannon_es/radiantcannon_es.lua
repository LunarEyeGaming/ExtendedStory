require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.ammunition = config.getParameter("ammunition")
  
  self.fireOffset = config.getParameter("fireOffset", {0, 0})
  self.projectileType = config.getParameter("projectileType")
  self.projectileConfig = copy(config.getParameter("projectileConfig", {}))

  if storage.isLoaded == nil then
    setDefaultState(config.getParameter("defaultSwitchState", false))
  else
    setDefaultState(storage.isLoaded)
  end
  updateActive()
end

function update(dt)
  items = world.containerItems(entity.id())
  acceptedItems = getMatchingItems(items, self.ammunition)
  if not storage.isLoaded and next(acceptedItems) then
    loadCannon()
    deleteItems(acceptedItems)
  else
    rejectItems(items)
  end
  
  if animator.animationState("cannon") == "loaded" then
    storage.isLoaded = true
  end
end

function getMatchingItems(items, keyItem)
  matchedItems = {}
  for _, item in pairs(items) do
    if item.name == keyItem then
      table.insert(matchedItems, item)
    end
  end
  return matchedItems
end

function deleteItems(items)
  for _, item in pairs(items) do
    world.containerConsume(entity.id(), item)
  end
end

function rejectItems(items)
  deleteItems(items)
  for _, item in pairs(items) do
    world.spawnItem(item, entity.position())
  end
end

function setDefaultState(isLoaded)
  storage.isLoaded = isLoaded
  if isLoaded then
    animator.setAnimationState("cannon", "loaded")
  else
    animator.setAnimationState("cannon", "empty")
  end
end

function fireCannon()
  storage.isLoaded = false
  animator.setAnimationState("cannon", "fire")
  animator.playSound("fire")
  animator.burstParticleEmitter("fire")
  
  world.spawnProjectile(self.projectileType, vec2.add(entity.position(), {self.fireOffset[1] * object.direction(), self.fireOffset[2]}), entity.id(), {object.direction(), 0}, false, self.projectileConfig)
end

function loadCannon()
  animator.setAnimationState("cannon", "loading")
  animator.playSound("loading")
end

function onInputNodeChange(args)
  updateActive()
end

function onNodeConnectionChange(args)
  updateActive()
end

function updateActive()
  local active = object.isInputNodeConnected(0) and object.getInputNodeLevel(0)
  if storage.isLoaded and active then
    fireCannon()
  end
end
