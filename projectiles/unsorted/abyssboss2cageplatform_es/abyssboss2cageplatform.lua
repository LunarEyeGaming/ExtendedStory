require "/scripts/vec2.lua"

function init() 
  self.stop1Delay = config.getParameter("stop1Delay")
  self.stop2Delay = config.getParameter("stop2Delay")
  self.redirectionDelay = config.getParameter("redirectionDelay")
  self.enterArenaDelay = config.getParameter("enterArenaDelay")
  self.captureDelay = config.getParameter("captureDelay")

  self.speed = projectile.getParameter("speed")
  self.stop1Distance = config.getParameter("stop1Distance")
  self.projectileMass = config.getParameter("projectileMass")
  self.captureOffset = config.getParameter("captureOffset")
  self.redirectionVelocity = config.getParameter("redirectionVelocity")
  self.redirection2Velocity = config.getParameter("redirection2Velocity")
  self.breachOffset = config.getParameter("breachOffset")
  
  if self.stop1Distance > 0 then
    self.stop1Force = (self.projectileMass * self.speed ^ 2) / (2 * self.stop1Distance)
  end

  self.stages = {
    {
      func = nil,
      endFunc = nil,
      duration = self.stop1Delay
    },
    {
      func = (function()
        if self.stop1Distance > 0 then
          mcontroller.approachVelocity({0, 0}, self.stop1Force)
        else
          mcontroller.setVelocity({0, 0})
        end
      end),
      endFunc = spawnCapture,
      duration = self.captureDelay
    },
    {
      func = nil,
      endFunc = redirect,
      duration = self.redirectionDelay
    },
    {
      func = nil,
      endFunc = breachAndRedirect,
      duration = self.enterArenaDelay
    },
    {
      func = nil,
      endFunc = stop,
      duration = self.stop2Delay
    }
  }
  setStage(1)
end

function update(dt)
  --world.debugText("stop1Force = %s", self.stop1Force, mcontroller.position(), "green")
  if self.stages[self.stage] then
    updateStages(dt)
  end
  mcontroller.setRotation(0)
end

function updateStages(dt)
  self.timer = math.max(0, self.timer - dt)
  if self.timer == 0 then
    local endFunc = self.stages[self.stage].endFunc
    if endFunc then
      endFunc()
    end
    setStage(self.stages[self.stage].nextStage or self.stage + 1)
    return
  end
  local func = self.stages[self.stage].func
  if func then
    func()
  end
end

function spawnCapture()
  local projectilePos = vec2.add(mcontroller.position(), self.captureOffset)
  local timeToLive = self.stop2Delay + self.enterArenaDelay + self.redirectionDelay
  world.spawnProjectile("abyssboss2cage_es", projectilePos, projectile.sourceEntity(), {1, 0}, false, {masterId = entity.id(), followOffset = self.captureOffset, timeToLive = timeToLive})
end

function redirect()
  mcontroller.setVelocity(self.redirectionVelocity)
end

function breachAndRedirect()
  local projectilePos = vec2.add(mcontroller.position(), self.breachOffset)
  world.spawnProjectile("abyssboss2ceilingbreacher_es", projectilePos)
  mcontroller.setVelocity(self.redirection2Velocity)
end

function stop()
  mcontroller.setVelocity({0, 0})
end

function setStage(nextStage)
  self.stage = nextStage
  if self.stages[nextStage] then
    self.timer = self.stages[nextStage].duration
  else
    self.timer = 0
  end
end