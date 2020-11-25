function init()
  self.recipientUId = config.getParameter("recipientUId")
  self.messageType = config.getParameter("messageType")
  self.messageArgs = config.getParameter("messageArgs")
end

function onInputNodeChange(args)
  if object.isInputNodeConnected(0) and object.getInputNodeLevel(0) then
    world.sendEntityMessage(self.recipientUId, self.messageType, table.unpack(self.messageArgs))
  end
end