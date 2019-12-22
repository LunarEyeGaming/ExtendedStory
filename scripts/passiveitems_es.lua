require "/scripts/extendedstoryutil.lua"

-- Uses passiveitems_es.config to give the player stats, status effects, etc. based on the items in their inventory.

local oldUpdate = update

function update(dt)
  oldUpdate(dt)
  passiveItems = root.assetJson("/passiveitems_es.config")
  for item, properties in pairs(passiveItems) do
    if world.entityHasCountOfItem(entity.id(), {name = item}, false) > 0 then
      -- Run a series of actions depending on the parameters of the passive item.
      if passiveItems[item].statusEffects then
        status.addEphemeralEffects(passiveItems[item].statusEffects)
      end
    end
  end
end