function init()
  self.recipientUId = config.getParameter("recipientUId")
  self.messageType = config.getParameter("messageType")
  self.messageArgs = entity.position()
end

function onInputNodeChange(args)
  if object.isInputNodeConnected(0) and object.getInputNodeLevel(0) then
    world.sendEntityMessage(self.recipientUId, self.messageType, self.messageArgs)
  end
end