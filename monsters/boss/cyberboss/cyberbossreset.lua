function bossReset()
  animator.setAnimationState("cyberboss", "idle")
  animator.setAnimationState("firstBeams", "idle")
  animator.setAnimationState("firstBeams", "idle")
  animator.setAnimationState("cyberbossdamage", "stage1")

  local cyberminis = world.entityQuery(mcontroller.position(), 60, { includedTypes = {"monster"} })
  for _,cybermini in pairs(cyberminis) do
    if world.monsterType(cybermini) == "cybermini" then
      world.callScriptedEntity(cybermini, "monster.setDropPool", nil)
      world.callScriptedEntity(cybermini, "status.setResource", "health", 0)
    end
  end
end
