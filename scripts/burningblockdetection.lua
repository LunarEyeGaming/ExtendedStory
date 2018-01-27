local oldUpdate = update

function update(dt)
    oldUpdate(dt)
    local gelPos = { mcontroller.xPosition(), math.floor(mcontroller.yPosition()-3)}
    local modCheck = world.material(gelPos,"foreground")
    if isn_getGelStatus(modCheck) == true then
        status.addEphemeralEffect("burning")
    end
end

function isn_getGelStatus(geltype)
    if geltype == "burningblock" then return true
    elseif geltype == "burningbrick" then return true
    else return nil end
end