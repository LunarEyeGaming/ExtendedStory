-- param variantNumber (number of variants)
-- param type
-- param state
-- The function of this is that it sets a somewhat random state type to an animation state and avoids state types that are in a specific state

function raBlinkEs(args, board)
  local variants = math.random(0, 4)
  if variants ~= 0 and animator.animationState("eye"..variants) == "idle" then
    animator.setAnimationState("eye"..variants, "blink")
  end
  
  return true
end
