require "/scripts/pathutil.lua"
require "/scripts/vec2.lua"

-- Function: setOpenSegment: Sets segmentIndex to open and every other segment to closed. Also translates the "cover" transformationGroup to the appropriate segment.
-- precondition: all segments have a margin of segmentSize in between each other, the median segment(s) is/are the closest to the center
-- param segmentIndex -- the segment number in the sequence of segments
-- param segmentCount -- the number of segments in total
-- param segmentSize -- the size of each segment in blocks
-- param coverOffset -- the offset of the cover. Used to identify the location of the shell shard burst projectile.
-- output openSegmentOffset
function setOpenSegment(args, board)
  if args.segmentIndex == nil or args.segmentCount == nil or args.segmentSize == nil then return false end
  
  for i = 1, args.segmentCount do
    animator.setPartTag("segment"..i, "shellState", "closed")
  end
  
  animator.setPartTag("segment"..args.segmentIndex, "shellState", "open")

  local openSegmentOffset = getSegmentToOffset_(args.segmentIndex, args.segmentCount, args.segmentSize)
  local coverOffset = {args.coverOffset[1] * mcontroller.facingDirection(), args.coverOffset[2]}
  local finalOffset = vec2.add(openSegmentOffset, coverOffset)
  
  animator.resetTransformationGroup("cover")
  animator.translateTransformationGroup("cover", openSegmentOffset)
  animator.playSound("switchSegment")
  world.spawnProjectile("nyctosshellshardburst_es", vec2.add(mcontroller.position(), finalOffset))

  return true, {openSegmentOffset = finalOffset}
end

-- param capturerId
-- param percentage
-- output healthPercentage
function capturerHealthPercentage(args, board)
  if args.capturerId == nil or not world.entityExists(args.capturerId) then return false end
  local health = world.entityHealth(args.capturerId)
  local percentage = health[1] / health[2]

  return percentage > args.percentage
end

-- Returns a vec2 based on the segment index, the total number of segments, and the size of each segment
function getSegmentToOffset_(segmentIndex, segmentCount, segmentSize)
  local startSegmentOffset = segmentCount // 2
  local coverVerticalOffset = (startSegmentOffset - segmentIndex + 1) * segmentSize
  
  return {0, coverVerticalOffset}
end