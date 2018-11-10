function init()

  self.soundInterval = config.getParameter("soundInterval")
  self.soundTimer = 0

  self.tickTime = 1.0
  self.tickTimer = self.tickTime
  self.timer = 0
  self.compoundDamage = config.getParameter("starvationCompoundDamage", 1)
  self.movementModifiers = config.getParameter("movementModifiers", {})
end

function update(dt)
end

function uninit()

end
