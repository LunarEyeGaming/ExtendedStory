function init()
  script.setUpdateDelta(config.getParameter("initialScriptDelta", 5))
  monster.setDeathParticleBurst("deathPoof")

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end
  if config.getParameter("uniqueId") then
    monster.setUniqueId(config.getParameter("uniqueId"))
  end

  -- Precondition: It is impossible for the mirror to receive this message in the middle of an adjustment.
  message.setHandler("adjust", function(_, _, aimPosition)
    local aimVector = world.distance(aimPosition, mcontroller.position())
    animator.playSound("adjust")
    self.startAngle = self.currentAngle
    self.endAngle = interp.angleDiff(self.startAngle, vec2.angle(aimVector)) + self.startAngle
    self.adjustTimer = 0
  end)
  
  message.setHandler("fire", fire)
  
  self.adjustTime = config.getParameter("adjustTime", 0)
  self.firePosition = vec2.add(mcontroller.position(), config.getParameter("fireOffset", {0, 0}))
  self.adjustProgressOffset = config.getParameter("adjustProgressOffset", 0.5) -- A number from 0 up to 1
  
  self.isAdjusting = false
  self.adjustTimer = self.adjustTime
  
  self.startAngle = 0
  self.endAngle = 0
  self.currentAngle = 0
end

function shouldDie()
  return status.resourcePercentage("health") == 0
end

function update(dt)
  self.currentAngle = util.wrapAngle(self.currentAngle)
  self.isAdjusting = self.adjustTimer < self.adjustTime
  if self.isAdjusting then
    self.adjustTimer = math.min(self.adjustTime, self.adjustTimer + dt)

    local progress = (self.adjustTimer / self.adjustTime) * (1 - self.adjustProgressOffset) + self.adjustProgressOffset
    self.currentAngle = interp.sin(progress, self.startAngle, self.endAngle)
  end
  updateMirrorAngle()
end

function updateMirrorAngle()
  local angle, direction = getAbsoluteAngleAndDirection(self.currentAngle)
  mcontroller.controlFace(direction)
  animator.resetTransformationGroup("body")
  animator.rotateTransformationGroup("body", angle)
end

-- Provides the angle and direction necessary to keep the entity from rendering upside-down
function getAbsoluteAngleAndDirection(angle)
  local isFacingLeft = math.pi / 2 < angle and angle < 3 * math.pi / 2
  local absoluteAngle = isFacingLeft and -1 * (angle + math.pi) or angle
  local direction = isFacingLeft and -1 or 1
  return absoluteAngle, direction
end

function fire()
  if not self.isAdjusting then
    animator.playSound("fire")
    world.spawnProjectile("abyssshotboss", self.firePosition, entity.id(), vec2.rotate({1, 0}, self.currentAngle))
  else
    animator.playSound("error")
  end
end

function die()
  status.setResourcePercentage("health", 1.0)
end