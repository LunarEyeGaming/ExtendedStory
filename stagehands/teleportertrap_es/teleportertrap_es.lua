require "/scripts/stagehandutil.lua"

function init()
  self.containsPlayers = {}
  self.teleportCinematic = config.getParameter("teleportCinematic")
  self.resetObjectUid = config.getParameter("resetObjectUid")
end

function update(dt)
  local newPlayers = broadcastAreaQuery({ includedTypes = {"player"} })
  local oldPlayers = table.concat(self.containsPlayers, ",")
  for _, id in pairs(newPlayers) do
    if not string.find(oldPlayers, id) then
      world.sendEntityMessage(id, "playCinematic", self.teleportCinematic)
      warpPlayer(id, self.resetObjectUid)
    end
  end
  self.containsPlayers = newPlayers
end

-- TODO: Handle generic worlds, ship worlds, and celestial worlds.
function warpPlayer(id, toUid)
  if not toUid then
    world.sendEntityMessage(id, "warp", "InstanceWorld:"..world.type())
  else
    world.sendEntityMessage(id, "warp", "InstanceWorld:"..world.type().."="..toUid)
  end
end