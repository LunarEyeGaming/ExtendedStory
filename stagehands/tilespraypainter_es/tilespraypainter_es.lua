require "/scripts/vec2.lua"

function init()
  minRadius = config.getParameter("minRadius")
  maxRadius = config.getParameter("maxRadius")
  clusterDensity = config.getParameter("brushClusterDensity")
  broadcastArea = config.getParameter("broadcastArea")
  broadcastPointSet = getPointMatrix(broadcastArea)
end

function getPointMatrix(pointRange)
  pointMatrix = {}
  pos = entity.position()
  for i = pointRange[1], pointRange[3] do
    for j = pointRange[2], pointRange[4] do
      position = vec2.add({i, j}, pos)
      table.insert(pointMatrix, position)
    end
  end
end

function generateCirclePointSet(radius)
  for i = -radius, radius do
    for j = -radius, radius do
      
    end
  end
end

function update()
  
end

function uninit()
  
end
