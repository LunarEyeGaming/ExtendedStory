require "/scripts/status.lua"

function init()
  self.maxShieldHealth = status.stat("maxHealth") * config.getParameter("shieldHealthMultiplier")
  status.setResource("damageAbsorption", self.maxShieldHealth)

  self.active = true
  self.expirationTimer = config.getParameter("expirationTime") or 0

  addVisualEffect()
  self.listener = damageListener("damageTaken", function()
    if self.active then
      animator.playSound("hit")
	end
  end)
  
end

function update(dt)
  self.listener:update()
  if not status.resourcePositive("damageAbsorption") then
    if self.active then
      removeVisualEffect()
    end

    if self.expirationTimer <= 0 then
      status.setResource("damageAbsorption", self.maxShieldHealth)
	  animator.playSound("charged")
    end
    self.expirationTimer = self.expirationTimer - dt

    self.active = false
	if broken == false then
	  animator.playSound("break")
	end
	broken = true
  else
    if not self.active then
      addVisualEffect()
    end

    self.active = true
    self.expirationTimer = config.getParameter("expirationTime") or 0
	broken = false
  end
  maxShieldHealth = self.maxShieldHealth
  shieldHealthRatio = status.resource("damageAbsorption") / maxShieldHealth
  animator.setAnimationState("energybar", "on")

  animator.setGlobalTag("barDirectives", "?scalenearest;"..shieldHealthRatio..";1")
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
