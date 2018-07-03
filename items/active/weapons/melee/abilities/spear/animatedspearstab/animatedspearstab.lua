require "/items/active/weapons/melee/meleeslash.lua"

-- Spear stab attack
-- Extends normal melee attack and adds a hold state
SpearStab = MeleeSlash:new()

function SpearStab:init()
  MeleeSlash.init(self)

  self.holdDamageConfig = sb.jsonMerge(self.damageConfig, self.holdDamageConfig)
  self.holdDamageConfig.baseDamage = self.holdDamageMultiplier * self.damageConfig.baseDamage
end

function SpearStab:windup()
  if self.windupAnimationState then
    animator.setAnimationState("spear", self.windupAnimationState)
  end
  MeleeSlash.windup(self)
end

function SpearStab:fire()
  if self.fireAnimationState then
    animator.setAnimationState("spear", self.fireAnimationState)
  end
  MeleeSlash.fire(self)

  if self.fireMode == "primary" and self.allowHold ~= false then
    self:setState(self.hold)
  elseif self.altCooldownAnimationState then
    animator.setAnimationState("spear", self.altCooldownAnimationState)
  elseif self.cooldownAnimationState then
    animator.setAnimationState("spear", self.cooldownAnimationState)
  end
end

function SpearStab:hold()
  self.weapon:setStance(self.stances.hold)
  self.weapon:updateAim()

  while self.fireMode == "primary" do
    local damageArea = partDamageArea("blade")
    self.weapon:setDamage(self.holdDamageConfig, damageArea)
    coroutine.yield()
  end
  if self.cooldownAnimationState then
    animator.setAnimationState("spear", self.cooldownAnimationState)
  end
  self.cooldownTimer = self:cooldownTime()
end
