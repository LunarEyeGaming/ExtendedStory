require "/scripts/vec2.lua"

function init()
  self.zigZagTime = config.getParameter("zigZagTime")
  self.zigZagAngle = config.getParameter("zigZagAngle")

  self.zigZagTimer = self.zigZagTime
  self.zig = true

  local curVel = mcontroller.velocity()
  mcontroller.setVelocity(vec2.rotate(curVel, self.zigZagAngle * 0.5))
end

function update(dt)
  self.zigZagTimer = math.max(0, self.zigZagTimer - dt)
  if self.zigZagTimer == 0 then
    local curVel = mcontroller.velocity()
    mcontroller.setVelocity(vec2.rotate(curVel, self.zigZagAngle * (self.zig and -1 or 1)))
    self.zig = not self.zig
    self.zigZagTimer = self.zigZagTime
  end
end
