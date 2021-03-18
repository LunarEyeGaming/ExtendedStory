require "/scripts/status.lua"

function init()
  broken = false
  recharged = false
  shieldMode = "default"
  self.maxShieldHealth = status.stat("maxHealth") * config.getParameter("shieldHealthMultiplier")
  status.setResource("damageAbsorption", self.maxShieldHealth)

  self.active = true
  self.rechargeDelay = config.getParameter("rechargeDelay") or 0
  self.rechargeRate = self.maxShieldHealth * 0.25
  
  self.barDimensions = config.getParameter("barDimensions")
  self.maxHueShift = config.getParameter("maxHueShift")
  
  currentShieldHealth = status.resource("damageAbsorption")
  
  addVisualEffect()
  
end

function update(dt)
  --Recharging
  maxShieldHealth = self.maxShieldHealth
  
  self.rechargeDelay = self.rechargeDelay - dt
  if self.rechargeDelay <= 0 then
    status.giveResource("damageAbsorption", self.rechargeRate * dt)
    broken = false
  end
  --Damage Detection(special)
  
  --damageListener works too, but it does not ignore damage equal to 0; it can be pretty annoying for 
  --when a status effect is applied to the player via a damage source or projectile
  oldShieldHealth = currentShieldHealth
  currentShieldHealth = status.resource("damageAbsorption")
  if currentShieldHealth < oldShieldHealth then
    animator.playSound("hit")
    self.rechargeDelay = config.getParameter("rechargeDelay") or 0
    recharged = false
  end
  if not status.resourcePositive("damageAbsorption") and broken == false then
    animator.playSound("break")
    broken = true
  end
  --Display Shield Bar
  animator.resetTransformationGroup("energybar")
  shieldHealthRatio = status.resource("damageAbsorption") / maxShieldHealth
  animator.setAnimationState("energybar", "on")

  animator.setGlobalTag("barDirectives", "?crop=0;0;"..shieldHealthRatio * self.barDimensions[1]..";"..self.barDimensions[2])
  animator.setGlobalTag("hueDirectives", "?hueshift="..shieldHealthRatio * self.maxHueShift)
  animator.translateTransformationGroup("energybar", {-(1 - shieldHealthRatio) * self.barDimensions[1] / 16, 0})
  --Shield Cap, useful for getting rid of negative damage, such as fall damage on moons
  if currentShieldHealth > maxShieldHealth then
    status.setResource("damageAbsorption", self.maxShieldHealth)
  end
  if currentShieldHealth >= maxShieldHealth and recharged == false then
    animator.playSound("charged")
    recharged = true
  end
end

function addVisualEffect()
  if not config.getParameter("hideBorder") then effect.setParentDirectives("") end
end

function removeVisualEffect()
  effect.setParentDirectives("")
end

function onExpire()
  status.setResource("damageAbsorption", 0)
end
