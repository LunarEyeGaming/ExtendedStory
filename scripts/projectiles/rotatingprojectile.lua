function init()
  self.rotVelocity = config.getParameter("rotateRate") * 2 * math.pi
  self.rotationAmount = 0
end

function update(dt)
  self.rotationAmount = self.rotationAmount + self.rotVelocity * dt

  mcontroller.setRotation(self.rotationAmount)
end
