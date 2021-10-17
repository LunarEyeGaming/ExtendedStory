function init()
  self.detectRegion = config.getParameter("detectRegion")
  self.msgTargets = config.getParameter("msgTargets")
  self.active = false
  
  local pos = object.position()
  self.detectRegion[1] = self.detectRegion[1] + pos[1]
  self.detectRegion[2] = self.detectRegion[2] + pos[2]
  self.detectRegion[3] = self.detectRegion[3] + pos[1]
  self.detectRegion[4] = self.detectRegion[4] + pos[2]
end

function update(dt)
  if not world.rectCollision(self.detectRegion) then
    animator.setAnimationState("emitterState", "on")
    animator.setParticleEmitterActive("smoke", true)
    if self.msgTargets and not self.active then
      messageSmokeScreens("addLevel")
    end
    self.active = true
  else
    animator.setAnimationState("emitterState", "off")
    animator.setParticleEmitterActive("smoke", false)
    if self.msgTargets and self.active then
      messageSmokeScreens("subLevel")
    end
    self.active = false
  end
end

function messageSmokeScreens(msg)
  for _, target in pairs(self.msgTargets) do
    world.sendEntityMessage(target, msg)
  end
end