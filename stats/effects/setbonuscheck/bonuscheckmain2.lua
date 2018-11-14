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
  --(internally screaming)
  --I fixed the problem
  status.addEphemeralEffects({"ancientsetbonus"})
end
