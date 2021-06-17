require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/behavior/bdata.lua"

-- A function that sets an animation parameter. Why this is not a thing in vanilla is beyond me.
-- param key
-- param value

function setAnimationParameter(args, board)
  if args.key == nil then return false end
  monster.setAnimationParameter(args.key, args.value)
  return true
end

-- Sets data of the specified key in a JSON object to value.
-- param object
-- param key
-- Refer to ListTypes in bdata.lua for info on the types of values that can be inserted.
-- output object

function setJsonObjectKey(args, board)
  if args.key == nil then return false end
  local newObject = args.object ~= nil and copy(args.object) or {}
  for _, dataType in pairs(ListTypes) do
    if args[dataType] then
      newObject[args.key] = args[dataType]
      return true, {object = newObject}
    end
  end
  return false, {object = object}
end

-- Removes a key from a JSON object
-- param object
-- param key
-- output object

function removeJsonObjectKey(args, board)
  if args.key == nil or args.object == nil then return false end
  local newObject = copy(args.object)
  newObject[args.key] = nil
  return true, {object = newObject}
end

-- Gets the value of a specified key in a JSON object.
-- param object
-- param key
-- output value

function getJsonObjectKey(args, board)

end

-- Returns a string. Ideal for setting board variables.
-- param string
-- output stringVal

function setString(args, board)
  if args.string == nil then return false end
  return true, {stringVal = args.string} -- string is a reserved word lol
end

-- Normalizes a vector. Why isn't this in any existing node lists?
-- param vector
-- output vector

function vecNorm(args, board)
  if args.vector == nil then return false end
  result = vec2.norm(args.vector)
  return true, {vector = result, x = result[1], y = result[2]}
end

-- param position1
-- param position2
-- param entityTypes
-- param orderBy
-- param withoutEntity
-- output entity
-- output list
function queryEntityRect(args, board)
  if args.position1 == nil or args.position2 == nil then return false end

  local queryArgs = {
    includedTypes = args.entityTypes,
    order = args.orderBy,
    withoutEntityId = args.withoutEntity
  }
  local nearEntities = world.entityQuery(args.position1, args.position2, queryArgs)
  if #nearEntities > 0 then
    return true, {entity = nearEntities[1], list = nearEntities}
  end

  return false
end