--By SlacDev lol

local die = true

function onPause()
    if die then
        setProperty('health', -500)
        return Function_Stop
    end
end
