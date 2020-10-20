require "/scripts/extendedstoryutil.lua"

-- Makes the parent entity have a specific amount of resistance to every element that is not in a given blacklist.
function init()
  blacklist = config.getParameter("elementBlacklist")
  resistanceAmount = config.getParameter("resistanceAmount", 1.0)

  local elementsAndResistances = getAllElementalResistances(blacklist)

  statModifierGroup = {}

  for _, resistance in pairs(elementsAndResistances) do
    local statModifier = {stat = resistance, amount = resistanceAmount}
    table.insert(statModifierGroup, statModifier)
  end

  effect.addStatModifierGroup(statModifierGroup)

  script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
  
end
