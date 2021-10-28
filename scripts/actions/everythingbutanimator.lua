require "/scripts/pathutil.lua"

-- param variantNumber (number of variants)
-- param type
-- param state
-- The function of this is that it sets a somewhat random state type to an animation state and avoids state types that are in a specific state

function raBlinkEs(args, board)
  local highest = args.variantNumber
  local variants = math.random(0, highest)
  local stateType = args.stateType
  local selectedStateType = stateType..variants
  local state = args.toState
  
  if not variants == 0 then
    if not (variants == 1 and animator.animationState("eye1") == "charged") then
	  animator.setAnimationState(stateType, state)
	end
	if not (variants == 2 and animator.animationState("eye2") == "portalcharged") then
	  animator.setAnimationState(stateType, state)
	end
	if not (variants == 3 and animator.animationState("eye3") == "charged") then
	  animator.setAnimationState(stateType, state)
	end
	if not (variants == 4 and animator.animationState("eye4") == "charged") then
	  animator.setAnimationState(stateType, state)
	end
  end
end
