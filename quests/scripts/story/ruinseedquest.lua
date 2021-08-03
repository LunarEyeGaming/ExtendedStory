require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/quests/scripts/portraits.lua"
require "/quests/scripts/questutil.lua"

function init()
  self.descriptions = config.getParameter("descriptions")
  self.compassUpdate = config.getParameter("compassUpdate", 0.5)
  self.messageTime = config.getParameter("messageTime")

  self.estherUid = config.getParameter("estherUid")
  storage.complete = storage.complete or false

  self.gateUid = config.getParameter("gateUid")

  self.state = FSM:new()

  storage.stage = storage.stage or 1
  self.stages = {
    destroyRuin,
    turnIn
  }

  message.setHandler("ruinseedDestroyed", function(_, sourceId)
    storage.stage = 2
  end)

  self.state:set(self.stages[storage.stage])

  setPortraits()
end

function update(dt)
  self.state:update(dt)

  if storage.complete then
    quest.setCanTurnIn(true)
  end
end

function questStart()
  storage.stage = 1
  self.state:set(self.stages[storage.stage])
  local associatedMission = config.getParameter("associatedMission")
  if associatedMission then
    player.enableMission(associatedMission)
    player.playCinematic(config.getParameter("missionUnlockedCinema"))
    self.radioMessageTimer = 3.0
  end
end

function questInteract(entityId)
  if self.onInteract then
    return self.onInteract(entityId)
  end
end

function questComplete()
  setPortraits()
  questutil.questCompleteActions()
end

function destroyRuin()
  quest.setObjectiveList({{self.descriptions.destroyRuin, false}})

  while storage.stage == 1 do
    coroutine.yield()
  end

  self.state:set(self.stages[storage.stage])
end

function turnIn()
  quest.setCanTurnIn(true)

  quest.setObjectiveList({{self.descriptions.turnIn, false}})

  local trackEsther = util.uniqueEntityTracker(self.estherUid, self.compassUpdate)
  while true do
    questutil.pointCompassAt(trackEsther())

    coroutine.yield()
  end
end
