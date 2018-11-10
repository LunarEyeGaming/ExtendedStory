--Attempt at making a tech deactivater

function update(dt)
  message.setHandler("deactivate", deactivateancientsphere())
  message.setHandler("activate", activateancientsphere())
end

function deactivateancientsphere()
  status.addEphemeralEffect("spheredeactivater")
end

function activateancientsphere()
  status.removeEphemeralEffect("spheredeactivater")
end