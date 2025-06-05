local introBossDone = false

local playerAnimator = nil
local playerTransf = nil
local bossAnimator = nil
local cameraTransf = nil

function on_ready()
    introBossDone = load_progress("introBossDone", introBossDone)

    -- Player
    playerAnimator = current_scene:get_entity_by_name("Player"):get_component("AnimatorComponent")
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent").rb

    -- Main Boss
    bossAnimator = current_scene:get_entity_by_name("MainBoss"):get_component("AnimatorComponent")

    -- Camera
    cameraTransf = current_scene:get_entity_by_name("Camera"):get_component("TransformComponent")
end

function on_update(dt)
    
    if not introBossDone then



        introBossDone = true
        save_progress("introBossDone", introBossDone)
    else

    end

end

function on_exit() end
