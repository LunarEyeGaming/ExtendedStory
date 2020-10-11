require "/scripts/vec2.lua"
require "/scripts/util.lua"

function update()
  localAnimator.clearDrawables()

  animatedDrawableAttributes = animationConfig.animationParameter("animatedDrawableAttributes")
  animatedDrawableVars = animationConfig.animationParameter("animatedDrawableVars")
  if animatedDrawableVars == nil or animatedDrawableAttributes == nil then return end
  currentState = animatedDrawableVars.state
  currentProgress = animatedDrawableVars.progress
  currentDirection = animatedDrawableVars.direction

  frameNumber = animatedDrawableAttributes.stateFrames[currentState]
  frame = math.min(frameNumber, math.max(1, math.ceil(currentProgress * frameNumber)))
  drawable = copy(animatedDrawableAttributes.drawable)
  drawable.image = string.format("%s:%s.%i%s", drawable.image, currentState, frame, currentDirection < 0 and "?flipx" or "")
  drawable.position = vec2.add(entity.position(), {drawable.offset[1] * currentDirection, drawable.offset[2]})

  localAnimator.addDrawable(drawable, animatedDrawableAttributes.renderLayer)
end
