require "/scripts/util.lua"

function init()
  self.detectArea = config.getParameter("detectArea")
  self.detectArea[1] = object.toAbsolutePosition(self.detectArea[1])
  self.detectArea[2] = object.toAbsolutePosition(self.detectArea[2])

  animator.setAnimationState("portal", "idle")

  storage.uuid = storage.uuid or sb.makeUuid()
  object.setInteractive(true)
end

function update(dt)
  if self.radioMessage ~= nil then
    self.radioMessage(dt)
  end

  local players = world.entityQuery(self.detectArea[1], self.detectArea[2], {
      includedTypes = {"player"},
      boundMode = "CollisionArea"
    })
end

function onInteraction(args)
  if config.getParameter("returnDoor") then
    return { "OpenTeleportDialog", {
        canBookmark = false,
        includePlayerBookmarks = false,
        destinations = { {
          name = "Exit Portal",
          planetName = "Return to World... Hopefully!",
          icon = "return",
          warpAction = "Return"
        } }
      }
    }
  else
    return { "OpenTeleportDialog", {
        canBookmark = false,
        includePlayerBookmarks = false,
        destinations = { {
          name = "Cryonia Temple",
          planetName = "Frozen Dimension",
          icon = "default",
          warpAction = string.format("InstanceWorld:iceartifactdungeon3:%s", storage.uuid)
        } }
      }
    }
  end
end
