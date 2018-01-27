function init()
  animator.setParticleEmitterOffsetRegion("snow", mcontroller.boundBox())
  animator.setParticleEmitterActive("snow", true)

  effect.setParentDirectives(config.getParameter("directives", ""))

  self.movementModifiers = config.getParameter("movementModifiers", {})

  self.energyCost = config.getParameter("energyCost", 1)
  self.healthDamage = config.getParameter("healthDamage", 1)
  
  script.setUpdateDelta(config.getParameter("tickRate", 1))

  effect.addStatModifierGroup({{stat = "energyRegenPercentageRate", effectiveMultiplier = 0}})

end

function update(dt)
  mcontroller.controlModifiers(self.movementModifiers)
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.healthDamage,
        damageSourceKind = "megadamageice",
        sourceEntityId = entity.id()
      })
end

function onExpire()
  status.addEphemeralEffect("frostsnare")
end