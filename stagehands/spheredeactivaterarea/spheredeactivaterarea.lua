require "/scripts/stagehandutil.lua"
require "/scripts/extendedstoryutil.lua"
require "/stagehands/statuseffectregion_es/statuseffectregion_es.lua"

superInit = init
superUpdate = update

function init()
  superInit()
  self.borderProjectile = config.getParameter("borderProjectile")
end

function update(dt)
  superUpdate(dt)
  spawnProjectileAlongBorder(translateBroadcastArea(), {self.borderProjectile})
end