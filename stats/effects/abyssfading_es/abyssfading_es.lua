function init()
  self.colorFadeDuration = config.getParameter("colorFadeDuration")
  self.alphaFadeDuration = config.getParameter("alphaFadeDuration")
  self.fadeMax = config.getParameter("fadeMax")
  self.fadeColor = config.getParameter("fadeColor")
  self.elapsed = 0
  mcontroller.setVelocity({0, 0})
end

function update(dt)
  self.elapsed = self.elapsed + dt
  if self.elapsed < self.colorFadeDuration then
    local fade = (self.elapsed / self.colorFadeDuration) * self.fadeMax
    effect.setParentDirectives(string.format("fade=%s=%.2f", self.fadeColor, fade))
  elseif self.elapsed <= self.alphaFadeDuration + self.colorFadeDuration then
    local alphaDuration = self.alphaFadeDuration
    local alphaElapsed = self.elapsed - self.colorFadeDuration
    local alpha = math.max(math.floor(((alphaDuration - alphaElapsed) / alphaDuration) * 255), 0)
    effect.setParentDirectives(string.format("?multiply=ffffff%02x?fade=%s=%.2f", alpha, self.fadeColor, self.fadeMax))
  else
    effect.setParentDirectives("?multiply=ffffff00")
  end
end

function uninit()
end
