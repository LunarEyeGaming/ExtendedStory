require "/scripts/stagehandutil.lua"

function init()
  self.containsPlayers = {}
  self.stalkerUid = config.getParameter("stalkerUid")
  self.stalkerOffset = config.getParameter("stalkerOffset")
  self.message = config.getParameter("message")
end

function update(dt)
  local newPlayers = broadcastAreaQuery({ includedTypes = {"player"} })
  local oldPlayers = table.concat(self.containsPlayers, ",")
  for _, id in pairs(newPlayers) do
    if not string.find(oldPlayers, id) then
      local currentPos = entity.position()
      world.sendEntityMessage(self.stalkerUid, self.message, {currentPos[1] + self.stalkerOffset[1], currentPos[2] + self.stalkerOffset[2]})
    end
  end
  self.containsPlayers = newPlayers
end