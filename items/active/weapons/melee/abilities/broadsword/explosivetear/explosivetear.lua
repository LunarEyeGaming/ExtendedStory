require "/items/active/weapons/melee/abilities/broadsword/travelingslash/travelingslash.lua"

ExplosiveTear = TravelingSlash:new()

function ExplosiveTear:slashSound()
  return "explosiveTear"
end
