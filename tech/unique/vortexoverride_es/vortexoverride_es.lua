require "/scripts/extendedstoryutil.lua"

function init()
  self.stoppingForce = config.getParameter("stoppingForce")
end

function uninit()
end

function update(args)
  if not args.moves["run"] and detectStatusEffect("abyssvortexmovement_es") then
    mcontroller.controlApproachVelocity({0, 0}, self.stoppingForce)
  end
end
