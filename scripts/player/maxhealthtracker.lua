require "/scripts/extendedstoryutil.lua"

-- A script that keeps track of the amount of max health changed by status effects.

function init()
  totalMaxHealthChange = 0
  activeStatusEffects = {}
  message.setHandler("addMaxHealthChange", function(_, _, nextMaxHealthChange)
    totalMaxHealthChange = totalMaxHealthChange + nextMaxHealthChange
    --[[status.removeEphemeralEffect(statusEffectName)
    status.addEphemeralEffect(statusEffectName, totalMaxHealthChange) -- 2nd argument is duration, but the script takes it as a different kind of input.
    table.insert(activeStatusEffects, statusEffectName)]]
    status.removeEphemeralEffect("permanenthealthdeduction_es")
    status.addEphemeralEffect("permanenthealthdeduction_es", totalMaxHealthChange)
  end)

  script.setUpdateDelta(60)
end

function update(dt)
  --[[sb.logInfo("[Extended Story Debug] activeStatusEffects: %s", activeStatusEffects)
  for _, statusEffect in pairs(activeStatusEffects) do
    if detectStatusEffect(statusEffect) then
      status.removeEphemeralEffect(statusEffect)
      status.addEphemeralEffect(statusEffect, totalMaxHealthChange)
    end
  end]]
  status.removeEphemeralEffect("permanenthealthdeduction_es")
  status.addEphemeralEffect("permanenthealthdeduction_es", totalMaxHealthChange)
end