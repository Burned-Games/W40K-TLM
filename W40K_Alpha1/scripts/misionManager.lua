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

--Mission5
local mission5Component = nil

--Mission6
local mission6Component = nil

--Mission7
local mission7Complet = false
enemyDie_M7 = 1

--Mission8
local mission8Component = nil

--Mission9
local mission9Component = nil

--Mission10
local mission10Complet = false
enemyDie_M10 = 1

--Text and Image
local textComponent = nil

--EnemyDieCount
enemyDieCount = 0

--WorkBrech
M5_WorkBrech = false
M9_WorkBrech = false
--misionNoheho
local nohecho = false

-- Initialize tasks when the engine is ready
function on_ready()
    --Mission3
    mission3_Enemy1_Component = current_scene:get_entity_by_name("Mission3Enemy1"):get_component("ScriptComponent")
    mission3_Enemy2_Component = current_scene:get_entity_by_name("Mission3Enemy2"):get_component("ScriptComponent")
    --Mission4
    mission4Component = current_scene:get_entity_by_name("Mission4Collider"):get_component("ScriptComponent")
    --Mission5
    mission5Component = current_scene:get_entity_by_name("Mission5Mesa"):get_component("ScriptComponent")
    --Mission6
    mission6Component = current_scene:get_entity_by_name("Mission6Collider"):get_component("ScriptComponent")
    --Mission8
    mission8Component = current_scene:get_entity_by_name("Mission8Collider"):get_component("ScriptComponent")
    --Mission9
    mission9Component = current_scene:get_entity_by_name("Mission9Collider"):get_component("ScriptComponent")

    textComponent = current_scene:get_entity_by_name("MisionText"):get_component("UITextComponent")
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


function insert_line_breaks(text, max_chars_per_line)
    local result = {}
    local current_line = ""
    local current_length = 0

    for word in text:gmatch("%S+") do  
        local word_length = utf8_char_count(word) 

        if current_length + word_length > max_chars_per_line then
            table.insert(result, current_line) 
            current_line = word  
            current_length = word_length
        else
            if current_line ~= "" then
                current_line = current_line .. " " .. word
                current_length = current_length + 1 + word_length 
            else
                current_line = word
                current_length = word_length
            end
        end
    end

    if current_line ~= "" then
        table.insert(result, current_line)  
    end

    return table.concat(result, "\n")  
end


function utf8_char_count(s)
    local _, count = s:gsub("[^\128-\191]", "")
    return count
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
        return "All missions done!"
    else
        local description = tasks[currentTaskIndex].description
        local formatted_desc = insert_line_breaks(description, 26)
        return formatted_desc


    end
end

function missionBlue_ZoneTutor()
    if currentTaskIndex == 1 and Input.get_axis_position(Input.axiscode.LeftX) ~= 0 then
        completeCurrentTask();
    end

    if(currentTaskIndex == 2 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0)  then
        completeCurrentTask();
    end

    if(currentTaskIndex == 3 and enemyDieCount >=2)  then
        completeCurrentTask();
    end

    if(currentTaskIndex == 4 and mission4Component.m4_Clear == true)  then
        completeCurrentTask();
    end


    if mission6Component.m6_Clear == true then
        jumpToNextMission(5)
    end
    if(currentTaskIndex == 5 and M5_WorkBrech == true)  then
        completeCurrentTask();
    end
 
    if(currentTaskIndex == 6 and mission6Component.m6_Clear == true)  then
        completeCurrentTask();
    end
    
    if mission6Component.m7_missionOpen == true then
        if enemyDie_M7 <= 0 then
            mission7Complet = true
        end
    end

    if currentTaskIndex == 7 and mission7Complet == true  then
        completeCurrentTask();
    end
    if currentTaskIndex == 8 and mission8Component.m8_Clear == true  then
        completeCurrentTask();
    end
    
    if mission9Component.m9_Clear == true then
        jumpToNextMission(9)
    end
    if currentTaskIndex == 9 and M9_WorkBrech == true  then
        completeCurrentTask();
    end

    if mission8Component.m10_missionOpen == true then
        if enemyDie_M10 <= 0 then
            mission10Complet = true
        end
    end

    if currentTaskIndex == 10 and mission10Complet == true then
        completeCurrentTask();
    end
end

function jumpToNextMission(nowTaks)
    if currentTaskIndex == nowTaks then
        completeCurrentTask();
    end
end

