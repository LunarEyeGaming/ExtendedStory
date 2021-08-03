require "/scripts/util.lua"

function init()
  self.endAngle = util.toRadians(config.getParameter("endAngle"))
  self.timer = 0
  self.interpTime = config.getParameter("interpTime") or config.getParameter("timeToLive")
end

function update(dt)
  self.timer = self.timer + dt

  mcontroller.setRotation(util.easeInOutSin(self.timer / self.interpTime, 0, self.endAngle))
end
