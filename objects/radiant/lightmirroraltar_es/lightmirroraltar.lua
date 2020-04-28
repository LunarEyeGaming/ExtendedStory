require "/scripts/util.lua"

function init()
  object.setInteractive(storage.interactive or config.getParameter("interactive", true))
  animator.setAnimationState("mirror", "idle")
  self.glowDelay = config.getParameter("glowDelay")
  self.disappearDelay = config.getParameter("disappearDelay")
  self.cinematic = config.getParameter("disappearCinematic")
  
  self.bobPeriod = config.getParameter("bobPeriod")
  self.bobAmplitude = config.getParameter("bobAmplitude")
  
  self.startShakingMagnitude = config.getParameter("startShakingMagnitude")
  self.endShakingMagnitude = config.getParameter("endShakingMagnitude")

  storage.stage = 0
  storage.timer = 0
  self.bobTimer = 0
  self.currentOffset = {0, 0}
end

function update(dt)
  if storage.stage == 0 then
    idleAnimation(dt)
  elseif storage.stage == 1 then
    stageOne(dt)
  elseif storage.stage == 2 then
    stageTwo(dt)
  end
  updateTransformationGroup("mirror", self.currentOffset)
end

function idleAnimation(dt)
  self.bobTimer = self.bobTimer + dt
  local bobProgress = self.bobTimer / self.bobPeriod
  self.currentOffset = {0, self.bobAmplitude * math.sin(math.pi * bobProgress)}
end

function stageOne(dt)
  if storage.timer == 0 then
    animator.setAnimationState("mirror", "glow")
    animator.playSound("preDisappear")
    endStage(self.disappearDelay)
    return
  end
  storage.timer = math.max(0, storage.timer - dt)
  local progress = storage.timer / self.glowDelay
  self.currentOffset = {util.lerp(progress, 0, storage.startOffset[1]), util.lerp(progress, 0, storage.startOffset[2])}
end

function stageTwo(dt)
  storage.timer = math.max(0, storage.timer - dt)

  local progress = storage.timer / self.disappearDelay
  local magnitude = math.random() * util.lerp(progress, self.endShakingMagnitude, self.startShakingMagnitude)
  local angle = math.random() * 2 * math.pi
  self.currentOffset[1] = magnitude * math.cos(angle)
  self.currentOffset[2] = magnitude * math.sin(angle)

  if storage.timer == 0 then
    animator.setAnimationState("mirror", "disappear")
    for _,playerId in pairs(world.players()) do
      world.sendEntityMessage(playerId, "playCinematic", self.cinematic)
    end
    endStage(0)
    return
  end
end

function endStage(newTimer)
  storage.stage = storage.stage + 1
  storage.timer = newTimer
end

function onInteraction(args)
  if storage.stage == 0 then
    storage.startOffset = self.currentOffset
    endStage(self.glowDelay)
  end
end

function updateTransformationGroup(group, newOffset)
  animator.resetTransformationGroup(group)
  animator.translateTransformationGroup(group, newOffset)
end