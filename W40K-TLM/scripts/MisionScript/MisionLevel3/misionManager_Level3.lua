-- Task list split by color
local blueTasks = {
    {id = 12, description = "Aqui es nivel 3 Blue"},
    {id = 13, description = "Find and use the lever to open the East Door"},
    {id = 14, description = "Make your way through the city"},
    {id = 15, description = "Explore and exit the Hive City Central Square"},
    {id = 16, description = "Upgrade your equipment before fighting in the Great Bridge"},
    {id = 17, description = "Pull the lever to open the Great Bridge door"},
    {id = 18, description = "Pull all the levers on the Great Bridge to open the Elevator Door. (x/2)"},
    {id = 19, description = "Enter the Great Bridge Elevator"}
}



local redTasks = {
    {id = 4, description = "Aqui es nivel 3 Red"},
    {id = 5, description = "Fight your way to the elevator of the Hive City"},
    {id = 6, description = "Fight and defeat (name)"}
}


local dialogLines = {
    { name = "Decius Marcellus", text = "Brother Quintus... this is where your path ends-or where legends are born." },
    { name = "Decius Marcellus", text = "You stand alone, the last blade of Guilliman's will, facing the warboss who brought an entire world to ruin." },
    { name = "Decius Marcellus", text = "Garrosh waits, surrounded by the corpses of heroes. But you are no mere warrior. You are an Ultramarine." },
    { name = "Decius Marcellus", text = "This is not the hour of your death-this is the hour of vengeance. Let none survive." }
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

--MisionBlue
--M3
m3_EnemyCount = 0
--M4
m4_lever = false
m4_EnemyCount = 0
--M5
m5_Upgrade = false
--M6
m6_heal  = false
--M7
m7_Upgrade = false
--m8
m8_lever1 = false
m8_lever2 = false
--M9
m9_EnemyCount = 0
--M10
m10_Upgrade = false
--M11
m11_NewZone = false

--MisionRed
--MR1
mr1_supply = false
--MR2
mr2_orkzBase = false
--MR3
mr3_breakOut = false

-- Trigger variables
enemyDieCounttest = 2
enemyDieCount = 0
enemyDie_M7 = 1
enemyDie_M10 = 1
M5_WorkBrech = false
M9_WorkBrech = false
local dialogScriptComponent = nil

local actualAlpha = 1

function on_ready()

    textBlueComponent = current_scene:get_entity_by_name("MisionTextBlue"):get_component("UITextComponent")
    textRedComponent = current_scene:get_entity_by_name("MisionTextRed"):get_component("UITextComponent")
    textBlueTransform = current_scene:get_entity_by_name("MisionTextBlue"):get_component("TransformComponent")
    textRedTransform = current_scene:get_entity_by_name("MisionTextRed"):get_component("TransformComponent")

    imgBlue = current_scene:get_entity_by_name("MisionImage"):get_component("TransformComponent")
    imgRed = current_scene:get_entity_by_name("MisionImageRed"):get_component("TransformComponent")

    imgBlueUI = current_scene:get_entity_by_name("MisionImage"):get_component("UIImageComponent")
    imgRedUI = current_scene:get_entity_by_name("MisionImageRed"):get_component("UIImageComponent")

    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    dialogScriptComponent.start_dialog(dialogLines)
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


    if Input.is_key_pressed(Input.keycode.I) then
        m8_lever1 = true
        m8_lever2 = true
    end




   
    --imgBlue.position.y = imgBlue.position.y-1
   --imgBlue.position.y = 500
   --imgBlue:set_size(Vector2.new(1,1))
   --print(imgBlue.position.y)

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
    if blueTaskIndex == 1 and Input.get_axis_position(Input.axiscode.LeftX) ~= 0 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 2 and Input.get_axis_position(Input.axiscode.RightX) ~= 0 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 3 and m3_EnemyCount == 2 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 4 and m4_EnemyCount == 2 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 5 and m5_Upgrade then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 6 and m6_heal then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 7 and m7_Upgrade then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 8 and m8_lever1 and m8_lever2 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 9 and m9_EnemyCount == 3 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 10 and m10_Upgrade then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 11 and m11_NewZone then
        startAnimation(blueAnimation)
    end
end

function missionRed_Tutor()
    if redAnimation.playing or redTaskIndex > #redTasks then return end
    if redTaskIndex == 1 and mr1_supply then
        startAnimation(redAnimation)
    elseif redTaskIndex == 2 and mr2_orkzBase then
        startAnimation(redAnimation)
    elseif redTaskIndex == 3 and mr3_breakOut then
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