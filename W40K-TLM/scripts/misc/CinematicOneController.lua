local timeToTransition = 18

local contador = 0
local fadeToBlackScript = nil
local changeing = false

local uiskipEntity = nil
local uiskipActualOffset = 0
local uiSkipSpeed = 1000


function on_ready()
    -- Add initialization code here
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
    uiskipEntity = current_scene:get_entity_by_name("UI_SKIP_Indicator")
    --move_ui_element(uiskipEntity, uiskipActualOffset, -16)
end

function on_update(dt)
    contador = contador + dt
    Input.send_rumble(1, 1, 200) 
    if  not changeing and (contador > timeToTransition or uiskipActualOffset >= 2000) then
        changeing = true
        move_ui_element(uiskipEntity, -2000, 0)
        
        fadeToBlackScript:DoFade()
    end
    

    if changeing and not changeScene then
        if fadeToBlackScript.fadeToBlackDoned then
            changeScene = true
            SceneManager.change_scene("scenes/level1.TeaScene")
        end
    end

    

end

function on_exit()
    -- Add cleanup code here
end
