function init()
  if storage.timer == nil then
    storage.timer = 0
  end
  self.recipientUId = config.getParameter("recipientUId")
  self.messageType = config.getParameter("messageType")
  self.messageArgs = config.getParameter("messageArgs")
  
  self.recipientId = world.loadUniqueEntity(self.recipientUId)
end

function onInputNodeChange(args)
  if object.isInputNodeConnected(0) and object.getInputNodeLevel(0) then
    world.sendEntityMessage(self.recipientId, self.messageType, self.messageArgs)
  end
end