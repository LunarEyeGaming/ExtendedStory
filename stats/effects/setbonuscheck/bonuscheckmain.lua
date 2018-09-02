require "/scripts/extendedstorymisc.lua"

function init()
  script.setUpdateDelta(1)
  setBonus = config.getParameter("setBonus")
  chestSlotCheck = config.getParameter("chest")
  pantsSlotCheck = config.getParameter("pants")
  setBonusStats = config.getParameter("setBonusStats")
  bonusStatsAdded = false
end

function update(dt)
  chestSlotEquipped = detectStatusEffect(chestSlotCheck)
  pantsSlotEquipped = detectStatusEffect(pantsSlotCheck)
  if chestSlotEquipped == true and pantsSlotEquipped == true then
    status.addEphemeralEffect(setBonus)
	if setBonusStats and bonusStatsAdded == false then
      for _, bonusStat in pairs(setBonusStats) do
        effect.addStatModifierGroup({{stat = bonusStat["stat"], amount = bonusStat["amount"]}})
		bonusStatsAdded = true
      end
    end
  elseif setBonusStats then
    bonusStatsAdded = false
  end
  
end
