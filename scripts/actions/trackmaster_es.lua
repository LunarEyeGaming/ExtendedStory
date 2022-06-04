function trackMaster_es(args, board)
  if not world.entityExists(config.getParameter("masterId")) then
    status.setResourcePercentage("health", 0.0)
    return true
  end
  
  return false
end