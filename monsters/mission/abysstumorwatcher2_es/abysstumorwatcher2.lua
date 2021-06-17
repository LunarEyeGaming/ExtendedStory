require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  monster.setDeathParticleBurst("deathPoof")
  self.targetRadius = config.getParameter("targetRadius")
  self.targetTypes = config.getParameter("targetTypes")
  self.disappearRadius = config.getParameter("disappearRadius")
  self.disappearTime = config.getParameter("disappearTime", 0)
  self.reappearDelay = config.getParameter("reappearDelay", 0)

  self.flyOffset = config.getParameter("flyOffset", {0, 0})
  self.flyAngle = util.toRadians(config.getParameter("flyAngle", 0))
  self.flySpeed = config.getParameter("flySpeed", mcontroller.baseParameters().flySpeed)
  self.flyTime = config.getParameter("flyTime")

  self.invisible = config.getParameter("invisible", false)
  
  if config.getParameter("uniqueId") then
    monster.setUniqueId(config.getParameter("uniqueId"))
  end

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end
  
  if self.invisible then
    animator.setAnimationState("body", "invisible")
  end
  
  self.teleportPosition = vec2.add(mcontroller.position(), self.flyOffset)
  self.target = nil
  self.stage = 0
  self.timer = nil
  
  --self.state = FSM:new()
  --self.state:set(idle)

  message.setHandler("despawn", despawn)
  
  monster.setDamageBar(config.getParameter("damageBar", "None"))
end

function shouldDie()
  return not status.resourcePositive("health")
end

function update(dt)
  if self.stage == 0 then
    idle()
  elseif self.stage == 1 then
    teleport(dt)
  elseif self.stage == 2 then
    scare(dt)
  elseif self.stage == 3 then
    if self.timer == 0 then
      status.setResourcePercentage("health", 0.0)
    end
    mcontroller.setVelocity(vec2.rotate({self.flySpeed, 0}, self.flyAngle))
    self.timer = math.max(0, self.timer - dt)
  end
end

function despawn()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end

function idle()
  if self.target and world.entityExists(self.target) then
    local targetPosition = world.entityPosition(self.target)
    local seesTarget = world.lineCollision(targetPosition, mcontroller.position()) == nil
    local isCloseEnough = world.magnitude(targetPosition, mcontroller.position()) < self.disappearRadius

    if seesTarget and isCloseEnough then
      if not self.invisible then
        animator.setAnimationState("body", "disappear")
      end
      setStage(1, config.getParameter("disappearTime"))
    end

    updateEye(targetPosition)
  else
    local entities = queryEntities(self.targetRadius, self.targetTypes)
    if #entities > 0 then
      self.target = entities[1]
    end
  end
end

function teleport(dt)
  if self.timer == 0 then
    mcontroller.setPosition(self.teleportPosition)
    setStage(2, self.reappearDelay)  -- Make it wait a bit before setting the animation state.
    return
  end
  self.timer = math.max(0, self.timer - dt)
end

function scare(dt)
  if self.timer == 0 then
    animator.setAnimationState("body", "spook")
    animator.resetTransformationGroup("body")
    animator.rotateTransformationGroup("body", self.flyAngle)
    setStage(3, self.flyTime)
    return
  end
  self.timer = math.max(0, self.timer - dt)
end

function setStage(newStage, newTimer)
  self.stage = newStage
  self.timer = newTimer
end

function queryEntities(radius, types)
  local queried = world.entityQuery(mcontroller.position(), radius, {withoutEntityId = entity.id(), includedTypes = types, order = "nearest"})

  local results = {}
  for _, ent in pairs(queried) do
    if entity.isValidTarget(ent) then
      table.insert(results, ent)
    end
  end
  
  return results
end

function updateEye(lookPosition)
  animator.resetTransformationGroup("body")
  local rotationAngle = vec2.angle(world.distance(lookPosition, mcontroller.position()))
  animator.rotateTransformationGroup("body", rotationAngle)
end