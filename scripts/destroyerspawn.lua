require "/scripts/extendedstorymisc.lua"

--Makes the destroyer spawn

local oldUpdate = update

function update(dt)
  oldUpdate(dt)
  chancesList = {
    2000,
	300,
	200,
	50,
	40,
	30,
	20,
	9999999,
	9999999,
	10
  }
  threatLevel = world.threatLevel()
  if status.resourceMax("health") >= 160 then
    if world.timeOfDay() <= 0.1 and world.timeOfDay() >= 0 then
	  worldTimeRange = true
	else
	  worldTimeRange = false
	  attemptSpawnRan = false
	end
	if worldTimeRange == true and attemptSpawnRan == false then
	  if previousNumber == nil then
	    previousNumber = 0
	  end
	  if chancesList[threatLevel] then
	    destroyerAttemptSpawn(chancesList[threatLevel], previousNumber)
	    attemptSpawnRan = true
	  end
	end
  end
end

function destroyerAttemptSpawn(spawnChance, previousNumber)
  spawnSuccessChance = math.random(1, spawnChance)
  if spawnSuccessChance == spawnChance and not (world.type() == "unknown" or threatLevel == 1 or world.isTileProtected(mcontroller.position())) then
    status.addEphemeralEffect("destroyerspawnstage1")
  end
end