require "/objects/wired/door/door.lua"

function init()
  storage.state = true
  shieldTimer = 0
  message.setHandler("interact", function()
    storage.state = false
	shieldTimer = 3
    animator.setAnimationState("shield", "activate")
	animator.playSound("activate")
	updateCollisionAndWires()
  end)
  message.setHandler("deactivate", function()
    storage.state = true
    animator.setAnimationState("shield", "deactivate")
	animator.playSound("deactivate")
	updateCollisionAndWires()
  end)
  message.setHandler("break", function()
    storage.state = true
    animator.setAnimationState("shield", "break")
	animator.playSound("break")
	updateCollisionAndWires()
  end)
end

function update(dt)
  shieldTimer = math.max(0, shieldTimer - dt)
  
end