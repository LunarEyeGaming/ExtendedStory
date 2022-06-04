function destroy()
  world.spawnMonster("ancientturretfriendly_es", mcontroller.position(), {damageTeamType = "friendly", level = 10, masterId = projectile.sourceEntity()})
end