-- param variantNumber (number of variants)
-- param type
-- param state
-- The function of this is that it sets a somewhat random state type to an animation state and avoids state types that are in a specific state

function raBlinkEs(args, board)
  local variants = math.random(0, 4)
  if variants == 1 and animator.animationState("eye1") == "idle" then
	animator.setAnimationState("eye1", "blink")
  elseif variants == 2 and animator.animationState("eye2") == "idle" then
	animator.setAnimationState("eye2", "blink")
  elseif variants == 3 and animator.animationState("eye3") == "idle" then
	animator.setAnimationState("eye3", "blink")
  elseif variants == 4 and animator.animationState("eye4") == "idle" then
	animator.setAnimationState("eye4", "blink")
  end
  
  return true
end
