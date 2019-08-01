function init()
  self.tickDamagePercentage = 0.1
end

function update(dt)
end

function onExpire()
  for i = 1, 4 do
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = math.ceil(status.resourceMax("health") * self.tickDamagePercentage),
        damageSourceKind = "default",
        sourceEntityId = entity.id()
      })
  end
end
