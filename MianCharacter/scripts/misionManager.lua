-- Task list
tasks = {
    {id = 1, description = "Mueve el joystick izquierdo para moverte"},
    {id = 2, description = "Apunta con el joystick derecho y pulsa R2 para disparar"},
    {id = 3, description = "Termina con todos los orkos"},
    {id = 4, description = "Llega a la siguiente zona"},
    {id = 5, description = "Interactua con la mesa"},
    {id = 6, description = "Llega a la siguiente zona"},
    {id = 7, description = "Acaba con los orkos del campamento"},
    {id = 8, description = "Busca la forma de continuar"},
    {id = 9, description = "Mejora tu equipamiento con la mesa"},
    {id = 10, description = "Limpia la zona de enemigos"}
}
local currentTaskIndex = 1  -- Current task index

--Mission3
local mission3_Enemy1_Component = nil
local mission3_Enemy2_Component = nil
--Mission4
local mission4Component = nil



-- Initialize tasks when the engine is ready
function on_ready()
    textComponent = self:get_component("UITextComponent");
    --Mission3
    mission3_Enemy1_Component = current_scene:get_entity_by_name("Mision3Enemy1"):get_component("ScriptComponent")
    mission3_Enemy2_Component = current_scene:get_entity_by_name("Mision3Enemy2"):get_component("ScriptComponent")
    --Mission4
    mission4Component = current_scene:get_entity_by_name("Mission4CCollider"):get_component("ScriptComponent")
end

-- Perform task completion check in each frame update
function on_update(dt)

    textComponent:set_text(getCurrentTask())
    missionBlue_ZoneTutor()
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

function missionBlue_ZoneTutor()
    if currentTaskIndex == 1 and Input.get_axis_position(Input.axiscode.LeftX) ~= 0 then
        completeCurrentTask();
    end

    if(currentTaskIndex == 2 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0)  then
        completeCurrentTask();
    end
    if(currentTaskIndex == 3 and mission3_Enemy1_Component.m3_enemy1_die == true and mission3_Enemy2_Component.m3_enemy2_die == true)  then
        completeCurrentTask();
    end

    if(currentTaskIndex == 4 and mission4Component.mission4Clear == true)  then
        completeCurrentTask();
    end

    if(currentTaskIndex == 5 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0)  then
        completeCurrentTask();
    end
    if(currentTaskIndex == 6 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0)  then
        completeCurrentTask();
    end
    if(currentTaskIndex == 7 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0)  then
        completeCurrentTask();
    end
    if(currentTaskIndex == 8 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0)  then
        completeCurrentTask();
    end
    if(currentTaskIndex == 9 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0)  then
        completeCurrentTask();
    end
    if(currentTaskIndex == 10 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0)  then
        completeCurrentTask();
    end
end

function jumpToNextMission(nowTaks)
    if currentTaskIndex == nowTaks then
        completeCurrentTask();
    end
end

