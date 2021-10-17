function init()
  self.levels = config.getParameter("levels")
  self.damageSource = config.getParameter("damageSource")
  
  self.levelNum = 0
  
  message.setHandler("addLevel", function()
    self.levelNum = self.levelNum + 1
  end)
  message.setHandler("subLevel", function()
    self.levelNum = self.levelNum - 1
  end)
end

function update(dt)
  if self.levelNum > 0 then
    self.level = self.levels[self.levelNum]
    self.damageSource.damage = self.level.damage
    animator.setParticleEmitterEmissionRate("smoke", self.level.emissionRate)
    object.setDamageSources({self.damageSource})
    animator.setAnimationState("emitterState", "on")
    animator.setParticleEmitterActive("smoke", true)
  else
    object.setDamageSources()
    animator.setAnimationState("emitterState", "off")
    animator.setParticleEmitterActive("smoke", false)
  end
  world.debugText("%s", self.levelNum, object.position(), "green")
end