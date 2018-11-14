require "/scripts/extendedstorymisc.lua"

function init()
  --Defining parameters setBonuses, chestSlotCheck, pantsSlotCheck, setBonusStats, and bonusStatsAdded
  setBonuses = config.getParameter("setBonuses")
  chestSlotCheck = config.getParameter("chest")
  pantsSlotCheck = config.getParameter("pants")
  setBonusStats = config.getParameter("setBonusStats")
  bonusStatsAdded = false
end

function update(dt)
  chestSlotEquipped = detectStatusEffect(chestSlotCheck)
  pantsSlotEquipped = detectStatusEffect(pantsSlotCheck)
  -- If the chest and pants slots are equipped, then execute the code below
  if chestSlotEquipped and pantsSlotEquipped then
    status.addEphemeralEffects(setBonuses)
	-- When stats are not added yet, if they exist. These are stats, not status effects.
	if setBonusStats and not bonusStatsAdded then
      for _, bonusStat in pairs(setBonusStats) do
        effect.addStatModifierGroup({{stat = bonusStat["stat"], amount = bonusStat["amount"]}})
		bonusStatsAdded = true
      end
    end
  elseif setBonusStats then
    bonusStatsAdded = false
  else
    -- A function named 'status.removeEphemeralEffects' does not exist, so I have to do it this way.
    for _, bonusEffect in pairs(setBonuses) do
	  -- Some of the entries can be tables to specify the duration of the effect, so this entire script will break the moment it reaches a table otherwise. Example: {duration: 1, effect: "mystatuseffect"}
	  -- or {duration = 1, effect = "mystatuseffect"}
	  if type(bonusEffect) == "table" then
	    setBonusEffect = bonusEffect["effect"]
	  else
	    setBonusEffect = bonusEffect
	  end
      status.removeEphemeralEffect(setBonusEffect)
	end
  end
  
end
