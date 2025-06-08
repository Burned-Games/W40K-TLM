

local blueTasks = {}
local redTasks = {}

blueTaskIndex = 1
redTaskIndex = 1


local current_scene_name = nil

local textBlueComponent = nil
local textRedComponent = nil
local imgBlueUI = nil
local imgRedUI = nil

local bcgBlueUI = nil
local bcgRedUI = nil
local bck = false
local actualAlphaBackground = 0

local blueAnimation = {start = false, playing = false, lerpTime = 0.0, phase = ""}
local redAnimation = {start = false, playing = false, lerpTime = 0.0, phase = ""}

--Level1
current_Level = nil
m3_EnemyCount = 0
m4_lever = false
m4_EnemyCount = 0
m4_showLeverPop = false
m5_Upgrade = false
m6_heal  = false
m7_Defeate = false
m7_Upgrade = false
m8_lever = 0
m9_EnemyCount = false
m10_Upgrade = false
m11_NewZone = false
mr1_supply = false
mr2_orkzBase = false
mr3_breakOut = false

--Level2
-- Mission Blue
-- M1
m1_Upgrade = false
-- M2
m2_lever = false
-- M3
m3_throughCity = false
-- M4
m4_exitCity = false
-- M5
m5_Upgrade = false
-- M6
m6_lever = false
-- M7
m7_lever = 0
-- M8
m8_Elevator = false

-- Mission Red
-- MR1
mr1_Check = false
-- MR2
mr2_Check = false
-- MR3
mr3_Check = false


actualAlpha = 0
delayTimer = 0
initialDelay = 3.0
initialDelayDone = false

--Audio
local missionCompleteSFX = nil

function on_ready()



    textBlueComponent = current_scene:get_entity_by_name("MisionTextBlue"):get_component("UITextComponent")
    textRedComponent = current_scene:get_entity_by_name("MisionTextRed"):get_component("UITextComponent")

    --Audio
    missionCompleteSFX = current_scene:get_entity_by_name("MissionCompleteSFX"):get_component("AudioSourceComponent")

    imgBlueUI = current_scene:get_entity_by_name("MisionImage"):get_component("UIImageComponent")
    imgRedUI = current_scene:get_entity_by_name("MisionImageRed"):get_component("UIImageComponent")

    bcgBlueUI = current_scene:get_entity_by_name("MisionBackgroundRed"):get_component("UIImageComponent")
    bcgRedUI = current_scene:get_entity_by_name("MisionBackgroundBlue"):get_component("UIImageComponent")

    current_scene_name = SceneManager:get_scene_name()

    popupScriptComponent = current_scene:get_entity_by_name("PopUpManager"):get_component("ScriptComponent")
    
    imgBlueUI:set_color(Vector4.new(1, 1, 1, 0))
    imgRedUI:set_color(Vector4.new(1, 1, 1, 0))
    textBlueComponent:set_color(Vector4.new(1, 1, 1, 0))
    textRedComponent:set_color(Vector4.new(1, 1, 1, 0))

    bcgBlueUI:set_color(Vector4.new(0, 0, 0, 0))
    bcgRedUI:set_color(Vector4.new(0, 0, 0, 0))

    blueTaskIndex = load_progress("bluemision",1)
    redTaskIndex = load_progress("redmision",1)


    
    if current_scene_name == "level1.TeaScene" then
        current_Level = 1
        blueTasks = {
            {id = 1, description = "Start moving with [L]"},
            {id = 2, description = "Aim with [R] and shoot with [RT]"},
            {id = 3, description = "Defeat the first ork"},
            {id = 4, description = "Finish the Orkz and pull the lever up"},
            {id = 5, description = "Upgrade your equipment with the drop pod supply"},
            {id = 6, description = "Find and get the Bio-Recovery Shot to heal yourself"},
            {id = 7, description = "Continue going East while defeating enemy orkz"},
            {id = 8, description = "Upgrade your equipment for the big fight"},
            {id = 9, description = "Pull both levers to get to the Orkz base (x/2)"},
            {id = 10, description = "Be the last standing on the Orkz Colliseum"},
            {id = 11, description = "Upgrade your equipment before leaving the Orkz base"},
            {id = 12, description = "Find a way to get to the Hive City"}
        }

        redTasks = {
            {id = 1, description = "Find the drop pod supply"},
            {id = 2, description = "Make your way to the orkz base"},
            {id = 3, description = "Break out of the orkz base to the Hive City"}
        }
    
    elseif current_scene_name == "level2.TeaScene" then
        current_Level = 2
        blueTasks = {
            {id = 1, description = "Upgrade your equipment before entering the Hive City"},
            {id = 2, description = "Find and use the lever to open the East Door"},
            {id = 3, description = "Make your way through the city"},
            {id = 4, description = "Explore and exit the Hive City Central Square"},
            {id = 5, description = "Upgrade your equipment before fighting in the Great Bridge"},
            {id = 6, description = "Pull the lever to open the Great Bridge door"},
            {id = 7, description = "Pull the lever on the Great Bridge to open the Elevator Door"},
            {id = 8, description = "Enter the Great Bridge Elevator"}
        }

        redTasks = {
            {id = 1, description = "Get to the Great Bridge of the Hive City"},
            {id = 2, description = "Fight your way to the elevator of the Hive City"},
            {id = 3, description = "Fight and defeat Brutus"}
        }
       
    elseif current_scene_name == "level3.TeaScene" then
        current_Level = 3
        blueTasks = {
            {id = 1, description = "Defeat Gorklaw"},
            {id = 2, description = "Destroy Boss"},

        }

        redTasks = {
            {id = 1, description = "Defeat Gorklaw"},
            {id = 2, description = "Destroy Boss"},

        }
    end
end

function on_update(dt)
    if not initialDelayDone then
        delayTimer = delayTimer + dt
        if delayTimer >= initialDelay then
            initialDelayDone = true
            blueAnimation.phase = "opening"
            blueAnimation.start = true
            blueAnimation.playing = true

            redAnimation.phase = "opening"
            redAnimation.start = true
            redAnimation.playing = true

            bck = true
        end
        return
    end

    updateText()
    missionBlue_Tutor()
    missionRed_Tutor()

    processAnimation(dt, blueAnimation, imgBlueUI, textBlueComponent, function()

        blueTaskIndex = blueTaskIndex + 1
        if blueTaskIndex > #blueTasks then 
            blueTaskIndex = #blueTasks + 1
        end
    end)
    
    processAnimation(dt, redAnimation, imgRedUI, textRedComponent, function()
        redTaskIndex = redTaskIndex + 1
        if redTaskIndex > #redTasks then 
            redTaskIndex = #redTasks + 1
        end
    end)
end

function updateText()
    local blueText = getCurrentTask(blueTasks, blueTaskIndex)
    local redText = getCurrentTask(redTasks, redTaskIndex)
    textBlueComponent:set_text(blueText == "" and "All missions done!" or blueText)
    textRedComponent:set_text(redText == "" and "All missions done!" or redText)
end

function getCurrentTask(tasks, index)

    if index > #tasks then 
        return ""
    end
    local description = tasks[index].description


    if current_scene_name == "level1.TeaScene" then

        if blueTaskIndex == 9 then
            description = description:gsub("x", tostring(m8_lever))
        end

    elseif current_scene_name == "level2.TeaScene" then
        if blueTaskIndex == 7 then
            description = description:gsub("x", tostring(m7_lever))
        end
       
    elseif current_scene_name == "level3.TeaScene" then
    end

    return insert_line_breaks(description, 23)
end

function missionBlue_Tutor()
    if blueAnimation.playing or blueTaskIndex > #blueTasks then return end

    if current_scene_name == "level1.TeaScene" then
        if blueTaskIndex == 1 and Input.get_axis_position(Input.axiscode.LeftX) ~= 0 then
            startAnimation(blueAnimation)
        elseif blueTaskIndex == 2 and Input.get_axis_position(Input.axiscode.RightTrigger) ~= 0 then
            startAnimation(blueAnimation)
        elseif blueTaskIndex == 3 and m3_EnemyCount >= 1 then
            startAnimation(blueAnimation)
            popupScriptComponent.start_popup_removal_timer()
        elseif blueTaskIndex == 4 and m4_lever and m4_EnemyCount >= 2 then
            startAnimation(blueAnimation)
        elseif blueTaskIndex == 5 and m5_Upgrade then
            startAnimation(blueAnimation)
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
        elseif blueTaskIndex == 10 and m9_EnemyCount == true then
            startAnimation(blueAnimation)
            popupScriptComponent.remove_persistent_popup()
        elseif blueTaskIndex == 11 and m10_Upgrade then
            startAnimation(blueAnimation)
        elseif blueTaskIndex == 12 and m11_NewZone then
            startAnimation(blueAnimation)
        end

    elseif current_scene_name == "level2.TeaScene" then
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
       
    elseif current_scene_name == "level3.TeaScene" then
        if blueTaskIndex == 1 and BossDie then
            startAnimation(blueAnimation)
        end
    end



    
end

function missionRed_Tutor()
    if redAnimation.playing or redTaskIndex > #redTasks then return end

    if current_scene_name == "level1.TeaScene" then

        if redTaskIndex == 1 and mr1_supply then
            startAnimation(redAnimation)
        elseif redTaskIndex == 2 and mr2_orkzBase then
            startAnimation(redAnimation)
        elseif redTaskIndex == 3 and mr3_breakOut then
            startAnimation(redAnimation)
        end
        
    elseif current_scene_name == "level2.TeaScene" then

       if redTaskIndex == 1 and mr1_Check then
            startAnimation(redAnimation)
        elseif redTaskIndex == 2 and mr2_Check then
            startAnimation(redAnimation)
        elseif redTaskIndex == 3 and mr3_Check then
            startAnimation(redAnimation)
        end
    elseif current_scene_name == "level3.TeaScene" then
        if redTaskIndex == 1 and BossDie then
            startAnimation(blueAnimation)
        end
    end

    
end


function startAnimation(anim)
    if not anim.start and not anim.playing then
        anim.start = true
        anim.playing = true
        anim.phase = "closing"
        anim.lerpTime = 0.0
        missionCompleteSFX:play()
    end
end


function processAnimation(dt, anim, img, text, onComplete)
    if not anim.start then return end

    anim.lerpTime = anim.lerpTime + (dt * 2.0)
    
    if anim.phase == "opening" then
        actualAlpha = lerp(0.0, 1.0, anim.lerpTime)
    else 
        actualAlpha = lerp(1.0, 0.0, anim.lerpTime)
    end

    if bck and actualAlphaBackground < 0.5 then
        actualAlphaBackground = lerp(0.0, 0.5, anim.lerpTime)
    end


    if anim.lerpTime >= 1.0 then
        anim.lerpTime = 0.0
        if anim.phase == "closing" then
            onComplete()
            anim.phase = "opening"
            anim.start = true  
        else
            anim.start = false
            anim.playing = false
        end
    end

    img:set_color(Vector4.new(1, 1, 1, actualAlpha))
    text:set_color(Vector4.new(1, 1, 1, actualAlpha))
    bcgBlueUI:set_color(Vector4.new(0, 0, 0, actualAlphaBackground))
    bcgRedUI:set_color(Vector4.new(0, 0, 0, actualAlphaBackground))
end

function lerp(a, b, t)
    return a + (b - a) * math.min(t, 1.0)
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

function getCurrerTaskIndex(isBlue)
    if isBlue then
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

function on_exit()
end