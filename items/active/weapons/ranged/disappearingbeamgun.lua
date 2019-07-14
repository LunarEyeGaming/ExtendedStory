require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"
require "/items/active/weapons/weapon.lua"

function init()
  inValidInstanceWorld = false
  instanceWorld = world.type()
  for _, v in pairs (config.getParameter("validInstanceWorlds")) do
    if instanceWorld == v then
	  inValidInstanceWorld = true
	  break
	end
  end
  if not inValidInstanceWorld then
    item.consume(1)
  end
  activeItem.setCursor("/cursors/beamcannonreticle.cursor")
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))

  self.weapon = Weapon:new()

  self.weapon:addTransformationGroup("weapon", {0,0}, 0)
  self.weapon:addTransformationGroup("muzzle", self.weapon.muzzleOffset, 0)

  self.weapon:addAbility(getPrimaryAbility())

  local secondaryAttack = getAltAbility()
  if secondaryAttack then
    self.weapon:addAbility(secondaryAttack)
  end
  
  self.weapon:init()
end

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)
end

function uninit()
  self.weapon:uninit()
end
