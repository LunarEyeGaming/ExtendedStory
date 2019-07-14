function init()
  message.setHandler("activate", function()
    output(true)
  end)
  message.setHandler("deactivate", function()
    output(false)
  end)
  output(config.getParameter("defaultSwitchState", false))
  self.inverted = config.getParameter("inverted")
  if storage.monsterId then
    world.sendEntityMessage(storage.monsterId, "despawn")
  end
  storage.monsterId = world.spawnMonster(config.getParameter("monsterType"), object.toAbsolutePosition(config.getParameter("monsterPosition")), {masterId = entity.id(), inverted = self.inverted})
end

function state()
  return storage.state
end

function output(state)
  storage.state = state
  if state then
    animator.setAnimationState("switchState", "on")
    if not (config.getParameter("alwaysLit")) then object.setLightColor(config.getParameter("lightColor", {0, 0, 0, 0})) end
    object.setSoundEffectEnabled(true)
    animator.playSound("on");
    object.setAllOutputNodes(true)
  else
    animator.setAnimationState("switchState", "off")
    if not (config.getParameter("alwaysLit")) then object.setLightColor(config.getParameter("lightColorOff", {0, 0, 0})) end
    object.setSoundEffectEnabled(false)
    animator.playSound("off");
    object.setAllOutputNodes(false)
  end
end
