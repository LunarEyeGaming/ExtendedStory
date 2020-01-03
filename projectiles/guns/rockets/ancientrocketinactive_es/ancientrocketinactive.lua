function trigger(cursorPosition)
  aimVector = world.distance(cursorPosition, mcontroller.position())
  world.spawnProjectile("ancientrocket_es", mcontroller.position(), projectile.sourceEntity(), aimVector, false, {power = projectile.power(), powerMultiplier = projectile.powerMultiplier()})
  projectile.die()
end