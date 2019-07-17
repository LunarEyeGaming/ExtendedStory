function init()
  self.blockedStatusEffects = config.getParameter("blockedStatusEffects")
  effect.addStatModifierGroup({{stat = "healingStatusImmunity", amount = 1}})
end

function update(dt)
  for _, statusEffect in pairs(self.blockedStatusEffects) do
    status.removeEphemeralEffect(statusEffect)
  end
end

function uninit()

end
