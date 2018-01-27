function init()
  animator.setAnimationRate(0)
  effect.addStatModifierGroup({
    {stat = "invulnerable", amount = 1},
    {stat = "fireStatusImmunity", amount = 1},
    {stat = "iceStatusImmunity", amount = 1},
    {stat = "electricStatusImmunity", amount = 1},
    {stat = "poisonStatusImmunity", amount = 1},
    {stat = "powerMultiplier", effectiveMultiplier = 0}
  })

  if status.isResource("stunned") then
    status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
  end

  mcontroller.setVelocity({0, 0})
end

function update(dt)
  mcontroller.setVelocity({0, 0})
  mcontroller.controlModifiers({
      facingSuppressed = true,
      movementSuppressed = true
    })
end

function onExpire()
  animator.setAnimationRate(1)
end
