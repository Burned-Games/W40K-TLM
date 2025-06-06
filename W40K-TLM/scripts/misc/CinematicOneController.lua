local timeToTransition = 18

local contador = 0
local fadeToBlackScript = nil
local changeing = false


local dialogManager = nil

-- Audio
local cinematicIntroSFX = nil
local cinematicOutroSFX = nil
local hasOutroPlayed = false

function on_ready()
    -- Add initialization code here
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
    dialogManager = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    --move_ui_element(uiskipEntity, uiskipActualOffset, -16)

    -- Audio
    cinematicIntroSFX = current_scene:get_entity_by_name("IntroCinematicSFX"):get_component("AudioSourceComponent")
    cinematicOutroSFX = current_scene:get_entity_by_name("OutroCinematicSFX"):get_component("AudioSourceComponent")

    cinematicIntroSFX:play()
end

function on_update(dt)
    contador = contador + dt
    Input.send_rumble(0.1, 1, 1) 

    if  not changeing and (contador > timeToTransition or dialogManager.finishedDialog) then
        changeing = true
        fadeToBlackScript:DoFade()
    end

    if changeing and not changeScene then
        if not hasOutroPlayed then
            cinematicOutroSFX:play()
            hasOutroPlayed = true
        end
        if fadeToBlackScript.fadeToBlackDoned then
            changeScene = true
            SceneManager.change_scene("scenes/level1.TeaScene")
        end
    end

    

end

function on_exit()
    -- Add cleanup code here
end
