--Attempt at making a tech deactivater

function init()
  message.setHandler("deactivate", deactivateancientsphere())
  message.setHandler("activate", activateancientsphere())
  sphereEquipped = false
end

function update(dt)
  equippedTech = player.equippedTech("head")
end

function deactivateancientsphere()
  if equippedTech == "ancientflight" then
    player.unequipTech("ancientflight")
	sphereEquipped = true
  end
end

function activateancientsphere()
  if not equippedTech == "ancientflight" and sphereEquipped == true then --The tech should be reequipped if the player was affected by the deactivater
    player.equipTech("ancientflight")
	sphereEquipped = false
  end
end