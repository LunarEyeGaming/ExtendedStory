require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.scale = config.getParameter("scale")
  self.scaleMode = config.getParameter("scaleMode")
  
  if self.scaleMode == "horizontal" then
    self.offset = {self.scale / 2, 0}
    self.scaleDirectiveParams = self.scale..";1"
  elseif self.scaleMode == "vertical" then
    self.offset = {0, self.scale / 2}
    self.scaleDirectiveParams = "1;"..self.scale
  elseif not self.scaleMode then
    error("Object parameter 'self.scaleMode' is nil.")
  else
    error("Object parameter 'self.scaleMode' is not valid.")
  end
  
  animator.setGlobalTag("directives", self.scaleDirectiveParams)
  
  script.setUpdateDelta(0)
end

function update(dt)
end