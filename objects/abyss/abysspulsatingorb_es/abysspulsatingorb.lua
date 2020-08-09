require "/scripts/util.lua"

function init()
  animator.setAnimationState("orb", "idle")
  self.pulseInDelay = config.getParameter("pulseInDelay")
  self.pulseOutDelay = config.getParameter("pulseOutDelay")

  self.stage = 1
  self.timer = 0
end

function update(dt)
  if self.stage == 0 then
    pulseIn(dt)
  elseif self.stage == 1 then
    pulseOut(dt)
  end
end

function pulseIn(dt)
  if self.timer == 0 then
    animator.setAnimationState("orb", "beat")
    animator.playSound("beatIn")
    setStage(1, self.pulseOutDelay)
    return
  end
  
  self.timer = math.max(0, self.timer - dt)
end

function pulseOut(dt)
  if self.timer == 0 then
    animator.setAnimationState("orb", "beat")
    animator.playSound("beatOut")
    setStage(0, self.pulseInDelay)
    return
  end
  
  self.timer = math.max(0, self.timer - dt)
end

function setStage(newStage, newTimer)
  self.stage = newStage
  self.timer = newTimer
end