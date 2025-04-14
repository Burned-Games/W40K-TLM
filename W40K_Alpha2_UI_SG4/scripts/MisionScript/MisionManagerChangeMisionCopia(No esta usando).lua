-- Task list
local tasks = {
    {id = 1, isRed = true , description = "Mueve el joystick izquierdo para moverte"},
    {id = 2, isRed = true ,description = "Apunta con el joystick derecho y pulsa R2 para disparar"},
    {id = 3, isRed = true ,description = "Termina con todos los orkos"},
    {id = 4, isRed = true ,description = "Llega a la siguiente zona"},
    {id = 5, isRed = true ,description = "Interactua con la mesa"},
    {id = 6, isRed = true ,description = "Llega a la siguiente zona"},
    {id = 7, isRed = true ,description = "Acaba con los orkos del campamento"},
    {id = 8, isRed = true ,description = "Busca la forma de continuar"},
    {id = 9, isRed = true ,description = "Mejora tu equipamiento con la mesa"},
    {id = 10, isRed = true ,description = "Limpia la zona de enemigos"}
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
local textTransform = nil

--EnemyDieCount
enemyDieCount = 0

--WorkBrech
M5_WorkBrech = false
M9_WorkBrech = false
--misionNoheho
local nohecho = false

--UIimage
imgComponent = nil
imgRedComponent = nil
local timeLerp = 0.0
local testB = false
local testA = false

--Animation
local startAnimation = false
local lerpReset = false
local AnimationClose = true
local changeText = false
local imgPosOri = 0
local imgPosDes = 0
local textPosOri = 0
local textPosDes = 0

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
    textTransform = current_scene:get_entity_by_name("MisionText"):get_component("TransformComponent")
   

    imgComponent = current_scene:get_entity_by_name("MisionImage"):get_component("TransformComponent")
    imgRedComponent = current_scene:get_entity_by_name("MisionImageRed"):get_component("TransformComponent")
    
end

-- Perform task completion check in each frame update
function on_update(dt)
    textComponent:set_text(getCurrentTask())
    missionBlue_ZoneTutor()

    if startAnimation == true then
        if AnimationClose == true then
            local inClosePosition = false
            if (tasks[currentTaskIndex].isRed == false and imgComponent.position.x == 124) or
               (tasks[currentTaskIndex].isRed == true and imgRedComponent.position.x == 124) then
                inClosePosition = true
            end

            local inOpenPosition = false
            if (tasks[currentTaskIndex].isRed == false and imgComponent.position.x == -123) or
               (tasks[currentTaskIndex].isRed == true and imgRedComponent.position.x == -123) then
                inOpenPosition = true
            end

            if misionAnimation(true, dt, tasks[currentTaskIndex].isRed) == true and
               ((tasks[currentTaskIndex].isRed == false and imgComponent.position.x == 124) or
                (tasks[currentTaskIndex].isRed == true and imgRedComponent.position.x == 124)) then
                if lerpReset == true then
                    timeLerp = 0.0
                    lerpReset = false
                    AnimationClose = false
                    completeCurrentTask()
                end
            end
        else
            if misionAnimation(false, dt, tasks[currentTaskIndex].isRed) == true and
               ((tasks[currentTaskIndex].isRed == false and imgComponent.position.x == -123) or
                (tasks[currentTaskIndex].isRed == true and imgRedComponent.position.x == -123)) then
                if lerpReset == true then
                    timeLerp = 0.0
                    lerpReset = false
                    AnimationClose = true
                    startAnimation = false
                end
            end
        end
    end
end


-- Cleanup when the game exits
function on_exit()
    --print("Mission cleared!")
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
        --print("All missions done!")
        return
    end
    --print("Mission done: " .. tasks[currentTaskIndex].description)
    currentTaskIndex = currentTaskIndex + 1  -- Move to the next task


end

-- Get the current task
function getCurrentTask()
    if currentTaskIndex > #tasks then
        ----print("No mission")
        return "All missions done!"
    else
        local description = tasks[currentTaskIndex].description
        local formatted_desc = insert_line_breaks(description, 26)
        return formatted_desc


    end
end

function missionBlue_ZoneTutor()
    if currentTaskIndex == 1 and Input.get_axis_position(Input.axiscode.LeftX) ~= 0 then
        startAnimation = true

    end

    if(currentTaskIndex == 2 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0)  then
        startAnimation = true
    end

    if(currentTaskIndex == 3 and enemyDieCount >=2)  then
        startAnimation = true
    end

    if(currentTaskIndex == 4 and mission4Component.m4_Clear == true)  then
        startAnimation = true
    end


    if mission6Component.m6_Clear == true then
        jumpToNextMission(5)
    end
    if(currentTaskIndex == 5 and M5_WorkBrech == true)  then
        startAnimation = true
    end
 
    if(currentTaskIndex == 6 and mission6Component.m6_Clear == true)  then
        startAnimation = true
    end
    
    if mission6Component.m7_missionOpen == true then
        if enemyDie_M7 <= 0 then
            mission7Complet = true
        end
    end

    if currentTaskIndex == 7 and mission7Complet == true  then
        startAnimation = true
    end
    if currentTaskIndex == 8 and mission8Component.m8_Clear == true  then
        startAnimation = true
    end
    
    if mission9Component.m9_Clear == true then
        jumpToNextMission(9)
    end
    if currentTaskIndex == 9 and M9_WorkBrech == true  then
        startAnimation = true
    end

    if mission8Component.m10_missionOpen == true then
        if enemyDie_M10 <= 0 then
            mission10Complet = true
        end
    end

    if currentTaskIndex == 10 and mission10Complet == true then
        startAnimation = true
    end
end

function jumpToNextMission(nowTaks)
    if currentTaskIndex == nowTaks then
        startAnimation = true
    end
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function misionAnimation(closeMision,dt, redMision)

    local imgEntity = nil
    if closeMision == true then
        imgPosOri = -123
        imgPosDes = 124
        textPosOri = -27
        textPosDes = 220
    else
        imgPosOri = 124
        imgPosDes = -123
        textPosOri = 220
        textPosDes = -27
    end

    if redMision == false then
        imgComponent.position.x = lerp(imgPosOri, imgPosDes, timeLerp)
    else
        imgRedComponent.position.x = lerp(imgPosOri, imgPosDes, timeLerp)
    end

    textTransform .position.x = lerp(textPosOri, textPosDes, timeLerp)
    timeLerp = timeLerp + (dt * 3);
    if timeLerp > 1 then
        timeLerp = 1
        lerpReset = true
        return true
    end
end


