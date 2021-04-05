function init()
  monster.setDeathParticleBurst("deathPoof")
  animator.setAnimationState("movement", "idle")

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end

  message.setHandler("despawn", despawn)
end

function shouldDie()
  return not status.resourcePositive("health")
end

function update(dt)

end

function despawn()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end