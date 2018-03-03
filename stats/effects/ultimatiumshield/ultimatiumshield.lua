function init()
  status.setResource("damageAbsorption", 5)
  newShieldHealth = status.resourcePercentage("damageAbsorption")
  oldShieldHealth = 5
  recharge = 3
end

function update(dt)
  oldShieldHealth = newShieldHealth
  newShieldHealth = status.resourcePercentage("damageAbsorption")
  shieldHealthDifference = newShieldHealth - oldShieldHealth
  if shieldHealthDifference > 0 then
    if status.resourcePositive("damageAbsorption") then
      animator.playSound("hit")
	else
	  animator.playSound("break")
	  recharge = 0
	end
  end
  if recharge < 3 and recharge >= 0 then
    recharge = recharge + dt
	rechargeCheck()
  end
end

function rechargeCheck()
  if recharge == 3 then
    animator.playSound("charged")
  end
end
