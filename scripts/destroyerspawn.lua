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
<<<<<<< HEAD
	  if chancesList[world.threatLevel()] then
	    destroyerAttemptSpawn(chancesList[world.threatLevel()], previousNumber)
	    attemptSpawnRan = true
	  end
=======
	  destroyerAttemptSpawn(30, previousNumber)
	  attemptSpawnRan = true
>>>>>>> bdc64ba7133a751c26b47322227b721e705bbd54
	end
  end
end

function destroyerAttemptSpawn(spawnChance, previousNumber)
  spawnSuccessChance = math.random(1, spawnChance)
<<<<<<< HEAD
  if spawnSuccessChance == spawnChance and not (world.type() == "unknown" or world.threatLevel() == 1 or world.isTileProtected(mcontroller.position())) then
=======
  if spawnSuccessChance == spawnChance and not (world.type() == "unknown" or world.isTileProtected(mcontroller.position())) then
>>>>>>> bdc64ba7133a751c26b47322227b721e705bbd54
    status.addEphemeralEffect("destroyerspawnstage1")
  end
end