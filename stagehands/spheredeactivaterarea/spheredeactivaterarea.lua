require "/scripts/stagehandutil.lua"

function init()
  self.players = {}
  self.music = config.getParameter("music", {})
  self.musicEnabled = false
end

function update(dt)
  for playerId, _ in pairs(self.players) do
    if not world.entityExists(playerId) then
      -- Player died or left the mission
      self.players[playerId] = nil
    end
  end

  local newPlayers = broadcastAreaQuery({ includedTypes = {"player"} })
  for _, playerId in pairs(newPlayers) do
    world.spawnProjectile("spheredeactivater", world.entityPosition(playerId), entity.id(), {1, 0}, false, {damageTeam = {type = "indiscriminate"}})
  end
end
