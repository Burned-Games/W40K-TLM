local timeToTransition = 0.1



local contador = 0
local fadeToBlackScript = nil
local changeing = false
local doTransition = false




function on_ready()
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")

    triggerBossBattle = self:get_component("RigidbodyComponent")
    triggerBossBattle.rb:set_trigger(true)
    
    triggerBossBattle:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            doTransition = true
        end
    end)
end

function on_update(dt)
    if not doTransition then return end

    contador = contador + dt
    if  not changeing and contador > timeToTransition then
        changeing = true
        fadeToBlackScript:DoFade()
    end
 
    if changeing and not changeScene then
        if fadeToBlackScript.fadeToBlackDoned then
            changeScene = true
            SceneManager.change_scene("scenes/bossArena.TeaScene")
        end
    end
end

function on_exit()
    -- Add cleanup code here
end
