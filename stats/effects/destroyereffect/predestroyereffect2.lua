function init()
  animator.setParticleEmitterActive("sparks", true)

  effect.setParentDirectives(config.getParameter("directives", ""))

  self.movementModifiers = config.getParameter("movementModifiers", {})

  self.energyCost = config.getParameter("energyCost", 1)
  self.healthDamage = config.getParameter("healthDamage", 1)
  
  script.setUpdateDelta(config.getParameter("tickRate", 1))
end

function update(dt)
  mcontroller.controlModifiers(self.movementModifiers)
end

function onExpire()
  position = mcontroller.position()
  spawnPosition = {position[1], position[2] + 20}
  status.addEphemeralEffect("destroyereffect")
  world.spawnProjectile("destroyerborderform", mcontroller.position())
  world.spawnMonster("destroyer", spawnPosition, {musicStagehands = {"bossmusicdestroyer"}, level = 10})
  world.spawnStagehand(
      mcontroller.position(),
      "bossmusicdestroyer",
	  {
	    uniqueId = "bossmusicdestroyer"
	})
end