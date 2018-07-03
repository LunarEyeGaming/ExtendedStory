require "/scripts/extendedstorymisc.lua"

--Makes the destroyer spawn

local oldUpdate = update

function update(dt)
  oldUpdate(dt)
  if status.resourceMax("health") >= 160 then
    if world.timeOfDay() <= 0.1 and world.timeOfDay() >= 0 then
	  worldTimeRange = true
	else
	  worldTimeRange = false
	  attemptSpawnRan = false
	end
	if worldTimeRange == true and attemptSpawnRan == false then
	  destroyerAttemptSpawn(50)
	  attemptSpawnRan = true
	end
  end
end

function destroyerAttemptSpawn(spawnChance)
  spawnSuccessChance = math.random(1, spawnChance)
  if spawnSuccessChance == spawnChance and not world.type() == "unknown" then
    status.addEphemeralEffect("destroyerspawnstage1")
  end
end