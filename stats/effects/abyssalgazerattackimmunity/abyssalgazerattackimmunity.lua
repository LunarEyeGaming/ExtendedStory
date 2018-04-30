function init()
   effect.addStatModifierGroup({{stat = "iceResistance", amount = 1}, {stat = "fireResistance", amount = 1}, {stat = "poisonResistance", amount = 1}, {stat = "electricResistance", amount = 1}, {stat = "ionResistance", amount = 1}, {stat = "abyssResistance", amount = 1}, {stat = "megadamageResistance", amount = 1}, {stat = "physicalResistance", amount = 1}})

   script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
  
end
