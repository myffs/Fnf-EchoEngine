local time = 0
function onUpdate(elapsed)
    time = time + elapsed
    setProperty('dad.y', defaultOpponentY + (math.sin(time)*50)-50)
end
