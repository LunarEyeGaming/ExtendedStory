function bossReset()
  animator.setAnimationState("eye", "idle")
  animator.setAnimationState("firstBeams", "idle")
  animator.setAnimationState("firstBeams", "idle")
  animator.setAnimationState("shell", "stage1")
  animator.setAnimationState("organs", "six")

  local moontants = world.entityQuery(mcontroller.position(), 60, { includedTypes = {"monster"} })
  for _,moontant in pairs(moontants) do
    if world.monsterType(moontant) == "moontant" then
      world.callScriptedEntity(moontant, "monster.setDropPool", nil)
      world.callScriptedEntity(moontant, "status.setResource", "health", 0)
    end
  end
end
