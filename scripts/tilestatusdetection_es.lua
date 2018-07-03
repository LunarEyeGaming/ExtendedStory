--Original code is from tutorial about tile status effects.

local oldUpdate = update

function update(dt)
  oldUpdate(dt)
  local gelPos = { mcontroller.xPosition(), math.floor(mcontroller.yPosition()-3)}
  local modCheck = world.material(gelPos,"foreground")
  if isn_getGelStatus(modCheck) == "burning" then
    status.addEphemeralEffect("burning")
  elseif isn_getGelStatus(modCheck) == "electrified" then
	status.addEphemeralEffect("electrified")
  elseif isn_getGelStatus(modCheck) == "shocked" then
	status.addEphemeralEffect("shocked_es") 
  end
end

function isn_getGelStatus(geltype)
    if geltype == "burningblock" then return "burning"
	elseif geltype == "chargedstone" then return "electrified"
	elseif geltype == "chargedbrick" then return "electrified"
	elseif geltype == "chargedsand" then return "electrified"
	elseif geltype == "livinglightning" then return "shocked"
    else return nil end
end