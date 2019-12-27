function init()
  effectDuration = 60
  effect.addStatModifierGroup({
    {stat = "maxHealth", amount = effect.duration()} -- The duration is used as this parameter instead
  })
  effect.modifyDuration(effectDuration) -- The duration is 60

  script.setUpdateDelta(60)
end

function update(dt)
  effect.modifyDuration(effectDuration)
end

function uninit()
end
