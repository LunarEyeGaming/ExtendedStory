require "/scripts/status.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"

function init()
  status.addEphemeralEffect("buddhamode_es", math.huge)
  script.setUpdateDelta(config.getParameter("initialScriptDelta", 5))
  monster.setDeathParticleBurst("deathPoof")

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end
  if config.getParameter("uniqueId") then
    monster.setUniqueId(config.getParameter("uniqueId"))
  end

  message.setHandler("despawn", despawn)

  -- Precondition: It is impossible for the mirror to receive this message in the middle of an adjustment.
  message.setHandler("adjust", function(_, _, aimPosition)
    if self.interactable then
      local aimVector = world.distance(aimPosition, mcontroller.position())
      animator.playSound("adjust")
      beginAdjust(aimVector)
    end
  end)
  
  message.setHandler("teleport", function(_, _, nextPosition)
    animator.setAnimationState("movement", "disappear")
    setStage(1, self.teleportDelay)
    self.nextPosition = nextPosition
  end)

  message.setHandler("setInteractability", function(_, _, interactable)
    self.interactable = interactable
  end)
  
  if config.getParameter("canFollow") then
    message.setHandler("follow", follow)
    --[[message.setHandler("unfollow", function()
      self.followTargetId = nil
    end)]]
  end
  
  self.damageListener = damageListener("damageTaken", fire)
  
  self.startingDirection = config.getParameter("startingDirection", {1, 0})

  self.teleportDelay = config.getParameter("teleportDelay", 0)
  self.reappearDelay = config.getParameter("reappearDelay", 0)

  self.adjustTime = config.getParameter("adjustTime", 0)
  self.adjustProgressOffset = config.getParameter("adjustProgressOffset", 0.5) -- A number from 0 up to 1

  self.fireOffset = config.getParameter("fireOffset", {0, 0})
  self.fireCooldown = config.getParameter("fireCooldown", 0.0)
  self.fireCooldown2 = config.getParameter("fireCooldown2", 0.0)
  
  self.projectileType = config.getParameter("projectileType")
  self.projectileConfig = config.getParameter("projectileConfig", {})
  if self.projectileConfig.power then
    self.projectileConfig.power = root.evalFunction("monsterLevelPowerMultiplier", monster.level()) * self.projectileConfig.power
  end
  
  self.nextPosition = nil
  
  self.stage = 0
  self.timer = 0.0
  
  self.fireTimer = 0.0
  
  self.followTargetId = nil
  
  self.interactable = true
  
  monster.setDamageBar("none")
  resetMirror()
end

function shouldDie()
  return status.resourcePercentage("health") == 0
end

function update(dt)
  if not self.interactable then
    status.addEphemeralEffect("invulnerable")
  else
    status.removeEphemeralEffect("invulnerable")
  end

  if self.stage == 0 then
    idle(dt)
  elseif self.stage == 1 then
    teleport(dt)
  elseif self.stage == 2 then -- Make it wait a bit before setting the animation state.
    reappear(dt)
  end
  
  if self.followTargetId and world.entityExists(self.followTargetId) then
    mcontroller.setPosition(world.entityPosition(self.followTargetId))
  end
end

function idle(dt)
  self.damageListener:update()
  self.fireTimer = math.max(0, self.fireTimer - dt)

  self.currentAngle = util.wrapAngle(self.currentAngle)
  self.isAdjusting = self.adjustTimer < self.adjustTime

  if self.isAdjusting then
    self.adjustTimer = math.min(self.adjustTime, self.adjustTimer + dt)

    local progress = (self.adjustTimer / self.adjustTime) * (1 - self.adjustProgressOffset) + self.adjustProgressOffset
    self.currentAngle = interp.sin(progress, self.startAngle, self.endAngle)
  end

  updateMirrorAngle()
end

function teleport(dt)
  if self.timer == 0 then
    mcontroller.setPosition(self.nextPosition)
    setStage(2, self.reappearDelay)
    resetMirror()
    return
  end
  self.timer = math.max(0, self.timer - dt)
end

function reappear(dt)
  if self.timer == 0 then
    animator.setAnimationState("movement", "appear")
    setStage(0, 0.0)
    return
  end
  self.timer = math.max(0, self.timer - dt)
end

function setStage(newStage, newTimer)
  self.stage = newStage
  self.timer = newTimer
end

function fire()
  if self.fireTimer == 0 then
    if not self.isAdjusting then
      local firePosition = vec2.add(mcontroller.position(), self.fireOffset)

      world.spawnProjectile(self.projectileType, firePosition, entity.id(), vec2.rotate({1, 0}, self.currentAngle), false, self.projectileConfig)
      animator.playSound("fire")
      self.fireTimer = self.fireCooldown
    else
      animator.playSound("error")
      self.fireTimer = self.fireCooldown2
    end
  end
end

function die()
  status.setResourcePercentage("health", 1.0)
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

function beginAdjust(direction)
  self.startAngle = self.currentAngle
  self.endAngle = interp.angleDiff(self.startAngle, vec2.angle(direction)) + self.startAngle
  self.adjustTimer = 0.0
end

function resetMirror()
  self.isAdjusting = false
  self.adjustTimer = self.adjustTime
  
  self.startAngle = 0
  self.endAngle = 0
  self.currentAngle = 0
  
  beginAdjust(self.startingDirection)
  self.adjustTimer = self.adjustTime - 0.0001
end

function follow(_, _, sourceId)
  self.followTargetId = sourceId
end

function despawn()
  hasDespawned = true
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end