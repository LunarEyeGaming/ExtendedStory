require "/scripts/pathutil.lua"

-- Function: isMaterial: returns whether the material at the given position and layer is the given material.
-- param position
-- param layer
-- param material
function isMaterial(args, board)
  if not (args.material or args.layer or args.position) then return false end
  materialName = world.material(args.position, args.layer)
  if not materialName then return false end
  return materialName == args.material
end

-- Function: getMaterial: returns the material at the given position and layer
-- param position
-- param layer
function getMaterial(args, board)
  if not (args.position or args.layer) then return false end
  return true, {material = world.material(args.position, args.layer)}
end
