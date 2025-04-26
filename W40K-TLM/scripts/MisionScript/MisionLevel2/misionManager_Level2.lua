-- Task list split by color
local blueTasks = {
    {id = 1, description = "Upgrade your equipment before entering the Hive City"},
    {id = 2, description = "Find and use the lever to open the East Door"},
    {id = 3, description = "Make your way through the city"},
    {id = 4, description = "Explore and exit the Hive City Central Square"},
    {id = 5, description = "Upgrade your equipment before fighting in the Great Bridge"},
    {id = 6, description = "Pull the lever to open the Great Bridge door"},
    {id = 7, description = "Pull all the levers on the Great Bridge to open the Elevator Door. (x/2)"},
    {id = 8, description = "Enter the Great Bridge Elevator"}
}



local redTasks = {
    {id = 4, description = "Get to the Great Bridge of the Hive City"},
    {id = 5, description = "Fight your way to the elevator of the Hive City"},
    {id = 6, description = "Fight and defeat (name)"}
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
local imgBlueUI = nil
local imgRedUI = nil

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

local current_Level = 2

--MisionBlue
--M1
m1_Upgrade = false
--M2
m2_lever = false
--M3
m3_throughCity = false
--M4
m4_exitCity = false
--M5
m5_Upgrade = false
--M6
m6_lever = false
--M7
m7_lever = 0
--M8
m8_Elevator = false


--MisionRed
--MR1
mr1_Check = false
--MR2
mr2_Check = false
--MR3
mr3_Check = false

-- Trigger variables
enemyDieCounttest = 2
enemyDieCount = 0
enemyDie_M7 = 1
enemyDie_M10 = 1
M5_WorkBrech = false
M9_WorkBrech = false

local actualAlpha = 1

function on_ready()
    --mission4Component = current_scene:get_entity_by_name("Mission4Collider"):get_component("ScriptComponent")
    --mission5Component = current_scene:get_entity_by_name("Mission5Mesa"):get_component("ScriptComponent")
    --mission6Component = current_scene:get_entity_by_name("Mission6Collider"):get_component("ScriptComponent")
    --mission8Component = current_scene:get_entity_by_name("Mission8Collider"):get_component("ScriptComponent")
    --mission9Component = current_scene:get_entity_by_name("Mission9Collider"):get_component("ScriptComponent")

    textBlueComponent = current_scene:get_entity_by_name("MisionTextBlue"):get_component("UITextComponent")
    textRedComponent = current_scene:get_entity_by_name("MisionTextRed"):get_component("UITextComponent")
    textBlueTransform = current_scene:get_entity_by_name("MisionTextBlue"):get_component("TransformComponent")
    textRedTransform = current_scene:get_entity_by_name("MisionTextRed"):get_component("TransformComponent")

    imgBlue = current_scene:get_entity_by_name("MisionImage"):get_component("TransformComponent")
    imgRed = current_scene:get_entity_by_name("MisionImageRed"):get_component("TransformComponent")

    imgBlueUI = current_scene:get_entity_by_name("MisionImage"):get_component("UIImageComponent")
    imgRedUI = current_scene:get_entity_by_name("MisionImageRed"):get_component("UIImageComponent")
end

function on_update(dt)
    updateText()
    missionBlue_Tutor()
    missionRed_Tutor()

    processAnimation(dt, blueAnimation, imgBlueUI, textBlueComponent, function()
        blueTaskIndex = blueTaskIndex + 1
        if blueTaskIndex > #blueTasks then blueTaskIndex = #blueTasks + 1 end
    end)
    processAnimation(dt, redAnimation, imgRedUI, textRedComponent, function()
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

    if blueTaskIndex == 3 then
        description = description:gsub("x", tostring(m3_EnemyCount))
    end

    if blueTaskIndex == 9 then
        description = description:gsub("x", tostring(m9_EnemyCount))
    end

    return insert_line_breaks(description, 23)
end





function missionBlue_Tutor()
    if blueAnimation.playing or blueTaskIndex > #blueTasks then return end
    if blueTaskIndex == 1 and m1_Upgrade then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 2 and m2_lever then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 3 and m3_throughCity then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 4 and m4_exitCity then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 5 and m5_Upgrade then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 6 and m6_lever then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 7 and m7_lever == 2 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 8 and m8_Elevator then
        startAnimation(blueAnimation)
    end
end

function missionRed_Tutor()
    if redAnimation.playing or redTaskIndex > #redTasks then return end
    if redTaskIndex == 1 and mr1_Check then
        startAnimation(redAnimation)
    elseif redTaskIndex == 2 and mr2_Check then
        startAnimation(redAnimation)
    elseif redTaskIndex == 3 and mr3_Check then
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

    anim.lerpTime = anim.lerpTime + (dt * 0.1)
    --img.position.x = lerp(ori, des, anim.lerpTime)
    --text.position.x = lerp(tOri, tDes, anim.lerpTime)
    
    if anim.lerpTime >= 0.1 then
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
    
    if anim.closing then
        actualAlpha = lerp(actualAlpha, 0.0, anim.lerpTime)
    elseif anim.start then
        actualAlpha = lerp(actualAlpha, 1.0, anim.lerpTime)
    end
    img:set_color(Vector4.new(1, 1, 1, actualAlpha))
    text:set_color(Vector4.new(1, 1, 1, actualAlpha))
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