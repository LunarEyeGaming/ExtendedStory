-- Credit goes to bk3000 for the code
local oldUpdate = update
local returnStatusType = {
  burningblock = "burning",
  chargedstone = "electrified",
  chargedbrick = "electrified",
  chargedsand = "electrified",
  livinglightning = "shocked"
}  --undefined tiles return nil
 
 
function update(dt)
  oldUpdate(dt)
  local currentPos = mcontroller.position()
  local tileType = world.material({currentPos[1], currentPos[2] - 3}, "foreground")
 
  if tileType then
    local statusType = returnStatusType[tileType]  
   
    if statusType then
      status.addEphemeralEffect(statusType)
    end
  end
end