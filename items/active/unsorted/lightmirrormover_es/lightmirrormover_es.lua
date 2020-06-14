require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  activeItem.setCursor("/cursors/reticle0.cursor")
  
  self.stance = "idle"
  
  self.animationStates = config.getParameter("animationStates", {})

  self.adjustmentCooldown = config.getParameter("adjustmentCooldown")
  self.fireCooldown = config.getParameter("fireCooldown")
  
  self.adjustmentEnergyCost = config.getParameter("adjustmentEnergyCost", 0)
  self.fireEnergyCost = config.getParameter("fireEnergyCost", 0)
  
  self.messengerUid = config.getParameter("messengerUid")
  self.positionRPC = world.findUniqueEntity(self.messengerUid)
  storage.messengerId = nil
  self.adjustMessage = config.getParameter("adjustMessage")
  self.fireMessage = config.getParameter("fireMessage")
  
  self.focusOffset = config.getParameter("focusOffset")
  
  self.idleAngle = util.toRadians(config.getParameter("idleAngle"))
  self.castingAngle = util.toRadians(config.getParameter("castingAngle"))
  
  self.returnDelay = config.getParameter("returnDelay")
  self.returnTime = config.getParameter("returnTime")
  
  storage.adjustTimer = self.adjustmentCooldown
  storage.fireTimer = self.fireCooldown
  self.stanceTimer = self.returnDelay
  self.angleOffset = self.idleAngle
end

function activate(fireMode, shiftHeld)
  if fireMode == "alt" and storage.fireTimer == 0 and status.overConsumeResource("energy", self.fireEnergyCost) then
    fireMirror()
  end
end

function update(dt, fireMode, shiftHeld)
  if self.positionRPC and self.positionRPC:finished() then
    if self.positionRPC:succeeded() then
      self.messengerPosition = self.positionRPC:result()
    end
    self.positionRPC = nil
  end

  if self.messengerPosition then
    local entities = world.entityQuery(self.messengerPosition, 1)
    for _, entity in pairs(entities) do
      if world.entityUniqueId(entity) == self.messengerUid then
        storage.messengerId = entity
      end
    end
    self.messengerPosition = nil
  end

  updateAim()
  
  if self.stance == "idle" then
    self.angleOffset = self.idleAngle
  elseif self.stance == "casting" then
    self.angleOffset = self.castingAngle
    self.stanceTimer = math.max(self.stanceTimer - dt, 0)
    if self.stanceTimer == 0 then
      setStage("cooldown", self.returnTime)
    end
  elseif self.stance == "cooldown" then
    local progress = (self.returnTime - self.stanceTimer) / self.returnTime
    self.angleOffset = util.lerp(progress, self.castingAngle, self.idleAngle)
    self.stanceTimer = math.max(self.stanceTimer - dt, 0)
    if self.stanceTimer == 0 then
      self.stance = "idle"
    end
  end
  
  storage.adjustTimer = math.max(storage.adjustTimer - dt, 0)
  storage.fireTimer = math.max(storage.fireTimer - dt, 0)

  if fireMode == "primary"
      and storage.adjustTimer == 0
      and status.overConsumeResource("energy", self.adjustmentEnergyCost) then
    adjustMirror()
  end
end

function discardedMessengerId()
  return storage.messengerId == nil or not world.entityExists(storage.messengerId)
end

function adjustMirror()
  storage.adjustTimer = self.adjustmentCooldown
  setStage("casting", self.returnDelay)
  if discardedMessengerId() then
    animator.playSound("error")
    return
  end
  animator.playSound("adjust")
    for stateType, state in pairs(self.animationStates) do
      animator.setAnimationState(stateType, state)
    end
  world.sendEntityMessage(storage.messengerId, self.adjustMessage, activeItem.ownerAimPosition())
end

function fireMirror()
  storage.fireTimer = self.fireCooldown
  setStage("casting", self.returnDelay)
  if discardedMessengerId() then
    animator.playSound("error")
    return
  end
  animator.playSound("trigger")
    for stateType, state in pairs(self.animationStates) do
      animator.setAnimationState(stateType, state)
    end
  world.sendEntityMessage(storage.messengerId, self.fireMessage)
end

function updateAim()
  self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(self.focusOffset[2], activeItem.ownerAimPosition())
  activeItem.setArmAngle(self.aimAngle + self.angleOffset)
  activeItem.setFacingDirection(self.aimDirection)
end

function setStage(stage, timer)
  self.stance = stage
  self.stanceTimer = timer
end

function uninit()
end
