-- Task list split by color
local blueTasks = {
    {id = 1, description = "Start moving with [L]"},
    {id = 2, description = "Aim with [R] and shoot with [RT]"},
    {id = 3, description = "Defeat both Orkz (x/2)"},
    {id = 4, description = "Finish the Orkz and pull the lever up"},
    {id = 5, description = "Upgrade your equipment with the drop pod supply"},
    {id = 6, description = "Find and get the (name) to heal yourself"},
    {id = 7, description = "Upgrade your equipment for the big fight"},
    {id = 8, description = "Pull both levers to get to the Orkz base"},
    {id = 9, description = "Be the last standing on the Orkz Colliseum (x/3)"},
    {id = 10, description = "Upgrade your equipment before leaving the Orkz base"},
    {id = 11, description = "Find a way to get to the Hive City"}
}



local redTasks = {
    {id = 1, description = "Find the drop pod supply"},
    {id = 2, description = "Make your way to the orkz base"},
    {id = 3, description = "Break out of the orkz base to the Hive City"}
}

local blueTaskIndex = 1
local redTaskIndex = 1

-- Components
local textBlueComponent = nil
local textRedComponent = nil
local textBlueTransform = nil
local textRedTransform = nil
local imgBlue = nil
local imgRed = nil

-- Animation control
local blueAnimation = {start = false, closing = true, lerpTime = 0.0, reset = false, playing = false}
local redAnimation = {start = false, closing = true, lerpTime = 0.0, reset = false, playing = false}

-- Position control
local imgPosOri = -123
local imgPosDes = 124
local textPosOri = -27
local textPosDes = 220

-- Other components
local mission4Component = nil
local mission5Component = nil
local mission6Component = nil
local mission7Complet = false
local mission8Component = nil
local mission9Component = nil
local mission10Complet = false


enemyDieCounttest = 3
-- Trigger variables
enemyDieCount = 0
enemyDie_M7 = 1
enemyDie_M10 = 1
M5_WorkBrech = false
M9_WorkBrech = false

function on_ready()
    mission4Component = current_scene:get_entity_by_name("Mission4Collider"):get_component("ScriptComponent")
    mission5Component = current_scene:get_entity_by_name("Mission5Mesa"):get_component("ScriptComponent")
    mission6Component = current_scene:get_entity_by_name("Mission6Collider"):get_component("ScriptComponent")
    mission8Component = current_scene:get_entity_by_name("Mission8Collider"):get_component("ScriptComponent")
    mission9Component = current_scene:get_entity_by_name("Mission9Collider"):get_component("ScriptComponent")

    textBlueComponent = current_scene:get_entity_by_name("MisionTextBlue"):get_component("UITextComponent")
    textRedComponent = current_scene:get_entity_by_name("MisionTextRed"):get_component("UITextComponent")
    textBlueTransform = current_scene:get_entity_by_name("MisionTextBlue"):get_component("TransformComponent")
    textRedTransform = current_scene:get_entity_by_name("MisionTextRed"):get_component("TransformComponent")

    imgBlue = current_scene:get_entity_by_name("MisionImage"):get_component("TransformComponent")
    imgRed = current_scene:get_entity_by_name("MisionImageRed"):get_component("TransformComponent")
end

function on_update(dt)
    updateText()
    missionBlue_Tutor()
    missionRed_Tutor()

    processAnimation(dt, blueAnimation, imgBlue, textBlueTransform, function()
        blueTaskIndex = blueTaskIndex + 1
        if blueTaskIndex > #blueTasks then blueTaskIndex = #blueTasks + 1 end
    end)
    processAnimation(dt, redAnimation, imgRed, textRedTransform, function()
        redTaskIndex = redTaskIndex + 1
        if redTaskIndex > #redTasks then redTaskIndex = #redTasks + 1 end
    end)
end

function updateText()
    local blueText = getCurrentTask(blueTasks, blueTaskIndex)
    local redText = getCurrentTask(redTasks, redTaskIndex)
    textBlueComponent:set_text(blueText == "" and "All missions done!" or blueText)
    textRedComponent:set_text(redText == "" and "All missions done!" or redText)
end

function getCurrentTask(tasks, index)
    if index > #tasks then return "" end
    local description = tasks[index].description

    description = description:gsub("x", tostring(enemyDieCounttest))

    return insert_line_breaks(description, 26)
end

function missionBlue_Tutor()
    if blueAnimation.playing or blueTaskIndex > #blueTasks then return end
    if blueTaskIndex == 1 and Input.get_axis_position(Input.axiscode.LeftX) ~= 0 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 2 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 3 and mission4Component.m4_Clear then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 4 and M5_WorkBrech then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 5 and mission6Component.m6_Clear then
        startAnimation(blueAnimation)
    elseif mission6Component.m7_missionOpen and enemyDie_M7 <= 0 then
        mission7Complet = true
    elseif blueTaskIndex == 6 and mission7Complet then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 7 and mission8Component.m8_Clear then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 8 and M9_WorkBrech then
        startAnimation(blueAnimation)
    elseif mission8Component.m10_missionOpen and enemyDie_M10 <= 0 then
        mission10Complet = true
    elseif blueTaskIndex == 9 and mission10Complet then
        startAnimation(blueAnimation)
    end
end

function missionRed_Tutor()
    if redAnimation.playing or redTaskIndex > #redTasks then return end
    if redTaskIndex == 1 and enemyDieCount >= 2 then
        startAnimation(redAnimation)
    end
end

function startAnimation(anim)
    if not anim.start and not anim.playing then
        anim.start = true
        anim.playing = true
        anim.closing = true
        anim.lerpTime = 0.0
    end
end

function processAnimation(dt, anim, img, text, onComplete)
    if not anim.start then return end

    local ori = anim.closing and imgPosOri or imgPosDes
    local des = anim.closing and imgPosDes or imgPosOri
    local tOri = anim.closing and textPosOri or textPosDes
    local tDes = anim.closing and textPosDes or textPosOri

    anim.lerpTime = math.min(anim.lerpTime + dt * 3, 1.0)
    img.position.x = lerp(ori, des, anim.lerpTime)
    text.position.x = lerp(tOri, tDes, anim.lerpTime)

    if anim.lerpTime >= 1.0 then
        if anim.closing then
            anim.closing = false
            anim.lerpTime = 0.0
            onComplete()
        else
            anim.start = false
            anim.playing = false
            anim.lerpTime = 0.0
        end
    end
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function insert_line_breaks(text, max_chars_per_line)
    local result, current_line, current_length = {}, "", 0
    for word in text:gmatch("%S+") do
        local word_length = utf8_char_count(word)
        if current_length + word_length > max_chars_per_line then
            table.insert(result, current_line)
            current_line, current_length = word, word_length
        else
            if current_line ~= "" then
                current_line = current_line .. " " .. word
                current_length = current_length + 1 + word_length
            else
                current_line, current_length = word, word_length
            end
        end
    end
    if current_line ~= "" then table.insert(result, current_line) end
    return table.concat(result, "\n")
end

function utf8_char_count(s)
    local _, count = s:gsub("[^\128-\191]", "")
    return count
end