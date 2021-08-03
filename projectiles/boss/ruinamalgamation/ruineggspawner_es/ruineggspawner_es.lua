function sourceEntityAlive()
  return world.entityExists(projectile.sourceEntity()) and world.entityHealth(projectile.sourceEntity())[1] > 0
end

function update()
  if not sourceEntityAlive() then
    projectile.die()
  end
end

function destroy()
  if not sourceEntityAlive() then
    return
  end

  local monsterType = config.getParameter("monsterType")
  local damageTeam = entity.damageTeam()
  local parameters = {
    level = config.getParameter("monsterLevel", world.threatLevel()),
    aggressive = true,
    damageTeam = damageTeam.team,
    damageTeamType = damageTeam.type
  }
  parameters = sb.jsonMerge(parameters, config.getParameter("monsterParameters", {}))
  local entityId = world.spawnMonster(monsterType, mcontroller.position(), parameters)

  world.sendEntityMessage(projectile.sourceEntity(), "notify", {
    type = "minionSpawned",
    targetId = entityId  
  })
end
