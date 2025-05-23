-- Task list split by color
local blueTasks = {
    {id = 12, description = "Upgrade your equipment before entering the Hive City"},
    {id = 13, description = "Find and use the lever to open the East Door"},
    {id = 14, description = "Make your way through the city"},
    {id = 15, description = "Explore and exit the Hive City Central Square"},
    {id = 16, description = "Upgrade your equipment before fighting in the Great Bridge"},
    {id = 17, description = "Pull the lever to open the Great Bridge door"},
    {id = 18, description = "Pull all the levers on the Great Bridge to open the Elevator Door. (x/2)"},
    {id = 19, description = "Enter the Great Bridge Elevator"}
}



local redTasks = {
    {id = 4, description = "Get to the Great Bridge of the Hive City"},
    {id = 5, description = "Fight your way to the elevator of the Hive City"},
    {id = 6, description = "Fight and defeat (name)"}
}

local blueTaskIndex = 12
local redTaskIndex = 4

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


--M12
m3_EnemyCount = 2
--M13
m4_lever = false
--M14
m5_Upgrade = false
--M15
m6_heal  = false
--M16
m7_Upgrade = false
--m17
m8_lever1 = false
m8_lever2 = false
--M18
m9_EnemyCount = 3
--M19
m10_Upgrade = false



-- Trigger variables
enemyDieCounttest = 2
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

    if Input.is_key_pressed(Input.keycode.P) then
        m4_lever = true
    end

    if Input.is_key_pressed(Input.keycode.O) then
        m5_Upgrade = true
    end

    if Input.is_key_pressed(Input.keycode.I) then
        m6_heal = true
    end

    if Input.is_key_pressed(Input.keycode.U) then
        m7_Upgrade = true
    end
    if Input.is_key_pressed(Input.keycode.Y) then
        m8_lever1 = true
        m8_lever2 = true
    end
    if Input.is_key_pressed(Input.keycode.T) then
        m10_Upgrade = true
    end
    if Input.is_key_pressed(Input.keycode.R) then
        m11_NewZone = true
    end

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

    if blueTaskIndex == 3 then
        description = description:gsub("x", tostring(m3_EnemyCount))
    end

    if blueTaskIndex == 9 then
        description = description:gsub("x", tostring(m9_EnemyCount))
    end

    return insert_line_breaks(description, 26)
end

function missionBlue_Tutor()
    if blueAnimation.playing or blueTaskIndex > #blueTasks then return end
    if blueTaskIndex == 12 and Input.get_axis_position(Input.axiscode.LeftX) ~= 0 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 13 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 14 and m3_EnemyCount == 0 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 15 and m4_lever then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 16 and m5_Upgrade then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 17 and m6_heal then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 18 and m7_Upgrade then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 19 and m8_lever1 and m8_lever2 then
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

function getCurrerTaskIndex(type)
    if type == true then
        return blueTaskIndex
    else
        return redTaskIndex
    end
end 


function utf8_char_count(s)
    local _, count = s:gsub("[^\128-\191]", "")
    return count
end