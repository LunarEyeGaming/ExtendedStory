function init()
  if storage.timer == nil then
    storage.timer = 0
  end
  self.recipientUId = config.getParameter("recipientUId")
  self.messageType = config.getParameter("messageType")
  self.messageArgs = entity.position()
  
  self.recipientId = world.loadUniqueEntity(self.recipientUId)
end

function onInputNodeChange(args)
  if self.recipientId == 0 then
    self.recipientId = world.loadUniqueEntity(self.recipientUId)
  end
  if object.isInputNodeConnected(0) and object.getInputNodeLevel(0) then
    world.sendEntityMessage(self.recipientId, self.messageType, self.messageArgs)
  end
end