-- param variantNumber (number of variants)
-- param type
-- param state
-- The function of this is that it sets a somewhat random state type to an animation state and avoids state types that are in a specific state

function raBlinkEs(args, board)
  local variants = math.random(0, 4)
  
  if not variants == 0 then
    if variants == 1 and not animator.animationState("eye1") == "charged" then
	  animator.setAnimationState("eye1", "blink")
	end
	if variants == 2 and not animator.animationState("eye2") == "portalcharged" then
	  animator.setAnimationState("eye2", "blink")
	end
	if variants == 3 and not animator.animationState("eye3") == "charged" then
	  animator.setAnimationState("eye3", "blink")
	end
	if variants == 4 and not animator.animationState("eye4") == "charged" then
	  animator.setAnimationState("eye4", "blink")
	end
  end
  
  return true
end
