local enemyAlertUI = nil
local alertTimer = 0

function on_ready()
    enemyAlertUI = current_scene:get_entity_by_name("EnemyAlertedUI")
end

function on_update(dt)
    alertTimer = alertTimer + dt
    if alertTimer >= 5 then
        current_scene:destroy_entity(enemyAlertUI)
    end
end

function on_exit()
    -- Add cleanup code here
end