require "/scripts/util.lua"

function init()
  animator.resetTransformationGroup("eye")
  animator.setAnimationState("eye", "idle")

  self.eyeOffset = config.getParameter("eyeOffset")
  self.activateCooldown = config.getParameter("activateCooldown")
  self.activeTime = config.getParameter("activeTime")
  self.detectionArea = config.getParameter("detectionArea")
  self.detectThroughCollisions = config.getParameter("detectThroughCollisions")

  animator.translateTransformationGroup("eye", self.eyeOffset)
  animator.rotateTransformationGroup("eye", util.toRadians(config.getParameter("eyeAngle")), self.eyeOffset)
  setStage(0, self.activateCooldown)
end

function update(dt)
  if not object.isInputNodeConnected(0) or object.getInputNodeLevel(0) then
    if self.stage == 0 then
      sentryIdle(dt)
    elseif self.stage == 1 then
      sentryActive(dt)
    end
  end
end

function sentryIdle(dt)
  if self.timer == 0 then
    animator.setAnimationState("eye", "activate")
    animator.playSound("activate")
    setStage(1, self.activeTime)
    return
  end
  
  self.timer = math.max(0, self.timer - dt)
end

function sentryActive(dt)
  if self.timer == 0 then
    object.setAllOutputNodes(false)
    setStage(0, self.activateCooldown)
    return
  end
  
  self.timer = math.max(0, self.timer - dt)
  local area = translateDetectionArea(self.detectionArea)
  local entities = world.entityQuery({area[1], area[2]}, {area[3], area[4]}, {includedTypes = {"player"}})
  if #entities > 0 and (self.detectThroughCollisions or not allEntitiesBlocked(entities)) then
    object.setAllOutputNodes(true)
  else
    object.setAllOutputNodes(false)
  end
end

function translateDetectionArea(rect)
  local pos = entity.position()
  return {
      rect[1] + pos[1],
      rect[2] + pos[2],
      rect[3] + pos[1],
      rect[4] + pos[2]
    }
end

function allEntitiesBlocked(entities)
  for _, item in pairs(entities) do
    if not world.lineTileCollision(entity.position(), world.entityPosition(item)) then
      return false
    end
  end
  
  return true
end

function setStage(newStage, newTimer)
  self.stage = newStage
  self.timer = newTimer
end