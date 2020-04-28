require "/scripts/pathutil.lua"

-- Function: setOpenSegment: Sets segmentNumber to open and sets every segment from one to segmentCount EXCEPT segmentNumber to closed. It also translates the "cover" transformationGroup to the appropriate segment.
-- precondition: all segments have a margin of segmentSize in between each other, the median segment(s) must be the closest to the center
-- param segmentNumber -- the segment number in the sequence of segments
-- param segmentCount -- the number of segments in total
-- param segmentSize -- the size of each segment in blocks
function setOpenSegment(args, board)
  if args.segmentNumber == nil or args.segmentCount == nil or args.segmentSize == nil then return false end
  
  for i = 1, args.segmentCount do
    animator.setPartTag("segment"..i, "shellState", "closed")
  end
  
  animator.setPartTag("segment"..args.segmentNumber, "shellState", "open")
  
  local startSegmentOffset = args.segmentCount // 2
  local coverVerticalOffset = (startSegmentOffset - args.segmentNumber + 1) * args.segmentSize
  
  animator.resetTransformationGroup("cover")
  animator.translateTransformationGroup("cover", {0, coverVerticalOffset})

  return true
end
