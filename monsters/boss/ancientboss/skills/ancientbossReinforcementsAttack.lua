--------------------------------------------------------------------------------
ancientbossReinforcementsAttack = {}

function ancientbossReinforcementsAttack.enter()
  if not hasTarget() then return nil end

  local reinforcements = ancientbossReinforcementsAttack.findReinforcements()
  if #reinforcements >= config.getParameter("ancientbossReinforcementsAttack.maxReinforcements") then
    return nil
  end

  return {
    basePosition = self.spawnPosition,
    spawns = 0,
    startDirection = util.randomDirection(),
    spawnDistance = config.getParameter("ancientbossReinforcementsAttack.spawnDistance")
  }
end

function ancientbossReinforcementsAttack.onInit()
  self.minionTimer = 0

  message.setHandler("minionTimer", function() return self.minionTimer end)
  self.minionState = {
    slots = { 0, 0, 0, 0 }
  }
end

function ancientbossReinforcementsAttack.onUpdate(dt)
  if status.resourcePositive("health") then
    --Update minions
    for minionIndex, entityId in pairs(self.minionState.slots) do
      if entityId == 0 or not world.entityExists(entityId) then
        self.minionState.slots[minionIndex] = 0
      end
    end

    -- minionTimer provides a single timer for minions to perform synchronized actions
    self.minionTimer = self.minionTimer + dt
  else
    for _,entityId in pairs(self.minionState.slots) do
      if world.entityExists(entityId) then
        world.sendEntityMessage(entityId, "despawn")
      end
    end
  end
end

function ancientbossReinforcementsAttack.enteringState(stateData)
  monster.setActiveSkillName("ancientbossReinforcementsAttack")
end

function ancientbossReinforcementsAttack.update(dt, stateData)
  mcontroller.controlFace(1)
  if not hasTarget() then return true end

  local targetPosition = {self.targetPosition[1], stateData.basePosition[2]}
  if stateData.spawns == 0 then
    targetPosition[1] = targetPosition[1] + stateData.spawnDistance * stateData.startDirection
  else
    targetPosition[1] = targetPosition[1] + stateData.spawnDistance * -stateData.startDirection
  end

  local targetDistance = world.magnitude(targetPosition, mcontroller.position())
  local toTarget = world.distance(targetPosition, mcontroller.position())
  if targetDistance < 3 or checkWalls(util.toDirection(toTarget[1])) then
    if currentPhase() < 3 then
      --Spawn ground reinforcements
      ancientbossReinforcementsAttack.spawnRandomGroundPenguin()
    else
      --In phase 3 spawn mini UFOs
      for i,minionId in ipairs(self.minionState.slots) do
        if minionId == 0 then
          self.minionState.slots[i] = world.spawnMonster("ancientfragment", mcontroller.position(), {
            level = monster.level(),
            masterId = entity.id(),
            minionIndex = i
          })
          break
        end
      end
    end
    stateData.spawns = stateData.spawns + 1
    mcontroller.controlFly({ 0, 0 })
  else
    flyTo(targetPosition)
  end

  if stateData.spawns > 1 then
    return true
  else
    return false
  end
end

function ancientbossReinforcementsAttack.findReinforcements()
  local selfId = entity.id()
  local position = mcontroller.position()
  local min = { position[1] - 50.0, position[2] - 50.0 }
  local max = { position[1] + 50.0, position[2] + 50.0 }

  return world.entityQuery(min, max, { callScript = "isPenguinReinforcement", includedTypes = {"monster"} })
end

function ancientbossReinforcementsAttack.spawnRandomGroundPenguin()
  local percent = math.random(100)
  if percent > 66 then
    rangedAttack.fireOnce(config.getParameter("ancientbossReinforcementsAttack.projectiles.generalspawn.type"), config.getParameter("ancientbossReinforcementsAttack.projectiles.generalspawn.config"), nil, true)
  elseif percent > 33 then
    rangedAttack.fireOnce(config.getParameter("ancientbossReinforcementsAttack.projectiles.rockettrooperspawn.type"), config.getParameter("ancientbossReinforcementsAttack.projectiles.rockettrooperspawn.config"), nil, true)
  else
    rangedAttack.fireOnce(config.getParameter("ancientbossReinforcementsAttack.projectiles.trooperspawn.type"), config.getParameter("ancientbossReinforcementsAttack.projectiles.trooperspawn.config"), nil, true)
  end
end