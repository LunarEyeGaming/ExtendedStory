require "/scripts/stagehandutil.lua"

function init()
  self.players = {}
  self.effect = config.getParameter("effect")
end

function update(dt)
  local players = broadcastAreaQuery({ includedTypes = {"player"} })
  for _, playerId in pairs(players) do
    world.sendEntityMessage(playerId, "applyStatusEffect", self.effect)
  end
end