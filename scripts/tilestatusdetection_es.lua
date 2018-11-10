
local oldUpdate = update

function update(dt)
  oldUpdate(dt)
  currentPos = mcontroller.position()
  tileCheckPos = {currentPos[1], currentPos[2] - 3}
  tileType = world.material(tileCheckPos, "foreground")
  if not (tileType == false or tileType == nil) then
    statusType = returnStatusType(tileType)
  end
  if statusType then
    status.addEphemeralEffect(statusType)
  end
  statusType = nil
end

function returnStatusType(tileType)
    if tileType == "burningblock" then return "burning"
	elseif tileType == "chargedstone" then return "electrified"
	elseif tileType == "chargedbrick" then return "electrified"
	elseif tileType == "chargedsand" then return "electrified"
	elseif tileType == "livinglightning" then return "shocked"
    else return nil end
end