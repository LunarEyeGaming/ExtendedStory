--Returns whether or not a specified status effect is active for an entity
--Table for status.activeUniqueStatusEffectSummary() is listed as {1: {1: statuseffectname, 2: <remaining duration to max duration ratio>}, 2: {1: statuseffectname, 2: <remaining duration to max duration ratio>}, 3:{1: statuseffectname, 2: <remaining duration to max duration ratio>}}
--Also, it is completely necessary to make statusEffectExists true or false. A lua error will be thrown if the return function is called in the for loop

function detectStatusEffect(statusEffect)
  statusEffects = status.activeUniqueStatusEffectSummary()
  if statusEffect == nil then
    sb.logWarn("Value 'statusEffect' is not defined")
  else
    for _, effect in pairs(statusEffects) do
      if effect[1] == statusEffect then
	    statusEffectExists = true
		break
	  else
        statusEffectExists = false
	  end
    end
	if statusEffectExists == true then
	  return true
	else
	  return false
    end
  end
end