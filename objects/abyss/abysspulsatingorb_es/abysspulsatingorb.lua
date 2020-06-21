require "/scripts/util.lua"

function init()
  animator.setAnimationState("orb", "idle")
  self.pulseInDelay = config.getParameter("pulseInDelay")
  self.pulseOutDelay = config.getParameter("pulseOutDelay")

  storage.stage = 1
  storage.timer = 0
end

function update(dt)
  if storage.stage == 0 then
    pulseIn(dt)
  elseif storage.stage == 1 then
    pulseOut(dt)
  end
end

function pulseIn(dt)
  if storage.timer == 0 then
    animator.setAnimationState("orb", "beat")
    animator.playSound("beatIn")
    setStage(1, self.pulseOutDelay)
    return
  end
  
  storage.timer = math.max(0, storage.timer - dt)
end

function pulseOut(dt)
  if storage.timer == 0 then
    animator.setAnimationState("orb", "beat")
    animator.playSound("beatOut")
    setStage(0, self.pulseInDelay)
    return
  end
  
  storage.timer = math.max(0, storage.timer - dt)
end

function setStage(newStage, newTimer)
  storage.stage = newStage
  storage.timer = newTimer
end