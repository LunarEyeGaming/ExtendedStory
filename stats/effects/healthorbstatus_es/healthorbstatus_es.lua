function init()
  self.initialPercentage = config.getParameter("initialPercentage", 1.0)
  self.finalPercentage = config.getParameter("finalPercentage", 0.5)
  status.setResourcePercentage("health", self.initialPercentage)
  self.changeRate = (self.finalPercentage - self.initialPercentage) / effect.duration()
end

function update(dt)
  if status.resourcePercentage("health") > self.finalPercentage then
    status.modifyResourcePercentage("health", self.changeRate * dt)
  else
    effect.expire()
  end
end
