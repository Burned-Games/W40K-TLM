-- Task list split by color
local blueTasks = {
    {id = 1, description = "Start moving with [L]"},
    {id = 2, description = "Aim with [R] and shoot with [RT]"},
    {id = 3, description = "Defeat both Orkz (x/2)"},
    {id = 4, description = "Finish the Orkz and pull the lever up"},
    {id = 5, description = "Upgrade your equipment with the drop pod supply"},
    {id = 6, description = "Find and get the Bio-Recovery Shot to heal yourself"},
    {id = 7, description = "Continue going East while defeating enemy orkz"},
    {id = 8, description = "Upgrade your equipment for the big fight"},
    {id = 9, description = "Pull both levers to get to the Orkz base (x/2)"},
    {id = 10, description = "Be the last standing on the Orkz Colliseum (x/3)"},
    {id = 11, description = "Upgrade your equipment before leaving the Orkz base"},
    {id = 12, description = "Find a way to get to the Hive City"}
}



local redTasks = {
    {id = 1, description = "Find the drop pod supply"},
    {id = 2, description = "Make your way to the orkz base"},
    {id = 3, description = "Break out of the orkz base to the Hive City"}
}


dialogLines = {
    { name = "Decius Marcellus", text = "This is Decius Marcellus, commander of Guilliman's Fist..." },
    { name = "Decius Marcellus", text = "Has anyone successfully made planetfall? I repeat: are there any survivors?" },
    { name = "Decius Marcellus", text = "I think you're the only survivor, Brother Quintus Maxillian. Maintain course toward Martyria Eterna." },
    { name = "Decius Marcellus", text = "We detect enemies along your path. May the Emperor be with you." }
}

dialogLines2 = {
    { name = "Decius Marcellus", text = "Brother Quintus, that is an upgrade station. With it, you can enhance your equipment to continue the xenos purge." },
    { name = "Decius Marcellus", text = "Search for them in the field-they could make a huge difference in how the battle unfolds." }
}

dialogLines3 = {
    { name = "Decius Marcellus", text = "Brother Quintus, it's an ambush! Hold out until the enemies are eliminated." },
    { name = "Decius Marcellus", text = "May the Emperor's light guide you, for Ultramar!" }
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

local current_Level = 1
--MisionBlue
--M3
m3_EnemyCount = 0
--M4
m4_lever = false
m4_EnemyCount = 0
m4_showLeverPop = false
--M5
m5_Upgrade = false
--M6
m6_heal  = false

--M7Espercial
m7_Defeate = false

--M7
m7_Upgrade = false
--m8
m8_lever = 0
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

    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    dialogScriptComponent.start_dialog(dialogLines)

    popupScriptComponent = current_scene:get_entity_by_name("PopUpManager"):get_component("ScriptComponent")

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
        description = description:gsub("x", tostring(m8_lever))
    end

    if blueTaskIndex == 10 then
        description = description:gsub("x", tostring(m9_EnemyCount))
    end

    return insert_line_breaks(description, 31)
end

function missionBlue_Tutor()
    if blueAnimation.playing or blueTaskIndex > #blueTasks then return end
    if blueTaskIndex == 1 and Input.get_axis_position(Input.axiscode.LeftX) ~= 0 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 2 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0 then
        startAnimation(blueAnimation)
        --popupScriptComponent.show_popup(false, "[Y] to change weapon")
    elseif blueTaskIndex == 3 and m3_EnemyCount >= 2 then
        startAnimation(blueAnimation)
        popupScriptComponent.start_popup_removal_timer()
    elseif blueTaskIndex == 4 and m4_lever and m4_EnemyCount >= 2 then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 5 and m5_Upgrade then
        startAnimation(blueAnimation)
        --popupScriptComponent.show_popup(false, "[B] to dash")
    elseif blueTaskIndex == 6 and m6_heal then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 7 and m7_Defeate then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 8 and m7_Upgrade then
        startAnimation(blueAnimation)
        popupScriptComponent.start_popup_removal_timer()
    elseif blueTaskIndex == 9 and m8_lever == 2 then
        startAnimation(blueAnimation)
        popupScriptComponent.start_popup_removal_timer()
        popupScriptComponent.remove_persistent_popup()
    elseif blueTaskIndex == 10 and m9_EnemyCount == 3 then
        startAnimation(blueAnimation)
        popupScriptComponent.remove_persistent_popup()
    elseif blueTaskIndex == 11 and m10_Upgrade then
        startAnimation(blueAnimation)
    elseif blueTaskIndex == 12 and m11_NewZone then
        startAnimation(blueAnimation)
    end
end

function missionRed_Tutor()
    if redAnimation.playing or redTaskIndex > #redTasks then return end
    if redTaskIndex == 1 and mr1_supply then
        startAnimation(redAnimation)
        dialogScriptComponent.start_dialog(dialogLines2)
    elseif redTaskIndex == 2 and mr2_orkzBase then
        startAnimation(redAnimation)
        dialogScriptComponent.start_dialog(dialogLines3)
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

function getCurrerLevel()
   
    return current_Level
end 