-- Variables and their defaults for saving and loading.
local checkpointTime = 0
local checkpointOffset = 0
local retainOldHealth = false
local oldHealth = 1
local savedScore = 0
local savedMisses = 0
local savedRating = 0
local savedHits = 0
local savedNamedRating = nil
local savedFCRating = nil
local savedScrollSpeed = scrollSpeed
local safetyNet = true
local stepSave = 0
local noteMissHealth = nil

-- Checkpoint Event Variables.
function onEvent(name, value1, value2)
if name == 'Add Checkpoint' then
checkpointTime = getPropertyFromClass('Conductor', 'songPosition')
debugPrint('Saved Time!')
if value1 == true then
retainOldHealth = true
oldHealth = getProperty('health')
debugPrint('Health saved!')
else
retainOldHealth = false
end
if value2 == '' or value2 == nil then
checkpointOffset = 0
else
checkpointOffset = value2
debugPrint('Checkpoint Offset made.')
end
checkpointSave()
end
end

-- Initialize and grab Checkpoint Data if it exists.
function onCreate()
luaDebugMode = true
initSaveData('checkpointData_' .. songName);
retainOldHealth = getDataFromSave('checkpointData_' .. songName, 'healthSave', false)
checkpointTime = getDataFromSave('checkpointData_' .. songName, 'time', 0)
oldHealth = getDataFromSave('checkpointData_' .. songName, 'healthRetained', 1)
savedScore = getDataFromSave('checkpointData_' .. songName, 'score', 0)
savedMisses = getDataFromSave('checkpointData_' .. songName, 'misses', 0)
savedHits = getDataFromSave('checkpointData_' .. songName, 'hits', 0)
savedRating = getDataFromSave('checkpointData_' .. songName, 'ratingScore', 0)
savedNamedRating = getDataFromSave('checkpointData_' .. songName, 'ratingName', 'checkpoint.Rating')
savedFCRating = getDataFromSave('checkpointData_' .. songName, 'ratingFC', nil)
savedScrollSpeed = getDataFromSave('checkpointData_' .. songName, 'scrollSpeed')
checkpointOffset = getDataFromSave('checkpointData_' .. songName, 'offset')
stepSave = getDataFromSave('checkpointData_' .. songName, 'eventStep')
debugPrint('Checkpoint System loaded.')
debugPrint('HealthSet:', retainOldHealth)
debugPrint('Health:', oldHealth)
debugPrint('Checkpoint:', checkpointTime)
debugPrint('Offset:', checkpointOffset)
end

-- Checkpoint Saving.
function checkpointSave()
debugPrint('Attempting Save...')
setDataFromSave('checkpointData_' .. songName, 'healthSave', retainOldHealth)
setDataFromSave('checkpointData_' .. songName, 'time', checkpointTime)
setDataFromSave('checkpointData_' .. songName, 'healthRetained', oldHealth)
setDataFromSave('checkpointData_' .. songName, 'score', score)
setDataFromSave('checkpointData_' .. songName, 'misses', misses)
setDataFromSave('checkpointData_' .. songName, 'hits', hits)
setDataFromSave('checkpointData_' .. songName, 'ratingScore', rating)
setDataFromSave('checkpointData_' .. songName, 'ratingName', ratingName)
setDataFromSave('checkpointData_' .. songName, 'ratingFC', ratingFC)
setDataFromSave('checkpointData_' .. songName, 'scrollSpeed', getProperty('songSpeed'))
setDataFromSave('checkpointData_' .. songName, 'offset', checkpointOffset)
setDataFromSave('checkpointData_' .. songName, 'eventStep', stepSave)
debugPrint('Checkpoint reached, and saved!')
--flushSaveData('checkpointData_')
end

-- Load a Checkpoint on the start of a song, also protects from cheap Checkpoint Positions, and prevents the game from killing you.
function checkpointLoad()
	for i = 0, getProperty('unspawnNotes.length')-1 do
noteMissHealth = getPropertyFromGroup('unspawnNotes', i, 'missHealth')
setPropertyFromGroup('unspawnNotes', i, 'missHealth', '0')
setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
end
setPropertyFromClass('Conductor', 'songPosition', checkpointTime + checkpointOffset)
setPropertyFromClass('flixel.FlxG', 'sound.music.time', getPropertyFromClass('Conductor', 'songPosition'))
setProperty('vocals.time', getPropertyFromClass('Conductor', 'songPosition'))
setProperty('health', oldHealth)
setScore(savedScore)
setMisses(savedMisses)
setHits(savedHits)
setRatingPercent(savedRating)
setRatingName(savedNamedRating)
setRatingFC(savedFCRating)
debugPrint('Checkpoint loaded!')
debugPrint('Note Miss:', noteMissHealth)
end

-- Yes.
function onSongStart()
checkpointLoad()
end

-- Clear Data, as there's no need for the checkpoint when the song is over.
function onEndSong()
saveDeleteDebug()
setDataFromSave('checkpointData_' .. songName, 'healthSave', nil)
setDataFromSave('checkpointData_' .. songName, 'time', nil)
setDataFromSave('checkpointData_' .. songName, 'healthRetained', nil)
setDataFromSave('checkpointData_' .. songName, 'score', nil)
setDataFromSave('checkpointData_' .. songName, 'misses', nil)
setDataFromSave('checkpointData_' .. songName, 'hits', nil)
setDataFromSave('checkpointData_' .. songName, 'ratingScore', nil)
setDataFromSave('checkpointData_' .. songName, 'ratingName', nil)
setDataFromSave('checkpointData_' .. songName, 'ratingFC', nil)
setDataFromSave('checkpointData_' .. songName, 'scrollSpeed', nil)
setDataFromSave('checkpointData_' .. songName, 'offset', nil)
setDataFromSave('checkpointData_' .. songName, 'eventStep', nil)
--flushSaveData('checkpointData_')
debugText('Deleting Checkpoint...')
end

-- Disables Protection once the Checkpoint is loaded.
function onStepHit()
if safetyNet then
	for i = 0, getProperty('unspawnNotes.length')-1 do
setPropertyFromGroup('unspawnNotes', i, 'missHealth', noteMissHealth)
setScore(savedScore)
setMisses(savedMisses)
setHits(savedHits)
setRatingPercent(savedRating)
setRatingName(savedNamedRating)
setRatingFC(savedFCRating)
setProperty('songMisses', savedMisses)
setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false)
safetyNet = false
end
end
end

-- This function is for later, so that leaving a song from the Pause Menu would also clear the data.
function onExitSong()
setDataFromSave('checkpointData_' .. songName, 'healthSave', nil)
setDataFromSave('checkpointData_' .. songName, 'time', nil)
setDataFromSave('checkpointData_' .. songName, 'healthRetained', nil)
setDataFromSave('checkpointData_' .. songName, 'score', nil)
setDataFromSave('checkpointData_' .. songName, 'misses', nil)
setDataFromSave('checkpointData_' .. songName, 'hits', nil)
setDataFromSave('checkpointData_' .. songName, 'ratingScore', nil)
setDataFromSave('checkpointData_' .. songName, 'ratingName', nil)
setDataFromSave('checkpointData_' .. songName, 'ratingFC', nil)
setDataFromSave('checkpointData_' .. songName, 'scrollSpeed', nil)
setDataFromSave('checkpointData_' .. songName, 'offset', nil)
setDataFromSave('checkpointData_' .. songName, 'eventStep', nil)
debugText('Deleting Checkpoint...')
end


-- Debug Functions

-- Coming soon, for now, Debug Text is always visible, unless you use "--" to hide them!

-- Also, if you enable flushing the data, this should allow you to keep Checkpoints even after closing the game. Not tested yet.
