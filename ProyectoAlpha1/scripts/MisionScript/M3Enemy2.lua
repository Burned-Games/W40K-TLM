m3_enemy2_die = false
missionManagerComponent = nil
mission6Component = nil
function on_ready()
    -- Add initialization code here
    missionManagerComponent = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")
    mission6Component = current_scene:get_entity_by_name("Mission6Collider"):get_component("ScriptComponent")
end

function on_update(dt)
    -- Add update code here
    if Input.is_key_pressed(Input.keycode.M) then
        m3_enemy2_die = true
    end


    if Input.is_key_pressed(Input.keycode.V) then
        if mission6Component.m7_missionOpen == true then
            missionManagerComponent.enemyDie = missionManagerComponent.enemyDie-1
            print("Enemy die")
        end
    end
end

function on_exit()
    -- Add cleanup code here
end
