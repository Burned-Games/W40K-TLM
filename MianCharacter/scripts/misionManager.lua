-- Task list
tasks = {
    {id = 1, description = "Usa el joystick izquierdo para moverte por el mapa"},
    {id = 2, description = "Apunta con el joystick derecho y dispara con RT"},
    {id = 3, description = "Derrota a los enemigos"}
}

local currentTaskIndex = 1  -- Current task index

-- Initialize tasks when the engine is ready
function on_ready()
    textComponent = self:get_component("UITextComponent");
end

-- Perform task completion check in each frame update
function on_update(dt)

    textComponent:set_text(getCurrentTask())


    if currentTaskIndex == 1 and Input.get_axis_position(Input.axiscode.LeftX) ~= 0 then
        completeCurrentTask();
    end

    if(currentTaskIndex == 2 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0)  then
        completeCurrentTask();
    end


end

-- Cleanup when the game exits
function on_exit()
    print("Mission cleared!")
end



-- Complete the current task
function completeCurrentTask()
    if currentTaskIndex > #tasks then
        print("All missions done!")
        return
    end

    print("Mission done: " .. tasks[currentTaskIndex].description)
    currentTaskIndex = currentTaskIndex + 1  -- Move to the next task
end

-- Get the current task
function getCurrentTask()
    if currentTaskIndex > #tasks then
        --print("No mission")
        return ""
    else
        --print("Current mission: " .. tasks[currentTaskIndex].description)
        return tasks[currentTaskIndex].description
    end
end
