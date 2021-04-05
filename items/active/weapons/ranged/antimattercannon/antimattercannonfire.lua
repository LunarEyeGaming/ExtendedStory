require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"

ChargeFire = WeaponAbility:new()

function ChargeFire:init()
  item.consume(1)
end