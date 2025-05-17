

local timeToTransition = 10



local contador = 0
local fadeToBlackScript = nil
local changeing = false

function on_ready()
    -- Add initialization code here
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
    
end

function on_update(dt)
    -- Add update code here

    contador = contador + dt
    if contador > timeToTransition and not changeing then
        changeing = true
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
